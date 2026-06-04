import SwiftUI

/// Sheet shown after a successful scan — lets the user share to the feed.
struct ComposePostView: View {
    let car: CarInfo
    @StateObject private var feed = FeedService()
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var location = ""
    @State private var busy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Photo preview
                    if let data = car.imageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    // Car identity strip
                    HStack(spacing: 10) {
                        BadgePill(label: car.category, color: .spotterCyan)
                        BadgePill(label: "Rarity \(car.rarity)/10",
                                  icon: "trophy.fill", color: .yellow)
                    }
                    Text("\(car.year) \(car.make) \(car.model)")
                        .font(.spotterTitle)
                        .foregroundStyle(.white)
                    Text(car.valueRange)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LinearGradient.spotterBrand)

                    Divider().background(Color.spotterLine)

                    // Caption
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CAPTION").font(.spotterLabel)
                        TextField("", text: $caption, prompt:
                                    Text("Say something about this spot…")
                                        .foregroundColor(.spotterMute),
                                  axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color.spotterPanel)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LOCATION (OPTIONAL)").font(.spotterLabel)
                        TextField("", text: $location, prompt:
                                    Text("Rodeo Drive, LA").foregroundColor(.spotterMute))
                            .padding(12)
                            .background(Color.spotterPanel)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spotterLine))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }

                    if let err = feed.error {
                        Text(err).font(.system(size: 13)).foregroundStyle(.red)
                    }

                    GradientButton(title: "Share to feed", icon: "paperplane.fill", loading: busy) {
                        Task {
                            busy = true
                            do {
                                guard let data = car.imageData else {
                                    feed.error = "Photo data missing."
                                    busy = false
                                    return
                                }
                                try await feed.createPost(
                                    imageData: data,
                                    car: car,
                                    caption: caption,
                                    location: location.isEmpty ? nil : location
                                )
                                dismiss()
                            } catch {
                                feed.error = error.localizedDescription
                            }
                            busy = false
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.spotterInk.ignoresSafeArea())
            .navigationTitle("Share spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.spotterMute)
                }
            }
        }
    }
}
