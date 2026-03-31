import UIKit

final class WeatherHeroSectionView: UIView {
    private let locationLabel = UILabel()
    private let metaLabel = UILabel()
    private let currentIconView = UIImageView()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let rangeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        WeatherUIStyle.applySectionCardStyle(to: self)
        configureContent()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: WeatherHeroViewData) {
        locationLabel.text = viewData.locationText
        metaLabel.text = viewData.metaText
        currentIconView.image = UIImage(systemName: viewData.currentSymbolName)
        temperatureLabel.text = viewData.temperatureText
        conditionLabel.text = viewData.conditionText
        rangeLabel.text = viewData.rangeText
    }

    private func configureContent() {
        let stack = UIStackView(arrangedSubviews: [
            locationLabel,
            metaLabel,
            currentIconView,
            temperatureLabel,
            conditionLabel,
            rangeLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center

        locationLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        locationLabel.textColor = .white
        locationLabel.textAlignment = .center

        metaLabel.font = .systemFont(ofSize: 15, weight: .medium)
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        metaLabel.textAlignment = .center

        currentIconView.tintColor = .white
        currentIconView.contentMode = .scaleAspectFit
        currentIconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 68, weight: .regular)
        currentIconView.translatesAutoresizingMaskIntoConstraints = false

        temperatureLabel.font = .monospacedDigitSystemFont(ofSize: 78, weight: .light)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center

        conditionLabel.font = .systemFont(ofSize: 22, weight: .medium)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center

        rangeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        rangeLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        rangeLabel.textAlignment = .center

        addSubview(stack)

        NSLayoutConstraint.activate([
            currentIconView.widthAnchor.constraint(equalToConstant: 82),
            currentIconView.heightAnchor.constraint(equalToConstant: 82),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28)
        ])
    }
}
