//
//  UserModel.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 29/12/20.
//

import Foundation
import Alamofire

struct UserModel {
    public static func generateToken(completion: @escaping(Int, Dictionary<String, Any>) -> Void) {
        let headers:HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded", "source": Tokens.source]
        NetWorkController.httpRequest(url: "/user/token", method: .get, parameters: [:], headers: headers) { (status, json) in
            completion(status, json)
        }
    }
}
