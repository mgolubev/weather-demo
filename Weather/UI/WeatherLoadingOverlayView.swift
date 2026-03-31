import UIKit

@MainActor
final class WeatherLoadingOverlayView: UIView {
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.16)
        configureContent()
        setVisible(false)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setVisible(_ isVisible: Bool) {
        isHidden = !isVisible

        if isVisible {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    private func configureContent() {
        let card = UIView()
        WeatherUIStyle.applyOverlayCardStyle(to: card)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white

        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.font = .systemFont(ofSize: 17, weight: .medium)
        loadingLabel.textColor = .white
        loadingLabel.text = "Получаем погоду"

        card.addSubview(loadingIndicator)
        card.addSubview(loadingLabel)
        addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),

            loadingIndicator.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            loadingIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            loadingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            loadingLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }
}
