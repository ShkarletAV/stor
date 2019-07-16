//
//  IBDesignableButton.swift
//  PoliDash
//
//  Created by David Minasyan on 19.07.2018.
//  Copyright © 2018 David Minasyan. All rights reserved.
//

import UIKit

@IBDesignable class IBDesignableButton: UIButton {

    @IBInspectable var borderW: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderW
        }
    }
    
    @IBInspectable var borderC: UIColor = .clear {
        didSet{
            self.layer.borderColor = borderC.cgColor
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 0.0 {
        didSet{
            self.layer.cornerRadius = borderRadius
        }
    }
    
    @IBInspectable var shadowOfet: CGSize = CGSize(){
        didSet{
            self.layer.shadowOffset = shadowOfet
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.0{
        didSet{
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0{
        didSet{
            self.layer.shadowRadius = shadowRadius
        }
    }
    @IBInspectable var shadowColor: UIColor = .clear{
        didSet{
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
}
