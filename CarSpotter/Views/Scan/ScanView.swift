import SwiftUI
import PhotosUI

struct ScanView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var identify = IdentifyService()
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()
                // Hero glow
                RadialGradient(
                    colors: [.spotterCyan.opacity(0.18), .clear],
                    center: .top, startRadius: 10, endRadius: 400
                ).ignoresSafeArea()

                if let result = identify.result {
                    ResultCardView(car: result, onScanAnother: { identify.result = nil })
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else if identify.isRunning {
                    ScanProgressView(stage: identify.stage, progress: identify.progress)
                } else {
                    landingState
                }

                if let err = identify.error {
                    VStack {
                        Spacer()
                        Text(err)
                            .padding(12)
                            .background(.red.opacity(0.85))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 24)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    BrandWordmark(size: 16)
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker { image in
                    Task { await identify.identify(image) }
                }
                .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    Task { await identify.identify(image) }
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .animation(.easeOut(duration: 0.35), value: identify.result)
        .animation(.easeOut, value: identify.isRunning)
    }

    private var landingState: some View {
        VStack(spacing: 24) {
            Spacer()
            BrandLogo(size: 86)

            VStack(spacing: 10) {
                Text("Snap any car.")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Know everything.")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient.spotterBrand)
            }

            Text("Make, model, year, MSRP, today's value,\nrarity, celebrity owners, fun facts — in 2s.")
                .multilineTextAlignment(.center)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.spotterMute)
                .padding(.horizontal, 30)

            Spacer()

            VStack(spacing: 12) {
                GradientButton(title: "Open camera", icon: "camera.fill") {
                    showCamera = true
                }
                GradientButton(title: "Upload from library", icon: "photo.on.rectangle", style: .ghost) {
                    showPhotoPicker = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

struct ScanProgressView: View {
    let stage: IdentifyService.Stage
    let progress: Double

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 4)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(LinearGradient.spotterBrand, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "camera.metering.matrix")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(LinearGradient.spotterBrand)
            }
            .animation(.easeOut(duration: 0.4), value: progress)

            Text("IDENTIFYING")
                .font(.spotterLabel)
                .tracking(3)
                .foregroundStyle(Color.spotterMute)

            Text(stage.rawValue)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.opacity)

            Spacer()
        }
        .padding(40)
    }
}

#Preview { ScanView().environmentObject(AuthService.preview) }
