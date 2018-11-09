//
//  AuthController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

protocol AuthControllerViewModelOutput: class {
    var loginButtonEnabled: ((Bool) -> Void)? { get set }
}

final class AuthControllerViewModel: AuthControllerViewModelOutput {
    // MARK: - Output

    var loginButtonEnabled: ((Bool) -> Void)?

    // MARK: - Members

    private let authService: AuthService

    private let authScope = CONST.VK.authScope

    // MARK: - Init

    init(authService: AuthService) {
        self.authService = authService

        checkIfAuthorized()
    }

    // MARK: - Interface



    func authorize() {}

    // MARK: - Private

    private func checkIfAuthorized() {
        authService.checkIfAuthorized(with: authScope, completion: handleAuthCallback)
    }

    private func handleAuthCallback(_ isAuthorized: Bool) {
        loginButtonEnabled?(!isAuthorized)
    }
}

final class Dependency {
    // MARK: - Interface

    static func makeAuthViewModel() -> AuthControllerViewModel {
        let viewModel = AuthControllerViewModel(authService: authService)

        return viewModel
    }

    // MARK: - Instance

    private static let tokenStore = TokenStore()

    private static let authService: AuthService = {
        let service = AuthServiceImp(store: tokenStore)

        return service
    }()
}

final class AuthController: UIViewController {
    // MARK: - Outlets

    @IBOutlet
    private var loginButton: UIButton!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    // MARK: - Members

    private lazy var viewModel: AuthControllerViewModel = Dependency.makeAuthViewModel()

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.loginButtonEnabled = { [unowned self] isEnabled in
            self.loginButton.isEnabled = isEnabled
        }

//        authService.onAuthChange = handleAuthCallback
//        authService.onIsLoggedIn = { [weak self] _ in
//        }
//
//        authService.onNeedPresent = { [weak self] controller in
//            self?.present(controller, animated: true)
//        }
    }

    private func handleAuthCallback(_ succeed: Bool, errorMessage: String?) {
        guard succeed else {
            showError(with: errorMessage)
            return
        }
    }

    private func showError(with message: String? = nil) {
        let alert = UIAlertController(title: "Authorization failed", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    @IBAction
    private func authorize() {
        let scope = CONST.VK.authScope
        //authService.authorize(with: scope)
    }

    private func showFeed() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let feed = main.instantiateViewController(withIdentifier: "Feed")

        guard let wnd = UIApplication.shared.keyWindow else { assertionFailure(); return }
        wnd.rootViewController = feed
    }
}

// ==

typealias VKAuthCallback = ((Bool, String?) -> Void)

protocol AuthServiceOutput: class {
    var onIsLoggedIn: ((Bool) -> Void)? { get set }

    var onAuthChange: VKAuthCallback? { get set }

    var onNeedPresent: ((UIViewController) -> Void)? { get set }
}

protocol AuthService: AuthServiceOutput {
    func checkIfAuthorized(with scope: [VKScope], completion: @escaping ((Bool) -> Void))

    func authorize(with scope: [VKScope])
}

final class AuthServiceImp: NSObject, AuthService {
    // MARK: - Output

    var onIsLoggedIn: ((Bool) -> Void)?

    var onAuthChange: VKAuthCallback?

    var onNeedPresent: ((UIViewController) -> Void)?

    // MARK: - Interface

    func checkIfAuthorized(with scope: [VKScope], completion: @escaping ((Bool) -> Void)) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.wakeUpSession(perms) { state, err in
            guard err == nil else {
                completion(false)
                return
            }

            let isAuthorized = (state == VKAuthorizationState.authorized)
            completion(isAuthorized)
        }
    }

    func authorize(with scope: [VKScope]) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    // MARK: - Members

    private let store: TokenStore

    // MARK: - Init

    init(store: TokenStore) {
        self.store = store
        super.init()
        initSDK()
    }

    // MARK: - Private

    private func initSDK() {
        guard let vk = VK_SDK.initialize(withAppId: CONST.VK.appID) else {
            assertionFailure("^ can't init vk sdk!")
            return
        }

        vk.register(self)
        vk.uiDelegate = self
    }
}

extension AuthServiceImp: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        guard let token = result.token.accessToken else {
            onAuthChange?(false, result?.error?.localizedDescription)
            return
        }
        store.save(token)
    }

    func vkSdkUserAuthorizationFailed() {
        onAuthChange?(false, nil)
    }
}

extension AuthServiceImp: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        onNeedPresent?(controller)
    }

    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        onAuthChange?(false, captchaError?.errorMessage)
    }
}
