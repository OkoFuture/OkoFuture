//
//  LogInViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 22.05.23.
//

import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn
import FirebaseDatabase
import MessageUI

final class LogInViewController: UIViewController {
    
    private var currentNonce: String?
    
    var keyboardHeight = CGFloat(0)
    
    var ref: DatabaseReference!
    
    let logoImageView: UIImageView = {
        let img = UIImage(named: "okoLogoBlack")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    let logInLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Log in"
        //        lbl.font = Helper().fontChakra600(size: 32)
        lbl.font = lbl.font.withSize(32)
        lbl.textColor = .black
        return lbl
    }()
    
    let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "E-mail"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let emailTextField: UITextField = {
        let txt = UITextField()
        txt.textColor = .black
        txt.backgroundColor = .white
        txt.layer.borderWidth = 1
        txt.layer.borderColor = UIColor.black.cgColor
        txt.textAlignment = .center
        return txt
    }()
    
    let passwordTextField: UITextField = {
        let txt = UITextField()
        txt.textColor = .black
        txt.backgroundColor = .white
        txt.layer.borderWidth = 1
        txt.layer.borderColor = UIColor.black.cgColor
        txt.textAlignment = .center
        return txt
    }()
    
    let sendCodeButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Send code", for: .normal)
        //        btn.font = Helper().fontChakra500(size: 16)!
        return btn
    }()
    
    let signUpLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Or Sign Up with"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let appleSignUpButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Apple", for: .normal)
        btn.setImage(UIImage(named: "AppleLogo"), for: .normal)
        //        btn.font = Helper().fontChakra500(size: 16)!
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    let googleSignUpButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Google", for: .normal)
        btn.setImage(UIImage(named: "GoogleLogo"), for: .normal)
        //        btn.font = Helper().fontChakra500(size: 16)!
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
        
        if Helper().getUser() == nil {
            Helper().createUser()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        view.addSubview(logInLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(sendCodeButton)
        view.addSubview(signUpLabel)
        view.addSubview(appleSignUpButton)
        view.addSubview(googleSignUpButton)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        sendCodeButton.addTarget(self, action: #selector(tapSendButton), for: .touchUpInside)
        appleSignUpButton.addTarget(self, action: #selector(tapLogInApple), for: .touchUpInside)
        googleSignUpButton.addTarget(self, action: #selector(tapLogInGoogle), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 96)/2, y: 116, width: 96, height: 96)
        logInLabel.frame = CGRect(x: (view.bounds.width - 90)/2, y: logoImageView.frame.origin.y + 96 + 14, width: 90, height: 42)
        
        emailTextField.frame = CGRect(x: 20, y: view.center.y - 4 - heightOko, width: view.bounds.width - 40, height: heightOko)
        emailTextField.layer.cornerRadius = emailTextField.bounds.size.height / 2.0
        
        emailLabel.frame = CGRect(x: (view.bounds.width - 60)/2, y: emailTextField.frame.origin.y - 24 - 8, width: 60, height: 24)
        
        passwordTextField.frame = CGRect(x: 20, y: view.center.y + 4, width: view.bounds.width - 40, height: heightOko)
        passwordTextField.layer.cornerRadius = emailTextField.bounds.size.height / 2.0
        
        sendCodeButton.frame = CGRect(x: 20, y: passwordTextField.frame.origin.y + heightOko + 8, width: view.bounds.width - 40, height: heightOko)
        
        signUpLabel.frame = CGRect(x: (view.bounds.width - 120)/2, y: view.bounds.height - 178 - 24, width: 120, height: 24)
        
        
        appleSignUpButton.frame = CGRect(x: 20, y: signUpLabel.frame.origin.y + 24 + 16, width: view.bounds.width - 40, height: heightOko)
        googleSignUpButton.frame = CGRect(x: 20, y: appleSignUpButton.frame.origin.y + heightOko + 4, width: view.bounds.width - 40, height: heightOko)
        
    }
    
//    private func pushToPasswordViewController(email: String, password: String) {
//
//        if Auth.auth().currentUser != nil {
//            pushToProfileSettingViewController()
//        } else {
//            Helper().addUserFirebase(email: email, password: password, completedHangler: { [weak self] in
//                guard let self = self else { return }
//                self.pushToProfileSettingViewController()
//            })
//        }
//    }
    
    private func pushToProfileSettingViewController() {
        let vc = ProfileSettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToUploadSceneViewController() {
        let vc = UploadSceneViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tapSendButton() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if email.count == 0 || password.count < 6 { return }
        
//        pushToPasswordViewController(email: email, password: password)
        signInEmail(withEmail: email, password: password)
    }
    
    private func signInEmail(withEmail: String, password: String) {
        Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          
            if let error = error {
                print ("signInEmail fail error =", error.localizedDescription)
                
                Helper().addUserFirebase(email: withEmail, password: password, completedHangler: { [weak self] in
                    guard let self = self else { return }
                    self.pushToProfileSettingViewController()
                })
            } else {
                strongSelf.pushToUploadSceneViewController()
            }
        }
    }
    
    @objc @available(iOS 13, *)
    func tapLogInApple() {
        currentNonce = Helper().tapLogInApple(delegate: self, presentationContextProvider: self)
    }
    
    @objc private func tapLogInGoogle() {
        
        self.signIn(completionHandler: { [weak self] in
            guard let self = self else { return }
            self.pushToProfileSettingViewController()
        })
    }
    
    func signIn(completionHandler: @escaping (() -> Void)) {
        
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                self.authenticateUser(for: user, with: error, completionHandler: { [weak self] in
                    guard let self = self else { return }
                    self.pushToUploadSceneViewController()
                })
            }
        } else {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = configuration
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, completion: { [unowned self] result, error in
                self.authenticateUser(for: result?.user, with: error, completionHandler: completionHandler)
            })
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?, completionHandler: @escaping (() -> Void)) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                if let fullname = user?.profile?.name, let email = user?.profile?.email {
                    for userDate in UserData.allCases {
                        switch userDate {
                        case .name:
                            Helper().updateUserData(typeUserData: .name, userData: fullname, needUpdateFirebase: false)
                        case .email:
                            Helper().updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                        default: break
                        }
                    }
                }
                
                print ("log in with google completed", user?.profile?.email, user?.profile?.name, user?.profile?.givenName, user?.profile?.familyName, user?.profile?.imageURL(withDimension: 320))
                
                Helper().updateUserLogStatus(logStatus: .logInWithGoogle)
                completionHandler()
            }
        }
    }

}

