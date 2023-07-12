//
//  LevelTwoViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 18.05.23.
//

import ARKit
import UIKit
import RealityKit
import ReplayKit
import Combine

public enum EmojiLVL2 {
    case surprise, cry, cuteness
}

public enum ArmSide {
    case left, right
}

protocol LevelTwoViewProtocol: UIViewController {
    func updateIsOko(isOKO: Bool)
}

final class LevelTwoViewController: UIViewController {
    
    var arView: ARView!
    
    var presenter: LevelTwoViewPresenterDelegate!
    
    private let photoVideoButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.backgroundColor = .black
//        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "okoLogoWhite"), for: .normal)
        return btn
    }()
    
    private var stepImageView: UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "Step 1 (4)"))
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    var isOKO = false {
        didSet {
            if isOKO == true {
                stepImageView.image = UIImage(named: "S")
                photoVideoButton.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.stepImageView.image = UIImage(named: "Step 2 (3)")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.stepImageView.isHidden = true
                    })
                })
            }
        }
    }
    
    var leftArmAnchorID: UUID? = nil
    var rightArmAnchorID: UUID? = nil
    var planeBodyAnchorID: UUID? = nil
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(backButton)
        view.addSubview(photoVideoButton)
        view.addSubview(stepImageView)
//        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        photoVideoButton.addTarget(self, action: #selector(snapshotSave), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
        photoVideoButton.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        
        photoVideoButton.frame = CGRect(x: (view.bounds.width - 80) / 2, y: view.bounds.height - 122, width: 80, height: 80)
        photoVideoButton.layer.cornerRadius = photoVideoButton.bounds.size.height / 2.0
        
        stepImageView.frame = view.frame
        
        arView.removeFromSuperview()
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
//        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
    }
    
    override func didReceiveMemoryWarning() {
        print ("ПАМЯТЬ КОНЧИЛАСЬ")
    }
    
    
    private func startSession() {
        presenter.startSession()
    }
    
    func stopSession() {
        presenter.stopSession()
    }
    
    func updateIsOko(isOKO: Bool) {
        if isOKO == true {
            stepImageView.image = UIImage(named: "S")
            photoVideoButton.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.stepImageView.image = UIImage(named: "Step 2 (3)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.stepImageView.isHidden = true
                })
            })
        }
    }
    
    @objc func backButtonTap() {
//        arView.removeFromSuperview()
//        navigationController?.popViewController(animated: true)
    }
    
    @objc private func snapshotSave() {
        arView.snapshot(saveToHDR: false, completion: {image in
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }

    
    @objc private func recordScreen(sender: UILongPressGestureRecognizer) {
        /// багулька с разрешением на запись экрана
        switch sender.state {
            
        case .began:
            RPScreenRecorder.shared().startRecording(handler: { error in
                guard let error = error else { return }
//                print ("htfghythyf", error.localizedDescription)
            })
        
        case .ended:
            RPScreenRecorder.shared().stopRecording { preview, err in
              guard let preview = preview else { print("no preview window"); return }
              preview.modalPresentationStyle = .overFullScreen
              preview.previewControllerDelegate = self
              self.present(preview, animated: true)
                
            }
        default:
            break
        }
    }
    
}


extension LevelTwoViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      previewController.dismiss(animated: true) { [weak self] in
      /// после исчезновения previewController
      }
    }
}

extension LevelTwoViewController: LevelTwoViewProtocol {
    
}


