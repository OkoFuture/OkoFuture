//
//  Extension.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit
import RealityKit
import AVFoundation

extension UIViewController: ShowAlertProtocol {
    func showAlert(title: String? = nil, message: String, complection: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title ?? "An error occurred!", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            guard let complection = complection else { return }
            complection()
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
/// для дефолтного ожидания
extension UIViewController {
    func defaultLoader() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
        }
        
    func stopDefaultLoader(loader : UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
}
/// добавить идентификатор или отдельный класс, что бы не удалить случайно другую Subview
/// сделать плавнее появление и исчезновение
extension UIViewController {
    func arLoaderShow() {
        let backgroundView = UIView(frame: view.frame)
        backgroundView.backgroundColor = .white
        
        let image = UIImage(named: "LogoBlack")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        backgroundView.addSubview(imageView)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 96, height: 96)
        imageView.center = view.center
        
        view.addSubview(backgroundView)
        UIView.animate(withDuration: 2.0, delay: 0, options: .repeat, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        })
    }
    
    func arVideoLoaderShow() {
        let backgroundView = UIView(frame: view.frame)
        backgroundView.backgroundColor = .white
        
        let videoView = UIView(frame: CGRect(x: 0, y: 0, width: 96, height: 96))
        videoView.center = view.center
        
        guard let path = Bundle.main.path(forResource: "Logo_1_glass_.png[0001-0135]", ofType: "mov") else {
            print("Failed get path Logo_1_glass_.png[0001-0135]")
            return
        }

        let videoURL = URL(fileURLWithPath: path)
        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)

        guard let alphaMovieURL = url else {
            print("Failed get url Logo_1_glass_.png[0001-0135]")
            return
        }

        let videoAsset = AVURLAsset(url: alphaMovieURL)

        let item: AVPlayerItem = .init(asset: videoAsset)

        let player = AVPlayer(playerItem: item)

        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = videoView.frame
        player.play()
        
        videoView.layer.addSublayer(playerLayer)
        backgroundView.addSubview(videoView)
        view.addSubview(backgroundView)
    }
    
    func arLoaderHide() {
        print ("dawbhjkawdbhj", self.view.subviews.last, self.view.subviews.count)
        self.view.subviews.last?.removeFromSuperview()
        
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

extension simd_float4x4 {
    var eulerAngles: simd_float3 {
        simd_float3(
            x: asin(-self[2][1]),
            y: atan2(self[2][0], self[2][2]),
            z: atan2(self[0][1], self[1][1])
        )
    }
}
