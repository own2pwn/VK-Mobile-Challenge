//
//  AuthControllerViewModel.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

protocol AuthControllerViewModelOutput: class {
    var loginButtonEnabled: ((Bool) -> Void)? { get set }

    var onNeedPresent: ((UIViewController) -> Void)? { get set }

    var onNeedShowError: ((String?) -> Void)? { get set }

    var onNeedShowFeed: VoidBlock? { get set }
}

protocol AuthControllerViewModel: AuthControllerViewModelOutput {
    func authorize()
}
