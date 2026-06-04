import UIKit

extension UIImage {
    /// Returns a copy with `imageOrientation = .up`, baking the EXIF
    /// rotation into the actual pixels. Critical for vision APIs that
    /// don't read the EXIF tag.
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}
