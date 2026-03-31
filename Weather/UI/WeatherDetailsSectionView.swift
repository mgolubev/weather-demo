import UIKit

@MainActor
final class WeatherDetailsSectionView: UIView {
    private let feelsLikeTile = StatTileView(title: "Ощущается как")
    private let windTile = StatTileView(title: "Ветер")
    private let humidityTile = StatTileView(title: "Влажность")
    private let uvTile = StatTileView(title: "UV")

    override init(frame: CGRect) {
        super.init(frame: frame)
        WeatherUIStyle.applySectionCardStyle(to: self)
        configureContent()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with viewData: WeatherDetailsViewData) {
        feelsLikeTile.configure(value: viewData.feelsLikeText)
        windTile.configure(value: viewData.windText)
        humidityTile.configure(value: viewData.humidityText)
        uvTile.configure(value: viewData.uvText)
    }

    private func configureContent() {
        let titleLabel = WeatherUIStyle.makeSectionTitleLabel(text: "Подробности")

        let firstRow = UIStackView(arrangedSubviews: [feelsLikeTile, windTile])
        firstRow.axis = .horizontal
        firstRow.spacing = 12
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView(arrangedSubviews: [humidityTile, uvTile])
        secondRow.axis = .horizontal
        secondRow.spacing = 12
        secondRow.distribution = .fillEqually

        let gridStack = UIStackView(arrangedSubviews: [firstRow, secondRow])
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 12

        addSubview(titleLabel)
        addSubview(gridStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            gridStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
