//
//  UIOkoProfileSettingButton.swift
//  Oko Future
//
//  Created by Денис Калинин on 14.06.23.
//

import UIKit

public enum SizeOkoProfileSettingButton {
    case big, small
}

final class UIOkoProfileSettingButton: UIView {
    
    var imageView = UIImageView()
    var label = UILabel()
    
    var tapGesture = UITapGestureRecognizer()
    var control = UIControl()
    
    override var frame: CGRect {
        didSet {
            layer.cornerRadius = 24
            setupLayout()
        }
    }
    
    init(size: SizeOkoProfileSettingButton) {
        
        switch size {
        case .big: super.init(frame: CGRect(x: 0, y: 0, width: 335, height: 96))
        case .small: super.init(frame: CGRect(x: 0, y: 0, width: 164, height: 96))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureView(image: UIImage, text: String, tapGesture: UITapGestureRecognizer) {
        self.imageView.image = image
        self.label.text = text
        self.label.textColor = .white
        self.tapGesture = tapGesture
        
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        self.addSubview(imageView)
        self.addSubview(label)
        self.addGestureRecognizer(tapGesture)
        
        self.backgroundColor = Helper().backgroundColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = Helper().borderColor()
    }
    
    private func setupLayout() {
        self.imageView.frame = CGRect(x: 16, y: 16, width: 24, height: 24)
        self.label.frame = CGRect(x: 16, y: 56, width: self.frame.width, height: 24)
    }
}
