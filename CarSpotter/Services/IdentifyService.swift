import Foundation
import UIKit

@MainActor
final class IdentifyService: ObservableObject {

    enum Stage: String, CaseIterable {
        case detecting   = "Detecting body shape…"
        case matching    = "Matching grille + headlights…"
        case crossref    = "Cross-referencing 500k models…"
        case market      = "Pulling market data…"
        case done        = ""
    }

    @Published var stage: Stage = .detecting
    @Published var progress: Double = 0
    @Published var result: CarInfo?
    @Published var error: String?
    @Published var isRunning: Bool = false

    /// High-quality client-side optimizer — caps the longest side at 3072px
    /// and re-encodes at 95% JPEG. Empirically the sweet spot for Claude
    /// vision: enough detail for badge/grille/wheel ID, still under 5MB.
    func optimize(_ image: UIImage) -> Data? {
        // Apply EXIF orientation FIRST — Claude's vision doesn't auto-rotate,
        // so a sideways phone photo becomes a sideways model input.
        let oriented = image.fixedOrientation()
        let maxDim: CGFloat = 3072
        let scale = max(oriented.size.width, oriented.size.height) > maxDim
            ? maxDim / max(oriented.size.width, oriented.size.height)
            : 1
        let newSize = CGSize(
            width: oriented.size.width * scale,
            height: oriented.size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            oriented.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.95)
    }

    /// Run the identification flow — animates the staged loader while the
    /// network request is in-flight.
    func identify(_ image: UIImage) async {
        guard !isRunning else { return }
        guard let data = optimize(image) else {
            error = "Couldn't process that image."
            return
        }

        isRunning = true
        error = nil
        result = nil
        progress = 0
        stage = .detecting

        // Kick off the staged progress animation in parallel with the request.
        Task { @MainActor in
            for (i, s) in Stage.allCases.dropLast().enumerated() {
                try? await Task.sleep(nanoseconds: 600_000_000)
                if !isRunning { return }
                stage = s
                progress = Double(i + 1) / Double(Stage.allCases.count - 1)
            }
        }

        do {
            let body = [
                "image": "data:image/jpeg;base64,\(data.base64EncodedString())",
                "mimeType": "image/jpeg",
            ]
            var req = URLRequest(url: API.url(.carInfo))
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (resp, http) = try await URLSession.shared.data(for: req)
            guard let httpResp = http as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            if httpResp.statusCode == 402 {
                throw APIError.paywall
            }
            guard (200..<300).contains(httpResp.statusCode) else {
                let txt = String(data: resp, encoding: .utf8) ?? ""
                throw APIError.http(httpResp.statusCode, txt)
            }

            struct Envelope: Decodable { let result: CarInfo }
            let env = try JSONDecoder().decode(Envelope.self, from: resp)
            var enriched = env.result
            enriched.imageData = data
            enriched.spottedAt = .init()

            progress = 1.0
            stage = .done
            result = enriched
        } catch {
            self.error = error.localizedDescription
        }

        isRunning = false
    }
}
