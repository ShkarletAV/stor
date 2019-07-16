//
//  RoundedImage.swift
//  PoliDash
//
//  Created by David Minasyan on 20.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import Foundation
import UIKit

class RoundedUIImageView: UIImageView {
    @IBInspectable var round: Bool = true {
        didSet { self.setNeedsLayout() }
    }
    
    @IBInspectable var width: CGFloat = 2.5 {
        didSet { self.setNeedsLayout() }
    }
    
    
    @IBInspectable var color: UIColor = .black {
        didSet { self.setNeedsLayout()
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        
        if round {
            self.layer.cornerRadius = self.frame.width / 2
        } else {
            self.layer.cornerRadius = 0
        }
        
        self.layer.borderWidth = self.width
        self.layer.borderColor = self.color.cgColor
    }
}
