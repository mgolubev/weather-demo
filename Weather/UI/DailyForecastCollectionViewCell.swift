import UIKit

@MainActor
final class DailyForecastCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "DailyForecastCollectionViewCell"

    private let rowView = DailyForecastRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(rowView)

        NSLayoutConstraint.activate([
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: DailyForecastItemViewData) {
        rowView.configure(with: viewData)
    }
}