extension LogInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print ("log in with apple fail", error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)
                
                Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let firstName = appleIDCredential.fullName?.givenName, let lastName = appleIDCredential.fullName?.familyName, let email = appleIDCredential.email {
                            for userDate in UserData.allCases {
                                switch userDate {
                                case .name:
                                    Helper().updateUserData(typeUserData: .name, userData: firstName + " " + lastName, needUpdateFirebase: false)
                                case .email:
                                    Helper().updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                                default: break
                                }
                            }
                        }
                        
                        print ("log in with apple completed", appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName)
                        
                        Helper().updateUserLogStatus(logStatus: .logInWithApple)
                        pushToProfileSettingViewController()
                    }
                }
            }
        default:
            break
        }
    }
}

extension LogInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension LogInViewController: MFMailComposeViewControllerDelegate {
    
    private func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendEmailButtonTapped() {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }

        func configuredMailComposeViewController() -> MFMailComposeViewController {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

            mailComposerVC.setToRecipients(["kalinin.denis187@gmail.com"])
            mailComposerVC.setSubject("Sending you an in-app e-mail...")
            mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)

            return mailComposerVC
        }

        func showSendMailErrorAlert() {
            let sendMailErrorAlert = UIAlertController(title: "баля", message: "не вышло брат", preferredStyle: .actionSheet)
            
            let closeButton = UIAlertAction(title: "Close", style: .cancel, handler: { alert in
//                alert
            })
            
            sendMailErrorAlert.addAction(closeButton)
            
            present(sendMailErrorAlert, animated: true)
        }
}

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            textField.resignFirstResponder() // Always dismiss KB upon textField 'Return'
                 return false
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var moveValueDown: CGFloat = 0.0
        
        if textField == passwordTextField {
            moveValueDown = CGFloat(keyboardHeight)
        }
        
        if moveValueDown > 0 {
//            animateViewMoving(false, moveValue: moveValueDown)
        }
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
//            let movementDuration:TimeInterval = 0.3
            let movement:CGFloat = ( up ? -moveValue : moveValue)
//            UIView.beginAnimations( "animateView", context: nil)
//            UIView.setAnimationBeginsFromCurrentState(true)
//            UIView.setAnimationDuration(movementDuration )
            self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
//            UIView.commitAnimations()
        }
        
        @objc func keyboardWillShow(notification: NSNotification) {
            
            // IMPORTANT Use    UIKeyboardFrameEndUserInfoKey
            //                  UIKeyboardFrameBeginUserInfoKey (gives inconsistent KB heights)
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              keyboardHeight = keyboardSize.height
              print(#function, keyboardHeight)
                // The 1st keyboardWillShow gets the keyboard size height then observer removed as no need to get keyboard height every time it shows or hides
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
                // Store KeyboardHeight in UserDefaults to use when in Edit Mode
//                UserDefaults.standard.set(keyboardHeight, forKey: "KeyboardHeight")
//                UserDefaults.standard.synchronize()
            }
        }
}

