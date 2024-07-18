//
//  RegisterViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

class RegisterViewModel {
    var newUser: Item?
    func register() async throws {
        guard let newUser else {
            return
        }
        do {
            try await AuthService.shared.register(with: Item(email: newUser.email, password: newUser.password, fullname: newUser.fullname, username: newUser.username))
        } catch {
            throw error
        }
    }
    
    
    struct Item {
        let email: String
        let password: String
        let fullname: String
        let username: String
    }

}
