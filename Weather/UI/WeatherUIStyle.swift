import UIKit

@MainActor
enum WeatherUIStyle {
    static func applySectionCardStyle(to view: UIView) {
        applyGlassStyle(
            to: view,
            backgroundAlpha: 0.14,
            borderAlpha: 0.12,
            cornerRadius: 30
        )
    }

    static func applyOverlayCardStyle(to view: UIView) {
        applyGlassStyle(
            to: view,
            backgroundAlpha: 0.14,
            borderAlpha: 0.12,
            cornerRadius: 28
        )
    }

    static func makeSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.text = text
        return label
    }

    private static func applyGlassStyle(
        to view: UIView,
        backgroundAlpha: CGFloat,
        borderAlpha: CGFloat,
        cornerRadius: CGFloat
    ) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(backgroundAlpha)
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(borderAlpha).cgColor
    }
}
