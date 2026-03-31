import UIKit

final class HourlyForecastCell: UICollectionViewCell {
    static let reuseIdentifier = "HourlyForecastCell"

    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let temperatureLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        contentView.layer.cornerRadius = 22
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.80)
        timeLabel.textAlignment = .center

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)

        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center

        contentView.addSubview(timeLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(temperatureLabel)

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 14),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 14),
            temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            temperatureLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: HourlyForecastItemViewData) {
        timeLabel.text = viewData.timeText
        iconImageView.image = UIImage(systemName: viewData.symbolName)
        temperatureLabel.text = viewData.temperatureText
    }
}
