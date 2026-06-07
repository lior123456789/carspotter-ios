import SwiftUI

// MARK: - Model

/// Decoded plate response from the CarsXE proxy (carsspotter.com/api/plate-decode).
/// Fields vary by country, so everything is optional.
struct PlateResult: Decodable {
    var success: Bool?
    var error: String?
    var description: String?
    var make: String?
    var model: String?
    var trim: String?
    var year: String?
    var registrationYear: String?
    var vin: String?
    var bodyStyle: String?
    var style: String?
    var fuelType: String?
    var color: String?
    var engine: String?
    var engineSize: String?
    var transmission: String?
    var driveType: String?
    var assembly: String?

    enum CodingKeys: String, CodingKey {
        case success, error, description, make, model, trim, year, vin, style, color, engine, assembly
        case registrationYear = "registration_year"
        case bodyStyle = "body_style"
        case fuelType = "fuel_type"
        case engineSize = "engine_size"
        case transmission
        case driveType = "drive_type"
    }

    var displayYear: String { year ?? registrationYear ?? "" }
    var title: String {
        let mk = [make, model].compactMap { $0 }.joined(separator: " ")
        return mk.isEmpty ? (description ?? "Unknown vehicle") : mk
    }
}

// MARK: - Service

@MainActor
final class PlateDecoderModel: ObservableObject {
    @Published var plate = ""
    @Published var state = ""
    @Published var isLoading = false
    @Published var result: PlateResult?
    @Published var errorMessage: String?

    func decode() async {
        let p = plate.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let st = state.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !p.isEmpty else { errorMessage = "Enter a plate number."; return }
        guard st.count == 2 else { errorMessage = "Enter the 2-letter state (e.g. CA)."; return }

        isLoading = true; errorMessage = nil; result = nil
        defer { isLoading = false }

        var comps = URLComponents(url: API.url(.plateDecode), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "plate", value: p),
            URLQueryItem(name: "state", value: st),
            URLQueryItem(name: "country", value: "US"),
        ]
        do {
            let (data, response) = try await URLSession.shared.data(from: comps.url!)
            let decoded = try JSONDecoder().decode(PlateResult.self, from: data)
            if decoded.success == false || (response as? HTTPURLResponse)?.statusCode ?? 200 >= 400 {
                errorMessage = decoded.error ?? "No match found for that plate."
                return
            }
            result = decoded
        } catch {
            errorMessage = "Lookup failed. Check the plate and try again."
        }
    }
}

// MARK: - View

struct PlateDecoderView: View {
    @StateObject private var vm = PlateDecoderModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter a US license plate to pull the make, model, year, VIN and full specs.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.spotterMute)

                    HStack(spacing: 12) {
                        field("PLATE", text: $vm.plate, placeholder: "7XER187", width: nil)
                        field("STATE", text: $vm.state, placeholder: "CA", width: 90)
                    }

                    GradientButton(title: "Decode plate", icon: "magnifyingglass", loading: vm.isLoading) {
                        Task { await vm.decode() }
                    }

                    if let err = vm.errorMessage {
                        Text(err).font(.system(size: 13, design: .rounded)).foregroundStyle(.red)
                    }

                    if let r = vm.result {
                        resultCard(r)
                    }
                }
                .padding(20)
            }
            .background(Color.spotterInk.ignoresSafeArea())
            .navigationTitle("Plate Decoder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }.foregroundStyle(Color.spotterMute)
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String, width: CGFloat?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.spotterLabel)
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.spotterMute))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.spotterPanel)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: width)
        }
    }

    private func resultCard(_ r: PlateResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if !r.displayYear.isEmpty {
                    Text(r.displayYear).font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.spotterMute)
                }
                Text(r.title).font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white).lineLimit(2).minimumScaleFactor(0.7)
            }
            if let t = r.trim, !t.isEmpty {
                Text(t).font(.system(size: 14, design: .rounded)).foregroundStyle(Color.spotterCyan)
            }
            Rectangle().fill(Color.spotterLine).frame(height: 1)
            specRow("VIN", r.vin)
            specRow("Body", r.bodyStyle ?? r.style)
            specRow("Engine", r.engine ?? r.engineSize)
            specRow("Fuel", r.fuelType)
            specRow("Drive", r.driveType)
            specRow("Transmission", r.transmission)
            specRow("Color", r.color)
            specRow("Assembly", r.assembly)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterPanel)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.spotterLine))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder private func specRow(_ label: String, _ value: String?) -> some View {
        if let v = value, !v.isEmpty {
            HStack(alignment: .top) {
                Text(label.uppercased()).font(.spotterLabel).frame(width: 110, alignment: .leading)
                Text(v).font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white).frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview { PlateDecoderView() }
