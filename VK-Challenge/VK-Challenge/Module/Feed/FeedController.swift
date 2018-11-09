//
//  FeedController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

final class FeedController: UIViewController {
    // MARK: - Outlets

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        let s = VKAPIProfileService()
        s.getMyProfile()
    }

    // MARK: - Members

    private let store: TokenStore = { TokenStore() }()

    // MARK: - Methods

    private func authorize(with scope: [VKScope]) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    @IBAction
    private func testCode() {
        let scope: [VKScope] = [.friends, .photos, .wall, .offline]
        authorize(with: scope)
    }

    @IBAction
    private func testDeauth() {
        VK_SDK.forceLogout()
        Router.replace(with: .auth)
    }

    private func showFailedAuthAlert(with error: Error? = nil) {
        let alert = UIAlertController(title: "Authorization failed", message: error?.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

// ===

struct VKProfileModel: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let avatarURL100: String
}

extension VKProfileModel  {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL100 = "photo_100"
    }
}

protocol VKAPIMethod {
    var value: String { get }
}

enum AnyVKAPIMethod: VKAPIMethod {
    var value: String { assertionFailure(); return "ABSTRACT" }
}

enum VKAPIMethodUsers {
    case get
}

extension VKAPIMethodUsers: VKAPIMethod {
    var value: String {
        switch self {
        case .get:
            return "users.get"
        }
    }
}

// ==

protocol VKAPIField {
    var value: String { get }
}

enum AnyVKAPIField: VKAPIField {
    var value: String { assertionFailure(); return "ABSTRACT" }
}

enum VKAPIUsersField {
    case photo100
}

extension VKAPIUsersField: VKAPIField {
    var value: String {
        switch self {
        case .photo100:
            return "photo_100"
        }
    }
}

final class VKAPIService<M: VKAPIMethod, F: VKAPIField> {
    // MARK: - Members

    private let token: String

    private let endpoint: URL

    // MARK: - Interface

    func buildRequest(for method: M, with fields: [F]) -> URLRequest? {
        var concrete = endpoint
        concrete.appendPathComponent(method.value)

        guard var components = URLComponents(url: concrete, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = makeQueryItems(with: fields)

        guard let result = components.url else {
            return nil
        }

        return URLRequest(url: result)
    }

    private func makeQueryItems(with params: [F]) -> [URLQueryItem] {
        let fields = params.map { $0.value }.joined(separator: ",")

        let dict = ["fields": fields,
                    "access_token": token,
                    "v": CONST.VK.apiVersion]

        var result = [URLQueryItem]()
        for (k, v) in dict {
            result.append(URLQueryItem(name: k, value: v))
        }

        return result
    }

    // MARK: - Init

    init(token: String) {
        self.token = token
        endpoint = URL(string: CONST.VK.apiEndpoint)!
    }
}

struct VKAPIArrayResponse<T: Decodable>: Decodable {
    let response: [T]
}

final class VKAPIProfileService {
    // MARK: - Interface

    func getMyProfile() -> VKProfileModel {
        let generic = VKAPIService<AnyVKAPIMethod, AnyVKAPIField>(token: "168f3fa6a562ab4fa7f3135a62e8506a94e2a0c53aaffdb4559d88743c894e5bcfe36260e020eebda22d0")
        let test = generic as? VKAPIService<VKAPIMethodUsers, VKAPIUsersField>

        let base = VKAPIService<VKAPIMethodUsers, VKAPIUsersField>(token: "168f3fa6a562ab4fa7f3135a62e8506a94e2a0c53aaffdb4559d88743c894e5bcfe36260e020eebda22d0")
        let request = base.buildRequest(for: .get, with: [.photo100])
        print(request)

        if let r = request {
            let t = URLSession.shared.dataTask(with: r) { data, _, e in
                if let e = e { assertionFailure(e.localizedDescription) }

                self.handleResponse(data!)
            }
            t.resume()
        }

        return VKProfileModel(id: 1, firstName: "", lastName: "", avatarURL100: "1")
    }

    private func handleResponse(_ data: Data) {
        let d = JSONDecoder()
        let r = try? d.decode(VKAPIArrayResponse<VKProfileModel>.self, from: data)
        print(r)
    }
}
