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
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(logoImageView)
        view.addSubview(logInLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendCodeButton)
        view.addSubview(signUpLabel)
        view.addSubview(appleSignUpButton)
        view.addSubview(googleSignUpButton)
        
        sendCodeButton.addTarget(self, action: #selector(tapSendButton), for: .touchUpInside)
        appleSignUpButton.addTarget(self, action: #selector(tapLogInApple), for: .touchUpInside)
        googleSignUpButton.addTarget(self, action: #selector(tapLogInGoogle), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 96)/2, y: 116, width: 96, height: 96)
        logInLabel.frame = CGRect(x: (view.bounds.width - 90)/2, y: logoImageView.frame.origin.y + 96 + 14, width: 90, height: 42)
        
        emailTextField.frame = CGRect(x: 20, y: view.center.y - 4 - heightOko, width: view.bounds.width - 40, height: heightOko)
        emailTextField.layer.cornerRadius = emailTextField.bounds.size.height / 2.0
        
        emailLabel.frame = CGRect(x: (view.bounds.width - 60)/2, y: emailTextField.frame.origin.y - 24 - 8, width: 60, height: 24)
        
        sendCodeButton.frame = CGRect(x: 20, y: view.center.y + 4, width: view.bounds.width - 40, height: heightOko)
        
        signUpLabel.frame = CGRect(x: (view.bounds.width - 120)/2, y: view.bounds.height - 178 - 24, width: 120, height: 24)
        
        
        appleSignUpButton.frame = CGRect(x: 20, y: signUpLabel.frame.origin.y + 24 + 16, width: view.bounds.width - 40, height: heightOko)
        googleSignUpButton.frame = CGRect(x: 20, y: appleSignUpButton.frame.origin.y + heightOko + 4, width: view.bounds.width - 40, height: heightOko)
        
    }
    
    private func pushToPasswordViewController(email: String, password: String) {
        
        /// вот тут запрос для получение пароля юзера
//        Helper().updateUserData(typeUserData: .password, userData: "11111")
        Helper().addUserFirebase(email: email, password: password)
        
//        self.ref.child("awd").setValue("dfg")
        
        let vc = PasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToProfileSettingViewController() {
        let vc = ProfileSettingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func tapSendButton() {
        
//        guard let email = emailTextField.text else { return }
//
//        if email.count == 0 { return }
        
//        sendEmailButtonTapped()
        
//        self.ref.child(“user_id”).setValue(123456)
        
//        pushToPasswordViewController(email: email)
        
//        admin.firestore().collection('mail').add({
//          to: 'someone@example.com',
//          message: {
//            subject: 'Hello from Firebase!',
//            html: 'This is an <code>HTML</code> email body.',
//          },
//        })
    }
    
    @objc private func tapLogInApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let requvest = provider.createRequest()
        requvest.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [requvest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
    }
    
    @objc private func tapLogInGoogle() {
        signIn()
    }
    
    func signIn() {
        
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            authenticateUser(for: user, with: error)
        }
      } else {
          
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let configuration = GIDConfiguration(clientID: clientID)
          
        GIDSignIn.sharedInstance.configuration = configuration
          
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
          
          GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, completion: { [unowned self] result, error in
              authenticateUser(for: result?.user, with: error)
            })
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
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
                        Helper().updateUserData(typeUserData: .name, userData: fullname)
                    case .email:
                        Helper().updateUserData(typeUserData: .email, userData: email)
                    default: break
                    }
                }
            }
            
            print ("log in with google completed", user?.profile?.email, user?.profile?.name, user?.profile?.givenName, user?.profile?.familyName, user?.profile?.imageURL(withDimension: 320))
            
            Helper().updateUserLogStatus(logStatus: .logInWithGoogle)
            pushToProfileSettingViewController()
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
            
            if let firstName = credentials.fullName?.givenName, let lastName = credentials.fullName?.familyName, let email = credentials.email {
                for userDate in UserData.allCases {
                    switch userDate {
                    case .name:
                        Helper().updateUserData(typeUserData: .name, userData: firstName + " " + lastName)
                    case .email:
                        Helper().updateUserData(typeUserData: .email, userData: email)
                    default: break
                    }
                }
            }
            
            print ("log in with apple completed", credentials.fullName, credentials.email, credentials.user, credentials.realUserStatus, credentials.state, credentials.identityToken)
            
            Helper().updateUserLogStatus(logStatus: .logInWithApple)
            pushToProfileSettingViewController()
            
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

