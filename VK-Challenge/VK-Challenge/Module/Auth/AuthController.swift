//
//  AuthController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

typealias VoidBlock = ()->Void

protocol AuthControllerViewModelOutput: class {
    var loginButtonEnabled: ((Bool) -> Void)? { get set }

    var onNeedPresent: ((UIViewController) -> Void)? { get set }

    var onNeedShowError: ((String?) -> Void)? { get set }

    var onNeedShowFeed: VoidBlock? { get set }
}

final class AuthControllerViewModel: AuthControllerViewModelOutput {
    // MARK: - Output

    var loginButtonEnabled: ((Bool) -> Void)?

    var onNeedPresent: ((UIViewController) -> Void)?

    var onNeedShowError: ((String?) -> Void)?

    var onNeedShowFeed: VoidBlock?

    // MARK: - Members

    private let authService: AuthService

    private let authScope = CONST.VK.authScope

    // MARK: - Init

    init(authService: AuthService) {
        self.authService = authService

        setupLocalBind()
        checkIfAuthorized()
    }

    private func setupLocalBind() {
        authService.onNeedPresent = { [weak self] controller in
            self?.onNeedPresent?(controller)
        }
    }

    // MARK: - Interface

    func authorize() {
        authService.authorize(with: authScope, completion: handleAuthCallback)
    }

    // MARK: - Private

    private func checkIfAuthorized() {
        authService.checkIfAuthorized(with: authScope, completion: handleAuthCallback)
    }

    private func handleAuthCallback(_ isAuthorized: Bool, errorMessage: String?) {
        loginButtonEnabled?(!isAuthorized)

        if !isAuthorized {
            onNeedShowError?(errorMessage)
        } else {
            onNeedShowFeed?()
        }
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
        viewModel.onNeedPresent = { [unowned self] controller in
            self.present(controller, animated: true)
        }
        viewModel.onNeedShowError = { [unowned self] message in
            self.showError(with: message)
        }

        viewModel.onNeedShowFeed = { [unowned self] in
            print("gotcha")
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
        // authService.authorize(with: scope)
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

protocol AuthService: AuthServiceOutput {
    func authorize(with scope: [VKScope], completion: @escaping VKAuthCallback)

    func checkIfAuthorized(with scope: [VKScope], completion: @escaping VKAuthCallback)
}

protocol AuthServiceOutput: class {
    var onNeedPresent: ((UIViewController) -> Void)? { get set }
}

final class AuthServiceImp: NSObject, AuthService {
    // MARK: - Output

    var onNeedPresent: ((UIViewController) -> Void)?

    // MARK: - Interface

    func authorize(with scope: [VKScope], completion: @escaping VKAuthCallback) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    func checkIfAuthorized(with scope: [VKScope], completion: @escaping VKAuthCallback) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.wakeUpSession(perms) { state, err in
            if let e = err {
                completion(false, e.localizedDescription)
                return
            }

            let isAuthorized = (state == VKAuthorizationState.authorized)
            completion(isAuthorized, nil)
        }
    }

    // MARK: - Members

    private let store: TokenStore

    private var authCallback: VKAuthCallback?

    // MARK: - Init

    init(store: TokenStore) {
        self.store = store
        presenter = presenter
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
            authCallback?(false, result?.error?.localizedDescription)
            return
        }
        store.save(token)
    }

    func vkSdkUserAuthorizationFailed() {
        authCallback?(false, nil)
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
