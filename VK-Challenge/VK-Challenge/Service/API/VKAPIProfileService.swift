//
//  VKAPIProfileService.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

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
