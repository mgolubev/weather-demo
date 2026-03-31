import UIKit

final class HourlyForecastSectionView: UIView {
    private var items: [HourlyForecastItemViewData] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 92, height: 132)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        WeatherUIStyle.applySectionCardStyle(to: self)
        configureContent()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setItems(_ items: [HourlyForecastItemViewData]) {
        self.items = items
        collectionView.reloadData()
    }

    private func configureContent() {
        let titleLabel = WeatherUIStyle.makeSectionTitleLabel(text: "По часам")

        collectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier)
        collectionView.dataSource = self

        addSubview(titleLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 132)
        ])
    }
}

extension HourlyForecastSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourlyForecastCell.reuseIdentifier,
            for: indexPath
        ) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: items[indexPath.item])
        return cell
    }
}
