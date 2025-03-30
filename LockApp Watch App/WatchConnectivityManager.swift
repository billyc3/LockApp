import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func requestCredentials(completion: @escaping (Result<Void, Error>) -> Void) {
        guard WCSession.default.isReachable else {
            completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "iPhone not reachable"])))
            return
        }
        WCSession.default.sendMessage(["request": "credentials"], replyHandler: { response in
            if let apiKey = response["apiKey"] as? String, let deviceId = response["deviceId"] as? String,
               let apiKeyData = apiKey.data(using: .utf8), let deviceIdData = deviceId.data(using: .utf8) {
                KeychainHelper.standard.save(apiKeyData, service: "LockAppService", account: "apiKey")
                KeychainHelper.standard.save(deviceIdData, service: "LockAppService", account: "deviceId")
                NotificationCenter.default.post(name: .credentialsUpdated, object: nil)
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: response["error"] as? String ?? "Invalid response"])))
            }
        }, errorHandler: { error in completion(.failure(error)) })
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let apiKey = message["apiKey"] as? String, let deviceId = message["deviceId"] as? String,
           let apiKeyData = apiKey.data(using: .utf8), let deviceIdData = deviceId.data(using: .utf8) {
            KeychainHelper.standard.save(apiKeyData, service: "LockAppService", account: "apiKey")
            KeychainHelper.standard.save(deviceIdData, service: "LockAppService", account: "deviceId")
            NotificationCenter.default.post(name: .credentialsUpdated, object: nil)
        }
    }
}
