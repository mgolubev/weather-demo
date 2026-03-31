import UIKit

final class WeatherDetailsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "WeatherDetailsCollectionViewCell"

    private let detailsView = WeatherDetailsSectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(detailsView)

        NSLayoutConstraint.activate([
            detailsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: WeatherDetailsViewData) {
        detailsView.configure(with: viewData)
    }
}
