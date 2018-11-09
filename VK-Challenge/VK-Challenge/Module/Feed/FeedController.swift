//
//  FeedController.swift
//  VK-Challenge
//
//  Created by Evgeniy on 09.11.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit
import VK_ios_sdk

protocol FeedViewModelOutput: class {
    var onAvatarLoaded: ((UIImage?) -> Void)? { get set }
}

protocol FeedViewModel: FeedViewModelOutput {
    func loadInitialData()
}

final class FeedViewModelImp: FeedViewModel {
    // MARK: - Output

    var onAvatarLoaded: ((UIImage?) -> Void)?

    // MARK: - Members

    private let profileService: MyProfileService

    private let imageLoader: ImageLoader

    // MARK: - Init

    init(profileService: MyProfileService, imageLoader: ImageLoader) {
        self.profileService = profileService
        self.imageLoader = imageLoader

        loadInitialData()
    }

    // MARK: - Methods

    func loadInitialData() {
        profileService.getMyProfile(completion: loadMyAvatar)
    }

    private func loadMyAvatar(from profile: VKProfileModel) {
        imageLoader.load(from: profile.avatarURL100) { avatar in
            DispatchQueue.main.async { self.onAvatarLoaded?(avatar) }
        }
    }
}

final class FeedController: UIViewController {
    // MARK: - Outlets

    @IBOutlet
    private var avatarImageView: UIImageView!

    @IBOutlet
    private var postCollection: UICollectionView!

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        postCollection.contentInset.top = 36
    }

    // MARK: - Members

    private let viewModel: FeedViewModel = { Dependency.makeFeedViewModel() }()

    // MARK: - Methods

    private func bindViewModel() {
        viewModel.onAvatarLoaded = { [unowned self] avatar in
            self.avatarImageView.image = avatar
        }
    }

    private func authorize(with scope: [VKScope]) {
        let perms = scope.map { $0.rawValue }
        VK_SDK.authorize(perms)
    }

    @IBAction
    private func testCode() {
        viewModel.loadInitialData()
        // let scope: [VKScope] = [.friends, .photos, .wall, .offline]
        // authorize(with: scope)
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

    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
}

// ===

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeedCell = collectionView.dequeueReusableCell(at: indexPath)
        // cell.testShadow()
        // cell.updateShadow()

        cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.red.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 24)
        cell.layer.shadowRadius = 9
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FeedHeader", for: indexPath)

        return view
    }
}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 256)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 58)
    }

    func test() {
        let shadows = UIView()
        shadows.frame = view.frame
        shadows.clipsToBounds = false
        view.addSubview(shadows)

        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 10)

        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0.39, green: 0.4, blue: 0.44, alpha: 0.07).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 18
        layer0.shadowOffset = CGSize(width: 0, height: 24)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)

        let shapes = UIView()

        shapes.frame = view.frame

        shapes.clipsToBounds = true

        view.addSubview(shapes)

        let layer1 = CALayer()

        layer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor

        layer1.bounds = shapes.bounds

        layer1.position = shapes.center

        shapes.layer.addSublayer(layer1)

        shapes.layer.cornerRadius = 10

        let parent = view!

        parent.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 8).isActive = true

        view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -8).isActive = true
    }
}
