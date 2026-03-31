import UIKit

final class WeatherErrorOverlayView: UIView {
    var onRetry: (() -> Void)?

    private let errorTitleLabel = UILabel()
    private let errorMessageLabel = UILabel()
    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = UIColor(red: 0.07, green: 0.22, blue: 0.48, alpha: 1)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 22, bottom: 12, trailing: 22)
        configuration.title = "Повторить"

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [weak self] _ in
                self?.onRetry?()
            },
            for: .touchUpInside
        )
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.20)
        configureContent()
        setVisible(false)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: WeatherErrorViewData) {
        errorTitleLabel.text = viewData.title
        errorMessageLabel.text = viewData.message

        var configuration = retryButton.configuration
        configuration?.title = viewData.buttonTitle
        retryButton.configuration = configuration
    }

    func setVisible(_ isVisible: Bool) {
        isHidden = !isVisible
    }

    private func configureContent() {
        let card = UIView()
        WeatherUIStyle.applyOverlayCardStyle(to: card)

        errorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorTitleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        errorTitleLabel.textColor = .white
        errorTitleLabel.textAlignment = .center
        errorTitleLabel.numberOfLines = 0

        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        errorMessageLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0

        card.addSubview(errorTitleLabel)
        card.addSubview(errorMessageLabel)
        card.addSubview(retryButton)
        addSubview(card)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            errorTitleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            errorTitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            errorTitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            errorMessageLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 12),
            errorMessageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            errorMessageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 22),
            retryButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28)
        ])
    }
}
