//
//  TabBarController.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class TabBarController: UITabBarController {
    
    let router: RouterProtocol = Router()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        setupViewController()
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black.withAlphaComponent(0.2)
    }
    
    private func setupViewController() {
       
        viewControllers = [
            createNavController(rootViewController: router.feedVC(), tabbarIcon: UIImage(named: "feed")),
            createNavController(rootViewController: router.searchVC(), tabbarIcon: UIImage(named: "explore")),
            createNavController(rootViewController: router.uploadVC(), tabbarIcon: UIImage(named: "write")),
            createNavController(rootViewController: router.notificationVC(), tabbarIcon: UIImage(named: "heart")),
            createNavController(rootViewController:  router.currentUserProfileVC(), tabbarIcon: UIImage(named: "account"))
        ]
    }
    
    private func createNavController(rootViewController: UIViewController, tabbarIcon: UIImage?) -> UIViewController{
        let vc = UINavigationController(rootViewController: rootViewController)
        vc.tabBarItem.image = tabbarIcon
        return vc
    }
    
}
