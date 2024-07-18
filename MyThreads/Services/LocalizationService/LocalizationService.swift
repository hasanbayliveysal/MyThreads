//
//  LocalizationService.swift
//  MyThreads
//
//  Created by Veysal Hasanbayli on 02.07.24.
//

import UIKit

protocol LocalizationServiceProtocol {
    func changeLanguage(_ language: String)
    func getLanguage() -> String
}

final class LocalizationService: LocalizationServiceProtocol {
    static let shared = LocalizationService()
    private init(){}
    
    static let userApplicationLanguageKey = "UserApplicationLanguageKey"
    static var currentLanguage = Language.az.rawValue
    
    func changeLanguage(_ language: String) {
        LocalizationService.currentLanguage = language
        UserDefaults.standard.setValue(language, forKey: LocalizationService.userApplicationLanguageKey)
    }
    
    @discardableResult
    func getLanguage() -> String {
        let language = UserDefaults.standard.string(forKey: LocalizationService.userApplicationLanguageKey) ?? LocalizationService.currentLanguage
        LocalizationService.currentLanguage = language
        return language
    }
}


enum Language: String {
    case az,en
}
