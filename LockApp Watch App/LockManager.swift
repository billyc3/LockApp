import Foundation

class LockManager {
    static let shared = LockManager()

    private init() {}

    func unlockDoor(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let apiKeyData = KeychainHelper.standard.read(service: "LockAppService", account: "apiKey"),
              let deviceIdData = KeychainHelper.standard.read(service: "LockAppService", account: "deviceId"),
              let apiKey = String(data: apiKeyData, encoding: .utf8),
              let deviceId = String(data: deviceIdData, encoding: .utf8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Credentials not set"])))
            return
        }
        let url = URL(string: "https://connect.getseam.com/locks/unlock_door")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["device_id": deviceId])
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error { completion(.failure(error)) }
            else if (response as? HTTPURLResponse)?.statusCode == 200 { completion(.success(())) }
            else { completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to unlock"]))) }
        }.resume()
    }

    func lockDoor(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let apiKeyData = KeychainHelper.standard.read(service: "LockAppService", account: "apiKey"),
              let deviceIdData = KeychainHelper.standard.read(service: "LockAppService", account: "deviceId"),
              let apiKey = String(data: apiKeyData, encoding: .utf8),
              let deviceId = String(data: deviceIdData, encoding: .utf8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Credentials not set"])))
            return
        }
        let url = URL(string: "https://connect.getseam.com/locks/lock_door")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["device_id": deviceId])
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error { completion(.failure(error)) }
            else if (response as? HTTPURLResponse)?.statusCode == 200 { completion(.success(())) }
            else { completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to lock"]))) }
        }.resume()
    }

    func checkLockStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let apiKeyData = KeychainHelper.standard.read(service: "LockAppService", account: "apiKey"),
              let deviceIdData = KeychainHelper.standard.read(service: "LockAppService", account: "deviceId"),
              let apiKey = String(data: apiKeyData, encoding: .utf8),
              let deviceId = String(data: deviceIdData, encoding: .utf8) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Credentials not set"])))
            return
        }
        let url = URL(string: "https://connect.getseam.com/locks/get?device_id=\(deviceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let lock = json["lock"] as? [String: Any],
                  let properties = lock["properties"] as? [String: Any],
                  let locked = properties["locked"] as? Bool else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            completion(.success(locked))
        }.resume()
    }
}
