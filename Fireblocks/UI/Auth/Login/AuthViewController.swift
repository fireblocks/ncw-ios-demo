//
//  LoginViewController.swift
//  Fireblocks
//
//  The login screen provides to users convenient authentication options "Sign in with Google" and
//  "Sign in with Apple".
//
//  Our login screen is designed to offer users a hassle-free and user-friendly authentication
//  experience. 
//
//  We prioritize the security and confidentiality of user-sensitive data. Robust measures are
//  implemented to safeguard user information throughout the authentication process. We employ
//  industry-standard encryption protocols and follow strict data protection guidelines to ensure
//  the privacy and integrity of user data.
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

class AuthViewController: UIViewController {
    
    static let identifier = "AuthViewController"

    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var headerConstraints: NSLayoutConstraint!
    @IBOutlet weak var signInMethodStackView: UIStackView!
    @IBOutlet weak var roundedCornerView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var roundedCornerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var googleButton: AppActionBotton!
    @IBOutlet weak var appleButton: AppActionBotton!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionLabelContainer: UIView!

    @IBOutlet weak var loginSubTitle: UILabel!
    @IBOutlet weak var mainViewContainer: UIView!
    @IBOutlet weak var loginButtonsContainer: UIView!

    @IBOutlet weak var hiddenBackButton: UIButton!

    private lazy var viewModel: AuthViewModel = { AuthViewModel(self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeaderSize()
        addPaddingStackView()
        versionLabel.text = Bundle.main.versionLabel
        versionLabelContainer.backgroundColor = AssetsColors.gray2.getColor()
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // get the Documents folder path
        
        let pathForDocumentDir = documentsPath[0]
        print("pathForDocumentDir: \(pathForDocumentDir)")

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        versionLabelContainer.layer.cornerRadius = versionLabelContainer.frame.height/2.0
    }
    
    private func setHeaderSize(){
        let viewHeight = UIScreen.main.bounds.height / 5
        let roundedCornerViewHeight = roundedCornerView.frame.height / 2
        headerConstraints.constant = viewHeight + roundedCornerViewHeight
    }
    
    private func addPaddingStackView() {
        signInMethodStackView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        signInMethodStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        viewModel.setLoginMethod(loginMethod: .signIn)
        setLoginView()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        viewModel.setLoginMethod(loginMethod: .signUp)
        setSignUpView()
    }
    
    @IBAction func addDeviceTapped(_ sender: UIButton) {
        viewModel.setLoginMethod(loginMethod: .addDevice)
        setAddDeviceView()
    }
    
    private func setTransition() {
        UIView.animate(withDuration: 0.3) {
            self.mainViewContainer.alpha = 0
            self.loginButtonsContainer.alpha = 1
            self.hiddenBackButton.alpha = 1
        }
    }
    
    private func revertTransition() {
        UIView.animate(withDuration: 0.3) {
            self.mainViewContainer.alpha = 1
            self.loginButtonsContainer.alpha = 0
            self.hiddenBackButton.alpha = 0
        }
    }

    @IBAction func didTapBack(_ sender: UIButton) {
        revertTransition()
    }
    
    private func setLoginView() {
        setTransition()
//        setButtonSelectedState(selectedButton: signInButton, disabledButton: signUpButton)
        loginSubTitle.text = LocalizableStrings.signInTitle
        googleButton.config(title: LocalizableStrings.loginGoogleSignIn, image: AssetsIcons.googleIcon.getIcon(), style: .Secondary)
        appleButton.config(title: LocalizableStrings.loginAppleSignIn, image: AssetsIcons.appleIcon.getIcon(), style: .Secondary)
    }
    
    private func setSignUpView(){
        setTransition()
//        setButtonSelectedState(selectedButton: signUpButton, disabledButton: signInButton)
        loginSubTitle.text = LocalizableStrings.signUpTitle
        googleButton.config(title: LocalizableStrings.loginGoogleSignUp, image: AssetsIcons.googleIcon.getIcon(), style: .Secondary)
        appleButton.config(title: LocalizableStrings.loginAppleSignUP, image: AssetsIcons.appleIcon.getIcon(), style: .Secondary)
    }
    
    private func setAddDeviceView() {
        setTransition()
//        setButtonSelectedState(selectedButton: signUpButton, disabledButton: signInButton)
        loginSubTitle.text = LocalizableStrings.addDeviceTitle
        googleButton.config(title: LocalizableStrings.loginGoogleAddDevice, image: AssetsIcons.googleIcon.getIcon(), style: .Secondary)
        appleButton.config(title: LocalizableStrings.loginAppleAddDevice, image: AssetsIcons.appleIcon.getIcon(), style: .Secondary)
    }
    
    private func setButtonSelectedState(selectedButton: UIButton, disabledButton: UIButton){
        selectedButton.backgroundColor = AssetsColors.black.getColor()
        disabledButton.backgroundColor = UIColor.clear
    }
    
    @IBAction func signInWithGoogleTapped(_ sender: AppActionBotton) {
        guard let gidSignInConfig = viewModel.getGIDConfiguration() else {
            print("Can't create GIDSignIn config for google request.")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = gidSignInConfig
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("Sign in failed with: \(String(describing: error?.localizedDescription)).")
                return
            }
            
            showLoader(isShow: true)
            showButtons(isShow: false)
            if let user = result?.user.userID {
                viewModel.signInToFirebase(with: result, user: user)
            }
        }
    }
    
