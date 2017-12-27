//
//  ImageCell.swift
//  Exa_Swift
//
//  Created by Juan on 25/12/17.
//  Copyright © 2017 Arkos. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    let showCaseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ico_restaurant")
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews(){
        
        //backgroundColor = UIColor.black
        
        addSubview(nameLabel)
        addSubview(showCaseImageView)
        
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0/3.0).isActive = true
        
        showCaseImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        showCaseImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        showCaseImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        showCaseImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0).isActive = true

    }
}
