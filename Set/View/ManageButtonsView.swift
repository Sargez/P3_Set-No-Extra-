//
//  ManageButtons.swift
//  Set
//
//  Created by 1C on 30/04/2022.
//

import UIKit

@IBDesignable
class ManageButtonsView: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable
    var cornerRadius: CGFloat = CGFloat(ManageButtonsConstants.cornerRadius)  {didSet {setNeedsLayout()}}

    @IBInspectable
    var borderWidth: CGFloat = CGFloat(ManageButtonsConstants.borderWidth) {didSet {setNeedsLayout()}}
    
    @IBInspectable
    var color: CGColor = ManageButtonsConstants.boderColor {didSet {setNeedsLayout()}}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = color
//        frame.size = CGSize.zero
//        sizeToFit()
    }
  
    private struct ManageButtonsConstants {
        static let borderWidth = 2.0
        static let cornerRadius = 8.0
        static let boderColor = UIColor.yellow.cgColor
    
    }
    
}
