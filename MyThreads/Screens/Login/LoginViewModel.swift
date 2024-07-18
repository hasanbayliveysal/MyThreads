//
//  LoginViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class LoginViewModel {
    var email = ""
    var password = ""
    func login() async throws {
        do {
            try await AuthService.shared.login(with: email, and: password)
        } catch {
            throw error
        }
    }
    
    func setUserLoggedIn() {
        UserDefaults.standard.setValue(true, forKey: "userLoggedIn")
    }
}
