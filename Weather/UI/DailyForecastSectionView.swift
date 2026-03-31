import UIKit

final class DailyForecastSectionView: UIView {
    private let dailyStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        WeatherUIStyle.applySectionCardStyle(to: self)
        configureContent()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setItems(_ items: [DailyForecastItemViewData]) {
        dailyStack.arrangedSubviews.forEach {
            dailyStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach { item in
            let row = DailyForecastRowView()
            row.configure(with: item)
            dailyStack.addArrangedSubview(row)
        }
    }

    private func configureContent() {
        let titleLabel = WeatherUIStyle.makeSectionTitleLabel(text: "Прогноз на 3 дня")

        dailyStack.translatesAutoresizingMaskIntoConstraints = false
        dailyStack.axis = .vertical
        dailyStack.spacing = 12

        addSubview(titleLabel)
        addSubview(dailyStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            dailyStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dailyStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dailyStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dailyStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
