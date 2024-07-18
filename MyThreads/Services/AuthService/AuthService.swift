//
//  AuthService.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol AuthServiceProtocol {
    func login(with email: String, and password: String) async throws
    func register(with user: RegisterViewModel.Item) async throws
    func signOut() async throws
}

class AuthService: AuthServiceProtocol {
    static let shared: AuthServiceProtocol = AuthService()
    
    let auth = Auth.auth()
    
    func login(with email: String, and password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            print("User", result.user.uid)
        } catch {
            throw error
        }
    }
    
    func register(with user: RegisterViewModel.Item) async throws  {
        do {
            let result = try await auth.createUser(withEmail: user.email, password: user.password)
            try await uploadUserData(with: user, and: result.user.uid)
        } catch {
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try auth.signOut()
        } catch {
            print(error)
        }
    }
    
    private func uploadUserData(with user: RegisterViewModel.Item, and id: String) async throws {
        let user = User(id: id, fullname: user.fullname, email: user.email, username: user.username, isAccountPrivate: false)
        guard let userData = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(id).setData(userData)
    }
    
}

