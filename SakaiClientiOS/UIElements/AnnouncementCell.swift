//
//  AnnouncmentCell.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/30/18.
//

import UIKit

class AnnouncementCell: UITableViewCell {
    
    static let reuseIdentifier:String = "announcementCell"
    
    ///The UILabel containing the title text
    var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    ///Setup subviews, add them to superview, and set constraints
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        addViews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///Setup subviews
    func setup() {
        //Instantiate titleLabel and set attributes
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.light)
    }
    
    ///Add subviews to self
    func addViews() {
        self.contentView.addSubview(titleLabel)
    }
    
    ///Set constraints of titleLabel
    func setConstraints() {
        let margins = self.contentView.layoutMarginsGuide
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Constrain titleLabel to top, bottom, left, and right anchors
        titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 20.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 1.0).isActive = true
    }
    
    
    /// Set titleLabel tect
    ///
    /// - Parameter title: String to assign to titleLabel.text
    func setTitle(title: String?) {
        titleLabel.text = title
    }
    
}