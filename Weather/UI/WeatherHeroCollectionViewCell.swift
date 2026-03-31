import UIKit

final class WeatherHeroCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "WeatherHeroCollectionViewCell"

    private let heroView = WeatherHeroSectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(heroView)

        NSLayoutConstraint.activate([
            heroView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: WeatherHeroViewData) {
        heroView.configure(with: viewData)
    }
}
