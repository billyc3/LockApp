import SwiftUI
import Alamofire

struct ContentView: View {
    @State private var apiKey = ""
    @State private var deviceId = ""
    @State private var statusMessage = "Ready"
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 20) {
            if isSaving {
                TextField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Device ID", text: $deviceId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save to Keychain") {
                    saveToKeychain()
                }
            } else {
                Button(action: { unlockDoor() }) {
                    Text("Unlock Door")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                Button(action: { lockDoor() }) {
                    Text("Lock Door")
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: { checkLockStatus() }) {
                    Text("Check Status")
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Text(statusMessage)
                    .font(.system(size: 16))
                Button("Edit Credentials") {
                    isSaving = true
                }
            }
        }
        .padding()
        .onAppear { loadFromKeychain() }
    }

    private func saveToKeychain() {
        guard let apiKeyData = apiKey.data(using: .utf8),
              let deviceIdData = deviceId.data(using: .utf8) else {
            statusMessage = "Error encoding data"
            return
        }
        KeychainHelper.standard.save(apiKeyData, service: "LockAppService", account: "apiKey")
        KeychainHelper.standard.save(deviceIdData, service: "LockAppService", account: "deviceId")
        statusMessage = "Credentials saved"
        isSaving = false
        WatchConnectivityManager.shared.sendCredentialsToWatch(apiKey: apiKey, deviceId: deviceId)
    }

    private func loadFromKeychain() {
        if let apiKeyData = KeychainHelper.standard.read(service: "LockAppService", account: "apiKey"),
           let deviceIdData = KeychainHelper.standard.read(service: "LockAppService", account: "deviceId") {
            apiKey = String(data: apiKeyData, encoding: .utf8) ?? ""
            deviceId = String(data: deviceIdData, encoding: .utf8) ?? ""
            statusMessage = "Credentials loaded"
            isSaving = false
        } else {
            statusMessage = "Please enter credentials"
            isSaving = true
        }
    }

    private func unlockDoor() {
        guard !apiKey.isEmpty, !deviceId.isEmpty else {
            statusMessage = "Credentials not set"
            return
        }
        LockManager.shared.unlockDoor(apiKey: apiKey, deviceId: deviceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.statusMessage = "Door Unlocked!"
                case .failure(let error):
                    self.statusMessage = "Unlock Failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func lockDoor() {
        guard !apiKey.isEmpty, !deviceId.isEmpty else {
            statusMessage = "Credentials not set"
            return
        }
        LockManager.shared.lockDoor(apiKey: apiKey, deviceId: deviceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.statusMessage = "Door Locked!"
                case .failure(let error):
                    self.statusMessage = "Lock Failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func checkLockStatus() {
        guard !apiKey.isEmpty, !deviceId.isEmpty else {
            statusMessage = "Credentials not set"
            return
        }
        LockManager.shared.checkLockStatus(apiKey: apiKey, deviceId: deviceId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locked):
                    self.statusMessage = locked ? "Lock is Locked" : "Lock is Unlocked"
                case .failure(let error):
                    self.statusMessage = "Status Check Failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
