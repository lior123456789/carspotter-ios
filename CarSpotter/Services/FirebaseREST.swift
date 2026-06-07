import Foundation
import FirebaseAuth

/**
 * Thin REST wrappers around Firebase Firestore + Storage that don't
 * need the heavy native SDKs (which made the Xcode build hang for 24h).
 *
 * Authentication: every call attaches the signed-in user's Firebase
 * ID token. The same Firestore Security Rules + Storage Rules that
 * gate the web app apply here automatically.
 */

private let projectID = "carspotter-c0863"
private let storageBucket = "carspotter-c0863.firebasestorage.app"

enum FirebaseRESTError: LocalizedError {
    case notSignedIn
    case http(Int, String)
    case decode

    var errorDescription: String? {
        switch self {
        case .notSignedIn:    return "Please sign in first."
        case .http(let c, _): return "Server error (\(c))."
        case .decode:         return "Couldn't parse server response."
        }
    }
}

// MARK: - Firestore REST

enum FirestoreREST {
    private static var baseURL: URL {
        URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents")!
    }

    /// Convert a Swift dictionary into Firestore's typed "fields" wire format.
    /// Supports String, Int, Double, Bool, Date, Array, and nested dicts.
    private static func encodeFields(_ data: [String: Any]) -> [String: Any] {
        ["fields": data.mapValues(typedValue)]
    }

    private static func typedValue(_ v: Any) -> [String: Any] {
        switch v {
        case let s as String:                return ["stringValue": s]
        case let b as Bool:                  return ["booleanValue": b]
        case let i as Int:                   return ["integerValue": String(i)]
        case let d as Double:                return ["doubleValue": d]
        case let date as Date:
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return ["timestampValue": f.string(from: date)]
        case let arr as [Any]:
            return ["arrayValue": ["values": arr.map(typedValue)]]
        case let dict as [String: Any]:
            return ["mapValue": ["fields": dict.mapValues(typedValue)]]
        case is NSNull:                      return ["nullValue": NSNull()]
        default:                             return ["stringValue": "\(v)"]
        }
    }

    /// Convert Firestore typed fields back into a plain Swift dictionary.
    static func decodeFields(_ fields: [String: Any]) -> [String: Any] {
        fields.mapValues { v -> Any in
            guard let kv = v as? [String: Any] else { return v }
            for (key, val) in kv {
                switch key {
                case "stringValue":    return val
                case "booleanValue":   return val
                case "integerValue":
                    if let s = val as? String, let i = Int(s) { return i }
                    return val
                case "doubleValue":    return val
                case "timestampValue":
                    if let s = val as? String, let d = ISO8601DateFormatter().date(from: s) { return d }
                    return val
                case "arrayValue":
                    if let inner = val as? [String: Any], let values = inner["values"] as? [[String: Any]] {
                        return values.map { v -> Any in decodeFields(["x": v])["x"] ?? NSNull() }
                    }
                    return []
                case "mapValue":
                    if let inner = val as? [String: Any], let nested = inner["fields"] as? [String: Any] {
                        return decodeFields(nested)
                    }
                    return [:]
                case "nullValue":      return NSNull()
                default:               continue
                }
            }
            return v
        }
    }

