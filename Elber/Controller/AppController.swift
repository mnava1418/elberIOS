//
//  AppController.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 28/12/20.
//

import Foundation

struct AppController {
    public static func getToken() -> String? {
        if let userDefaults = UserDefaults(suiteName: Tokens.userAppGroup) {
            guard let token = userDefaults.string(forKey: Constants.TOKEN_KEY) else {
                return nil
            }
            
            return token
        }
              
        return nil
    }
    
    public static func saveToken(token: String, completion: () -> Void) {
        if let userDefaults = UserDefaults(suiteName: Tokens.userAppGroup) {
            userDefaults.set(token, forKey: Constants.TOKEN_KEY)
            completion()
        }
    }
}
