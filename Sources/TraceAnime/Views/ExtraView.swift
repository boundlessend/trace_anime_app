import SwiftUI

struct ExtraView: View {
    @Binding var settings: AppSettings

    @State private var didClearCache: Bool = false
    @State private var isCheckingUpdate: Bool = false
    @State private var updateResult: UpdateCheckResult?
    @State private var showUpdateAlert: Bool = false

    private let updateCheckService: UpdateCheckService = UpdateCheckService(
        session: .shared,
        releasesURL: URL(string: "https://api.github.com/repos/boundlessend/trace_anime_app/releases/latest")!,
        decoder: JSONDecoder()
    )

    let user: TraceMoeUser?
    let isCheckingQuota: Bool
    let quotaErrorText: String?
    let language: AppLanguage
    let checkQuota: () -> Void
    let clearCache: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SecureField(t(.apiKey, language: language), text: $settings.apiKey)
                .textFieldStyle(.roundedBorder)

            TextField(t(.anilistIDFilter, language: language), text: $settings.anilistIDText)
                .textFieldStyle(.roundedBorder)

            if isCheckingQuota {
                LoadingView(title: t(.checkingQuota, language: language))
                    .transition(.opacity)
            }

            if let user: TraceMoeUser {
                VStack(alignment: .center, spacing: 4) {
                    Text("ID: \(user.id)")
                    Text("\(t(.quota, language: language)): \(user.quotaUsed)/\(user.quota)")
                    Text("\(t(.concurrency, language: language)): \(user.concurrency)")
                    Text("\(t(.priority, language: language)): \(user.priority)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if !isCheckingQuota, user == nil, quotaErrorText == nil {
                Text(t(.checkingQuota, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let quotaErrorText: String {
                Text(quotaErrorText)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                clearCache()
                didClearCache = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    await MainActor.run {
                        didClearCache = false
                    }
                }
            } label: {
                Label(t(.clearCache, language: language), systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .symbolEffect(.bounce, value: didClearCache)
            }
            .buttonStyle(TracePressButtonStyle())

            if didClearCache {
                Text(t(.cacheCleared, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity)
            }

            VStack(spacing: 6) {
                Text("\(t(.version, language: language)) \(currentAppVersion())")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    checkForUpdate()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .rotationEffect(.degrees(isCheckingUpdate ? 360 : 0))
                            .animation(
                                isCheckingUpdate
                                    ? .linear(duration: 0.9).repeatForever(autoreverses: false) : .default,
                                value: isCheckingUpdate
                            )
                        Text(t(.checkUpdates, language: language))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(TracePressButtonStyle())
                .disabled(isCheckingUpdate)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            Text(t(.copyright, language: language))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .animation(.easeInOut(duration: 0.2), value: isCheckingQuota)
        .animation(.easeInOut(duration: 0.2), value: user?.quotaUsed)
        .animation(.easeInOut(duration: 0.2), value: isCheckingUpdate)
        .sensoryFeedback(trigger: updateResult) { _, newValue in
            guard let newValue: UpdateCheckResult else {
                return nil
            }

            switch newValue {
            case .available, .upToDate:
                return .success
            case .failed:
                return .error
            }
        }
        .onAppear {
            checkQuota()
        }
        .alert(t(.checkUpdates, language: language), isPresented: $showUpdateAlert, presenting: updateResult) {
            result in
            updateAlertButtons(result)
        } message: { result in
            Text(updateAlertMessage(result))
        }
    }

    @ViewBuilder
    private func updateAlertButtons(_ result: UpdateCheckResult) -> some View {
        switch result {
        case .available(let release):
            Button(t(.download, language: language)) {
                openURL(release.url)
            }
            Button(t(.cancel, language: language), role: .cancel) {}
        case .upToDate, .failed:
            Button("OK", role: .cancel) {}
        }
    }

    private func updateAlertMessage(_ result: UpdateCheckResult) -> String {
        switch result {
        case .available(let release):
            return "\(t(.updateAvailable, language: language)): \(release.version)"
        case .upToDate:
            return "\(t(.upToDate, language: language)) (\(currentAppVersion()))"
        case .failed:
            return t(.updateFailed, language: language)
        }
    }

    private func checkForUpdate() {
        isCheckingUpdate = true
        Task { @MainActor in
            let result: UpdateCheckResult

            do {
                if let release: AppRelease = try await updateCheckService.availableUpdate(
                    currentVersion: currentAppVersion())
                {
                    result = .available(release)
                } else {
                    result = .upToDate
                }
            } catch {
                result = .failed
            }

            isCheckingUpdate = false
            updateResult = result
            showUpdateAlert = true
        }
    }
}

enum UpdateCheckResult: Equatable {
    case upToDate
    case available(AppRelease)
    case failed
}
