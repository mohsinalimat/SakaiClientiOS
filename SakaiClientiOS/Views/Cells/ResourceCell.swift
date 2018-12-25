//
//  ResourceCell.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/28/18.
//

import UIKit
import ReusableSource

/// A cell to display a Resource collection or element
class ResourceCell: UITableViewCell, ReusableCell {
    typealias T = ResourceItem

    let titleLabel: InsetUILabel = {
        let titleLabel: InsetUILabel = UIView.defaultAutoLayoutView()
        titleLabel.textColor = UIColor.lightText
        titleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.light)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.backgroundColor = UIColor.clear
        return titleLabel
    }()

    let leftBorder: UIView = UIView.defaultAutoLayoutView()

    let sizeLabel: UILabel = {
        let sizeLabel: UILabel = UIView.defaultAutoLayoutView()
        sizeLabel.backgroundColor = UIColor.lightGray
        sizeLabel.textAlignment = .center
        sizeLabel.textColor = UIColor.white
        sizeLabel.layer.masksToBounds = true
        return sizeLabel
    }()

    let spaceView: UIView = UIView.defaultAutoLayoutView()

    var needsSizeLabel = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.darkGray
        selectedBackgroundView = darkSelectedView()

        contentView.addSubview(titleLabel)
        contentView.addSubview(leftBorder)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(spaceView)
    }

    private func setConstraints() {
        let margins = contentView.layoutMarginsGuide

        leftBorder.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        leftBorder.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        leftBorder.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        leftBorder.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        leftBorder.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.015).isActive = true

        titleLabel.trailingAnchor.constraint(equalTo: sizeLabel.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true

        sizeLabel.trailingAnchor.constraint(equalTo: spaceView.leadingAnchor).isActive = true
        sizeLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        sizeLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        sizeLabel.widthAnchor.constraint(equalTo: sizeLabel.heightAnchor).isActive = true

        spaceView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        spaceView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        spaceView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }

    func configure(_ item: ResourceItem, at level: Int, isExpanded: Bool) {
        titleLabel.titleLabel.text = item.title
        leftBorder.backgroundColor = getColor(for: level)
        let left = CGFloat(level == 0 ? 0 : level * 20 + 10)
        contentView.layoutMargins.left = left
        switch item.type {
        case .collection:
            selectionStyle = .none
            accessoryType = .none
            sizeLabel.text = String(item.numChildren)
            sizeLabel.isHidden = false
            if isExpanded {
                sizeLabel.backgroundColor = getColor(for: level)
            } else {
                sizeLabel.backgroundColor = UIColor.lightGray
            }
            break
        case .resource:
            selectionStyle = .default
            accessoryType = .disclosureIndicator
            sizeLabel.isHidden = true
            break
        }
        layoutSubviews()
    }

    private func getColor(for level: Int) -> UIColor {
        let mod = level % 4
        switch mod {
        case 0:
            return UIColor(red: 199.0 / 256.0, green: 26.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
        case 1:
            return UIColor(red: 199.0 / 256.0, green: 66.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
        case 2:
            return UIColor(red: 199.0 / 256.0, green: 104.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
        case 3:
            return UIColor(red: 199.0 / 256.0, green: 142.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
        default:
            return UIColor.black
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutSubviews()
        sizeLabel.layer.cornerRadius = sizeLabel.bounds.size.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sizeLabel.backgroundColor = UIColor.lightGray
    }
}
