//
//  OkoDefaultButton.swift
//  Oko Future
//
//  Created by Денис Калинин on 23.04.23.
//

import UIKit

final class OkoDefaultButton: UIButton {
    
    override var frame: CGRect {
        didSet {
            layer.cornerRadius = bounds.size.width / 2.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(.white, for: .normal)
        backgroundColor = Helper().backgroundColor()
        layer.borderWidth = 1
        layer.borderColor = Helper().borderColor()
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
