//
//  CleanFaceTrackViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 25.04.23.
//

import ARKit
import UIKit
import RealityKit

final class CleanFaceTrackViewController: UIViewController {
    
    private var arView: ARView
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    init(arView: ARView) {
        self.arView = arView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        
        arView.removeFromSuperview()
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
    }
    
    private func startSession() {
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        arView.removeFromSuperview()
    }
    
    @objc func back() {
        arView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
    }
    
}

extension CleanFaceTrackViewController: ARSessionDelegate {
    
}
