//
//  UIOkoLoginButton.swift
//  Oko Future
//
//  Created by Денис Калинин on 24.06.23.
//

import UIKit

enum TypeLoginButton {
    case google, apple
}

final class UIOkoLoginButton: UIView {
    
    private var imageView: UIImageView
    private var label: UILabel
    
    override var frame: CGRect {
        didSet {
            setupLayout(frame: frame)
        }
    }
    
    init(type: TypeLoginButton) {
        
        switch type {
            
        case .apple:
            imageView = UIImageView(image: UIImage(named: "apple"))
            label = UILabel()
            label.text = "Apple"
        case .google:
            imageView = UIImageView(image: UIImage(named: "Google"))
            label = UILabel()
            label.text = "Google"
        }
        
        super.init(frame: .zero)
        
        label.textAlignment = .center
        backgroundColor = .white
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        contentMode = .scaleAspectFit
        
        addSubview(imageView)
        addSubview(label)
    }
    
    private func setupLayout(frame: CGRect ) {
        layer.cornerRadius = bounds.size.height / 2.0
        let widthLabel = label.text!.width(withConstrainedHeight: frame.height, font: label.font)
        
        imageView.frame = CGRect(x: (frame.width - 24 - widthLabel) / 2, y: (frame.height - 24) / 2, width: 24, height: 24)
        label.frame = CGRect(x: imageView.frame.origin.x + imageView.frame.width + 16, y: 0, width: widthLabel, height: frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
