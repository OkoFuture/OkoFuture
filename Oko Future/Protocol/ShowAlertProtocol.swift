//
//  ShowAlertProtocol.swift
//  Oko Future
//
//  Created by Денис Калинин on 06.07.23.
//

import Foundation
import UIKit

protocol ShowAlertProtocol {
    func showAlert(title: String?, message: String, complection: (() -> Void)?)
    
    func defaultLoader() -> UIAlertController
    func stopDefaultLoader(loader : UIAlertController)
    
    func arLoaderShow()
    func arLoaderHide()
}
