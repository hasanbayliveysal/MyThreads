//
//  MoreViewModel.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 15.07.24.
//

import UIKit

class MoreViewModel: NSObject {
    var selectedRow: ((MoreVCElemets)->Void)?
    private var rows: [MoreVCElemets] = [
        .liked, .language, .help, .about
    ]
    
    func signOut() async throws {
        do {
            try await AuthService.shared.signOut()
        } catch {
            print(error)
        }
    }
    
    func setUserSignedOut() {
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    func changeLanguage(_ language: Language) {
        LocalizationService.shared.changeLanguage(language.rawValue)
    }
    
}

extension MoreViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreTVCell.identifier, for: indexPath) as! MoreTVCell
        cell.configure(with: rows[indexPath.row])
        return cell
    }
}

extension MoreViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow?(rows[indexPath.row])
    }
}

