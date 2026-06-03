import SwiftUI

struct BrandLogo: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(LinearGradient.spotterBrand)

            // camera body silhouette
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .padding(size * 0.18)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: .spotterCyan.opacity(0.5), radius: size * 0.25, x: 0, y: size * 0.1)
    }
}

struct BrandWordmark: View {
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: 8) {
            BrandLogo(size: size + 8)
            Text("CarSpotter")
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .tracking(-0.3)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BrandLogo(size: 40)
        BrandLogo(size: 64)
        BrandWordmark()
    }
    .padding(40)
    .background(Color.spotterInk)
}
