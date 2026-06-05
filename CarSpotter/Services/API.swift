import Foundation

enum API {
    /// Always use the live production API on `carsspotter.com`.
    /// (Was using `carsspotter.app` and `localhost` in DEBUG — both
    /// caused "Could not connect to the server" on a real iPhone.)
    static let baseURL = URL(string: "https://carsspotter.com")!

    enum Endpoint: String {
        case carInfo = "/api/car-info"
        case identify = "/api/identify"
        case spots = "/api/spots"
        case usage = "/api/usage"
        case me = "/api/me"
        case authSync = "/api/auth/sync"
    }

    static func url(_ endpoint: Endpoint) -> URL {
        baseURL.appendingPathComponent(endpoint.rawValue.dropFirst().description)
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case http(Int, String)
    case paywall
    case decode(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:   return "The server returned an unexpected response."
        case .http(let c, _):    return "Request failed (\(c))."
        case .paywall:           return "Free trial used up — upgrade to keep scanning."
        case .decode(let e):     return "Couldn't read the response. \(e.localizedDescription)"
        }
    }
}