    private static func authedRequest(_ url: URL, method: String, requireAuth: Bool = true) async throws -> URLRequest {
        let token = try? await Auth.auth().currentUser?.getIDToken()
        if requireAuth && token == nil {
            throw FirebaseRESTError.notSignedIn
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }

    /// Add a doc to a collection. Firestore generates the ID.
    @discardableResult
    static func createDoc(in collection: String, data: [String: Any]) async throws -> String {
        let url = baseURL.appendingPathComponent(collection)
        var req = try await authedRequest(url, method: "POST")
        req.httpBody = try JSONSerialization.data(withJSONObject: encodeFields(data))

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: respData, encoding: .utf8) ?? ""
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0, body)
        }
        guard let json = try JSONSerialization.jsonObject(with: respData) as? [String: Any],
              let name = json["name"] as? String else {
            throw FirebaseRESTError.decode
        }
        // name = "projects/X/databases/(default)/documents/COLLECTION/DOC_ID"
        return name.components(separatedBy: "/").last ?? ""
    }

    /// Set/overwrite a doc at a known path.
    static func setDoc(path: String, data: [String: Any]) async throws {
        // Firestore REST: PATCH on the document with updateMask omitted → upsert
        let url = baseURL.appendingPathComponent(path)
        var req = try await authedRequest(url, method: "PATCH")
        req.httpBody = try JSONSerialization.data(withJSONObject: encodeFields(data))
        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0,
                                         String(data: respData, encoding: .utf8) ?? "")
        }
    }

    /// Read a single document by path (e.g. "users/{uid}"). Returns nil if it
    /// doesn't exist. Used to pick up web/Stripe purchases written to Firestore.
    static func getDoc(path: String) async throws -> [String: Any]? {
        let url = baseURL.appendingPathComponent(path)
        var req = try await authedRequest(url, method: "GET")
        req.httpBody = nil
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw FirebaseRESTError.decode }
        if http.statusCode == 404 { return nil }
        guard (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let fields = json["fields"] as? [String: Any] else { return nil }
        return decodeFields(fields)
    }

    /// List documents in a collection ordered by a single field.
    /// `orderBy` "createdAt DESC" → returns newest first.
    /// Set `requireAuth=false` to allow this from non-signed-in users —
    /// works only when Firestore rules permit public read on that
    /// collection (currently /posts and /spots).
    static func listDocs(in collection: String, limit: Int = 50,
                         orderByField: String? = nil, descending: Bool = true,
                         requireAuth: Bool = true) async throws -> [(id: String, data: [String: Any])] {
        var components = URLComponents(url: baseURL.appendingPathComponent(collection), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = [URLQueryItem(name: "pageSize", value: String(limit))]
        if let f = orderByField {
            items.append(URLQueryItem(name: "orderBy", value: "\(f) \(descending ? "desc" : "asc")"))
        }
        components.queryItems = items

        var req = try await authedRequest(components.url!, method: "GET", requireAuth: requireAuth)
        req.httpBody = nil

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0,
                                         String(data: data, encoding: .utf8) ?? "")
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        let docs = (json["documents"] as? [[String: Any]]) ?? []
        return docs.compactMap { doc in
            guard let name = doc["name"] as? String,
                  let fields = doc["fields"] as? [String: Any] else { return nil }
            return (id: name.components(separatedBy: "/").last ?? "",
                    data: decodeFields(fields))
        }
    }

    /// Run a structured query — supports a single field-equals filter.
    /// This is what we MUST use for "list my scans" because Firestore
    /// security rules require the query to be statically provable as
    /// matching only the user's docs (i.e. the filter must be present).
    static func queryDocs(
        collection: String,
        whereField: String,
        equalToString: String,
        orderByField: String? = nil,
        descending: Bool = true,
        limit: Int = 100,
    ) async throws -> [(id: String, data: [String: Any])] {
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents:runQuery")!
        var req = try await authedRequest(url, method: "POST")

        var structuredQuery: [String: Any] = [
            "from": [["collectionId": collection]],
            "where": [
                "fieldFilter": [
                    "field": ["fieldPath": whereField],
                    "op": "EQUAL",
                    "value": ["stringValue": equalToString],
                ],
            ],
            "limit": limit,
        ]
        if let f = orderByField {
            structuredQuery["orderBy"] = [[
                "field": ["fieldPath": f],
                "direction": descending ? "DESCENDING" : "ASCENDING",
            ]]
        }

        req.httpBody = try JSONSerialization.data(withJSONObject: ["structuredQuery": structuredQuery])

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0,
                                         String(data: data, encoding: .utf8) ?? "")
        }
        // runQuery returns an ARRAY of { document?: {...} } entries
        guard let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return arr.compactMap { entry in
            guard let doc = entry["document"] as? [String: Any],
                  let name = doc["name"] as? String,
                  let fields = doc["fields"] as? [String: Any] else { return nil }
            return (id: name.components(separatedBy: "/").last ?? "",
                    data: decodeFields(fields))
        }
    }

    /// Delete a document.
    static func deleteDoc(path: String) async throws {
        let url = baseURL.appendingPathComponent(path)
        let req = try await authedRequest(url, method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0, "")
        }
    }
}

// MARK: - Firebase Storage REST

enum StorageREST {
    /// Uploads `data` to Firebase Storage at the given path. Returns a
    /// public download URL.
    static func upload(data: Data, to path: String, contentType: String = "image/jpeg") async throws -> URL {
        guard let token = try? await Auth.auth().currentUser?.getIDToken() else {
            throw FirebaseRESTError.notSignedIn
        }
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/\(storageBucket)/o?uploadType=media&name=\(encoded)")!

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpBody = data

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FirebaseRESTError.http((response as? HTTPURLResponse)?.statusCode ?? 0,
                                         String(data: respData, encoding: .utf8) ?? "")
        }
        guard let json = try JSONSerialization.jsonObject(with: respData) as? [String: Any],
              let downloadTokens = (json["downloadTokens"] as? String)?.components(separatedBy: ",").first,
              let name = json["name"] as? String else {
            throw FirebaseRESTError.decode
        }
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .init(charactersIn: "-_.~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")) ?? name
        let urlStr = "https://firebasestorage.googleapis.com/v0/b/\(storageBucket)/o/\(encodedName)?alt=media&token=\(downloadTokens)"
        guard let downloadURL = URL(string: urlStr) else {
            throw FirebaseRESTError.decode
        }
        return downloadURL
    }
}
