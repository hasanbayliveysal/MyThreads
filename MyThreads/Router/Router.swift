//
//  Router.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

protocol RouterProtocol {
    func loginVC () -> UIViewController
    func registerVC() -> UIViewController
    func feedVC()->UIViewController
    func searchVC()->UIViewController
    func uploadVC()->UIViewController
    func notificationVC()->UIViewController
    func currentUserProfileVC()->UIViewController
    func guestUserProfileVC(with guestUserID: String) -> UIViewController
    func moreVC()->UIViewController
    func commentVC(threadID: String)->UIViewController
    func likedVC()->UIViewController
}

class Router: RouterProtocol {
  
    
    func loginVC() -> UIViewController {
        return LoginViewController(vm: LoginViewModel(), router: self)
    }
    func registerVC() -> UIViewController {
        return RegisterViewController(vm: RegisterViewModel(), router: self)
    }
    
    func feedVC() -> UIViewController {
        return FeedViewController(vm: FeedViewModel(), router: self)
    }
    func searchVC() -> UIViewController {
        return SearchViewController(vm: SearchViewModel(), router: self)
    }
    func uploadVC() -> UIViewController {
        return UploadViewController(vm: UploadViewModel(), router: self)
    }
    func notificationVC() -> UIViewController {
        return NotificationViewController(vm: NotificationViewModel(), router: self)
    }
    func currentUserProfileVC() -> UIViewController {
        return CurrentUserProfileViewController(vm: UserProfileViewModel(), router: self)
    }
    
    func guestUserProfileVC(with guestUserID: String) -> UIViewController {
       return GuestUserProfileViewController(vm: UserProfileViewModel(userID: guestUserID), router: self)
    }
    func moreVC() -> UIViewController {
        return MoreViewController(vm: MoreViewModel(), router: self)
    }
    func commentVC(threadID: String) -> UIViewController {
        return CommentsVC(vm: CommentsVM(threadID: threadID), router: self)
    }
    func likedVC() -> UIViewController {
        return LikedViewController(vm: FeedViewModel(), router: self)
    }
}
