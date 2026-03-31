import UIKit

final class GradientBackgroundView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        guard let layer = layer as? CAGradientLayer else {
            return CAGradientLayer()
        }
        return layer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyTheme(isDay: true)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func applyTheme(isDay: Bool) {
        gradientLayer.startPoint = CGPoint(x: 0.15, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.85, y: 1.0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.colors = isDay ? [
            UIColor(red: 0.11, green: 0.43, blue: 0.86, alpha: 1).cgColor,
            UIColor(red: 0.29, green: 0.66, blue: 0.93, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.89, blue: 0.99, alpha: 1).cgColor
        ] : [
            UIColor(red: 0.05, green: 0.10, blue: 0.24, alpha: 1).cgColor,
            UIColor(red: 0.10, green: 0.18, blue: 0.39, alpha: 1).cgColor,
            UIColor(red: 0.21, green: 0.30, blue: 0.55, alpha: 1).cgColor
        ]
    }
}
