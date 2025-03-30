//
//  LockManager.swift
//  LockApp
//
//  Created by William Cook on 3/26/25.
//


import Alamofire
import Foundation

class LockManager {
    static let shared = LockManager()

    private init() {}

    func unlockDoor(apiKey: String, deviceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "https://connect.getseam.com/locks/unlock_door"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(apiKey)", "Content-Type": "application/json"]
        let parameters = ["device_id": deviceId]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                if let error = response.error { completion(.failure(error)) }
                else if response.response?.statusCode == 200 { completion(.success(())) }
                else { completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 0))) }
            }
    }

    func lockDoor(apiKey: String, deviceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "https://connect.getseam.com/locks/lock_door"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(apiKey)", "Content-Type": "application/json"]
        let parameters = ["device_id": deviceId]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                if let error = response.error { completion(.failure(error)) }
                else if response.response?.statusCode == 200 { completion(.success(())) }
                else { completion(.failure(NSError(domain: "", code: response.response?.statusCode ?? 0))) }
            }
    }

    func checkLockStatus(apiKey: String, deviceId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "https://connect.getseam.com/locks/get?device_id=\(deviceId)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(apiKey)", "Content-Type": "application/json"]
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let lock = json["lock"] as? [String: Any],
                   let properties = lock["properties"] as? [String: Any],
                   let locked = properties["locked"] as? Bool {
                    completion(.success(locked))
                } else { completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))) }
            case .failure(let error): completion(.failure(error))
            }
        }
    }
}
