import SwiftUI

struct ContentView: View {
    @State private var credentialsSet = false
    @State private var isFetching = false
    @State private var errorMessage: String?
    @State private var statusMessage = "Ready"
    @State private var isLocked: Bool?

    var body: some View {
        Group {
            if credentialsSet {
                VStack(spacing: 10) {
                    if let isLocked = isLocked {
                        Text(isLocked ? "Locked" : "Unlocked")
                            .font(.headline)
                            .foregroundColor(isLocked ? .red : .green)
                    } else {
                        Text("Checking...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Button("Unlock") { unlockDoor() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    Button("Lock") { lockDoor() }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            } else {
                VStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    if isFetching {
                        ProgressView("Fetching...")
                    } else {
                        Button("Fetch Credentials") { fetchCredentials() }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            print("Content надайте: ContentView appeared")
            checkCredentials()
        }
        .onReceive(NotificationCenter.default.publisher(for: .credentialsUpdated)) { _ in
            print("Received credentialsUpdated notification")
            checkCredentials()
        }
    }

    private func checkCredentials() {
        print("Checking credentials...")
        credentialsSet = KeychainHelper.areCredentialsSet()
        print("Credentials set: \(credentialsSet)")
        if credentialsSet {
            print("Fetching lock status...")
            checkLockStatus()
        }
    }

    private func fetchCredentials() {
        print("Fetching credentials...")
        isFetching = true
        errorMessage = nil
        WatchConnectivityManager.shared.requestCredentials { result in
            print("Credentials fetch complete")
            DispatchQueue.main.async {
                isFetching = false
                switch result {
                case .success:
                    print("Credentials fetched successfully")
                    self.checkCredentials()
                case .failure(let error):
                    print("Failed to fetch credentials: \(error.localizedDescription)")
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func unlockDoor() {
        print("Unlocking door...")
        LockManager.shared.unlockDoor { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    statusMessage = "Unlocked!"
                    isLocked = false
                    print("Door unlocked successfully")
                case .failure(let error):
                    statusMessage = "Unlock Failed: \(error.localizedDescription)"
                    print("Failed to unlock door: \(error.localizedDescription)")
                }
            }
        }
    }

    private func lockDoor() {
        print("Locking door...")
        LockManager.shared.lockDoor { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    statusMessage = "Locked!"
                    isLocked = true
                    print("Door locked successfully")
                case .failure(let error):
                    statusMessage = "Lock Failed: \(error.localizedDescription)"
                    print("Failed to lock door: \(error.localizedDescription)")
                }
            }
        }
    }

    private func checkLockStatus() {
        print("Checking lock status...")
        LockManager.shared.checkLockStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locked):
                    isLocked = locked
                    statusMessage = locked ? "Locked" : "Unlocked"
                    print("Lock status: \(locked ? "Locked" : "Unlocked")")
                case .failure(let error):
                    statusMessage = "Status Error: \(error.localizedDescription)"
                    print("Failed to check lock status: \(error.localizedDescription)")
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
