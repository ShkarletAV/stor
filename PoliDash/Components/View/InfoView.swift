//
//  InfoView.swift
//  PoliDash
//
//  Created by olya on 17/07/2019.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
    
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(title: String,
         subtitle: String,
         image: UIImage?) {
        super.init(frame: CGRect.zero)
        self.titleLabel.text = title
        self.imageView.image = image
        self.subtitleLabel.text = subtitle
        commonInit()
    }
    
    func commonInit() {
        self.addSubview(titleLabel)
        self.addSubview(imageView)
        self.addSubview(subtitleLabel)
        self.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 4),
            
            imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 4),
            subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 4),
        ])
    }
}
