//
//  OkoBigButton.swift
//  Oko Future
//
//  Created by Денис Калинин on 22.05.23.
//

import UIKit

final class OkoBigButton: UIButton {
    
    override var frame: CGRect {
        didSet {
            layer.cornerRadius = bounds.size.height / 2.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(.white, for: .normal)
        backgroundColor = .black
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
