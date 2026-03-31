import UIKit

final class DailyForecastRowView: UIView {
    private let dayLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let iconImageView = UIImageView()
    private let temperaturesLabel = UILabel()
    private let rainChanceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.10)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor

        let titleStack = UIStackView(arrangedSubviews: [dayLabel, descriptionLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 4

        dayLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        dayLabel.textColor = .white

        descriptionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.75)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)

        temperaturesLabel.translatesAutoresizingMaskIntoConstraints = false
        temperaturesLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        temperaturesLabel.textColor = .white
        temperaturesLabel.textAlignment = .right

        rainChanceLabel.translatesAutoresizingMaskIntoConstraints = false
        rainChanceLabel.font = .systemFont(ofSize: 13, weight: .medium)
        rainChanceLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        rainChanceLabel.textAlignment = .right

        let trailingStack = UIStackView(arrangedSubviews: [temperaturesLabel, rainChanceLabel])
        trailingStack.translatesAutoresizingMaskIntoConstraints = false
        trailingStack.axis = .vertical
        trailingStack.spacing = 4
        trailingStack.alignment = .trailing

        addSubview(titleStack)
        addSubview(iconImageView)
        addSubview(trailingStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 88),

            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleStack.trailingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            trailingStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 14),
            trailingStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            trailingStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: DailyForecastItemViewData) {
        dayLabel.text = viewData.dayText
        descriptionLabel.text = viewData.descriptionText
        temperaturesLabel.text = viewData.temperaturesText
        rainChanceLabel.text = viewData.rainChanceText
        iconImageView.image = UIImage(systemName: viewData.symbolName)
    }
}