    @IBAction func signInWithAppleTapped(_ sender: AppActionBotton) {
        let authorizationController = ASAuthorizationController(
            authorizationRequests: [viewModel.getAppleRequest()]
        )
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func showLoader(isShow: Bool) {
        if isShow {
            showActivityIndicator(isBackgroundEnabled: false)
        } else {
            hideActivityIndicator()
        }
    }
    
    private func showButtons(isShow: Bool){
        buttonsContainerView.isHidden = !isShow
    }
    
    private func navigateWithAnimation() {
        let vc: UIViewController
        switch viewModel.getLoginMethod() {
        case .signUp:
            vc = UINavigationController(rootViewController: MpcKeysViewController(isAddingDevice: false))
        case .signIn:
            if viewModel.isUserHaveKeys() {
                FireblocksManager.shared.startPolling()
                vc = UINavigationController(rootViewController: TabBarViewController())
            } else {
                vc = UINavigationController(rootViewController: RedirectNewUserHostingVC())
            }
        case .addDevice:
            vc = UINavigationController(rootViewController: MpcKeysViewController(isAddingDevice: true))
        }

        AppLoggerManager.shared.loggers[FireblocksManager.shared.getDeviceId()] = AppLogger(deviceId: FireblocksManager.shared.getDeviceId())
        AppLoggerManager.shared.logger()?.log("User logged in")
        UIView.animate(withDuration: 1, animations: {
            self.welcomeTitle.alpha = 0
            self.subTitle.alpha = 0
            self.roundedCornerViewHeightConstraint.constant = 300
            self.view.layoutIfNeeded()
        }) { [weak self] (finished) in
            if finished {
                if let window = self?.view.window {
                    window.rootViewController = vc
                }
            }
        }
    }
}

extension AuthViewController:
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        showLoader(isShow: true)
        showButtons(isShow: false)
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            viewModel.signInToFirebase(with: authorization, user: appleIDCredential.user)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension AuthViewController: AuthViewModelDelegate {
    @MainActor
    func isUserSignedIn(_ isUserSignedIn: Bool) async {
        showLoader(isShow: false)
        if isUserSignedIn {
            showButtons(isShow: false)
            navigateWithAnimation()
        } else {
            showButtons(isShow: true)
            showAlert(description: viewModel.getErrorMessage())
        }
    }
}
