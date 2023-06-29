//
//  LevelOneViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 25.04.23.
//

import ARKit
import UIKit
import RealityKit
import ReplayKit

enum Emoji {
    case shoced, excited, pokerFace
}

protocol LevelOneViewProtocol: AnyObject{
    func updateIsOko(isOKO: Bool)
}

final class LevelOneViewController: UIViewController {
    
    var arView: ARView!
    
    var presenter: LevelOneViewPresenterDelegate!
    
    private let photoVideoButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.backgroundColor = .black
        btn.setImage(UIImage(named: "okoLogoWhite"), for: .normal)
        return btn
    }()
    
    private var stepImageView: UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "Step 1 (4)"))
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stepImageView)
        view.addSubview(backButton)
        view.addSubview(photoVideoButton)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        
        photoVideoButton.addTarget(self, action: #selector(snapshotSave), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
        photoVideoButton.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        stepImageView.frame = view.frame
        photoVideoButton.frame = CGRect(x: (view.bounds.width - 80) / 2, y: view.bounds.height - 122, width: 80, height: 80)
        photoVideoButton.layer.cornerRadius = photoVideoButton.bounds.size.height / 2.0
        
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    private func startSession() {
        presenter.startSession()
    }
    
    @objc func backButtonTap() {
        presenter.backButtonTap()
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

extension LevelOneViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      previewController.dismiss(animated: true) { [weak self] in
      /// после исчезновения previewController
      }
    }
}

extension LevelOneViewController: LevelOneViewProtocol{
    
}
