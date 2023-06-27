//
//  OkoBigSwitch.swift
//  Oko Future
//
//  Created by Денис Калинин on 23.04.23.
//

import UIKit

final class OkoBigSwitch: UIView {
    
    public var isOn = true {
        didSet {
            changeState(isOn: isOn)
        }
    }
    
    private var onActive: (() -> Void)? = nil
    private var offActive: (() -> Void)? = nil
    
    private let withAlpha = 0.32
    
    private let avatarLabel: UILabel = {
        let lbl = UILabel()
//        lbl.font = Helper().fontChakra500(size: 16)
        lbl.text = "Avatar"
        lbl.textColor = .black
        return lbl
    }()
    
    private let arLabel: UILabel = {
        let lbl = UILabel()
//        lbl.font = Helper().fontChakra500(size: 16)
        lbl.text = "AR"
        lbl.textColor = .white
        return lbl
    }()
    
    private let bubbleActive: UIView = {
       let vw = UIView()
        vw.backgroundColor = .white
        return vw
    }()
    
    override var frame: CGRect {
        didSet {
            setupFrame(frame: frame)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Helper().backgroundColor()
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = Helper().borderColor()
        
        addSubview(bubbleActive)

        addSubview(avatarLabel)
        addSubview(arLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSwitch))
        addGestureRecognizer(tap)
        
        guard let font = Helper().fontChakra500(size: 16) else {
            print ("zalupa font")
            return
        }
        avatarLabel.font = font
        arLabel.font = font
    }
    
    private func setupFrame(frame: CGRect) {
        self.layer.cornerRadius = self.bounds.size.height / 2.0
            
        avatarLabel.frame = CGRect(x: frame.width/6, y: frame.height/4, width: frame.width/4, height: frame.height/2)
        arLabel.frame = CGRect(x: frame.width/1.5, y: frame.height/4, width: frame.width/4, height: frame.height/2)
        
        avatarLabel.center = CGPoint(x: frame.width/4, y: frame.height/2)
        arLabel.center = CGPoint(x: frame.width/1.25, y: frame.height/2)
        
        let offsetBubble: CGFloat = 2
        let heightCircleActive = frame.height - offsetBubble * 2
        
        bubbleActive.frame = CGRect(x: offsetBubble, y: offsetBubble, width: frame.width / 2, height: heightCircleActive)
        bubbleActive.layer.cornerRadius = bubbleActive.bounds.size.height / 2.0
    }
    
    private func changeState(isOn: Bool) {
        
        let duration = 0.3
        let offsetBubble: CGFloat = 2
        
        switch isOn {
            
        case true:
            
            UIView.animate(withDuration: duration, animations: {
                self.bubbleActive.frame = CGRect(x: offsetBubble, y: offsetBubble, width: self.bubbleActive.frame.width, height: self.bubbleActive.frame.height)
            })
            
            UIView.transition(with: avatarLabel, duration: duration, options: .transitionCrossDissolve) {
                self.avatarLabel.textColor = .black
            }
            
            UIView.transition(with: arLabel, duration: duration, options: .transitionCrossDissolve) {
                self.arLabel.textColor = .white
            }
            
            guard let action = onActive else {return}
            action()
            
        case false:
            
            UIView.animate(withDuration: duration, animations: {
                self.bubbleActive.frame = CGRect(x: self.frame.width/2 - offsetBubble, y: offsetBubble, width: self.bubbleActive.frame.width, height: self.bubbleActive.frame.height)
            })
            
            UIView.transition(with: avatarLabel, duration: duration, options: .transitionCrossDissolve) {
                self.avatarLabel.textColor = .white
            }
            
            UIView.transition(with: arLabel, duration: duration, options: .transitionCrossDissolve) {
                self.arLabel.textColor = .black
            }
            
            guard let action = offActive else {return}
            action()
        }
    }
    
    public func setOnActive(active: @escaping () -> Void) {
        onActive = active
    }
    
    public func setOffActive(active: @escaping () -> Void) {
        offActive = active
    }
    
    @objc private func tapSwitch() {
        isOn.toggle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
