// CoreManagerViewModel.swift
// Pocket

import Foundation

@MainActor
class CoreManagerViewModel: ObservableObject {
    @Published var catalogCores: [CatalogCore] = []
    @Published var installedCores: [InstalledCore] = []
    @Published var updatableCores: [CatalogCore] = []
    @Published var isLoadingCatalog: Bool = false
    @Published var errorMessage: String?
    @Published var installProgress: [String: Double] = [:]

    var volumeRoute: URL?

    private let catalogFetcher = CatalogFetcher()
    private let cache = CatalogCache()
    private let installer = CoreInstaller()

    // MARK: - Catalog

    func loadCatalog() async {
        isLoadingCatalog = true
        errorMessage = nil
        defer { isLoadingCatalog = false }

        do {
            let cores: [CatalogCore]
            if cache.isFresh, let cached = cache.read() {
                let response = try JSONDecoder.snakeCase.decode(CatalogResponse.self, from: cached)
                cores = response.data
            } else {
                let (fetched, rawData) = try await catalogFetcher.fetchCatalog()
                try? cache.write(rawData)
                cores = fetched
            }
            catalogCores = cores
            computeUpdates()
        } catch {
            if let cached = cache.read(),
               let response = try? JSONDecoder.snakeCase.decode(CatalogResponse.self, from: cached) {
                catalogCores = response.data
                computeUpdates()
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reloadCatalog() async {
        cache.invalidate()
        await loadCatalog()
    }

    // MARK: - Installed Cores

    func loadInstalledCores() {
        guard let route = volumeRoute else {
            installedCores = []
            return
        }
        installedCores = getAllInstalledCores(from: route)
        computeUpdates()
    }

    // MARK: - Updates

    func computeUpdates() {
        let installedMap = Dictionary(uniqueKeysWithValues: installedCores.map { ($0.id.lowercased(), $0) })
        updatableCores = catalogCores.filter { catalog in
            guard let installed = installedMap[catalog.id.lowercased()] else { return false }
            return VersionComparator.isNewer(catalog.latestVersion, than: installed.version)
        }
    }

    // MARK: - Install

    func install(core: CatalogCore) async {
        guard let route = volumeRoute else {
            errorMessage = CoreManagerError.sdCardNotMounted.localizedDescription
            return
        }
        guard let downloadURL = core.downloadURL else {
            errorMessage = CoreManagerError.noZipAsset.localizedDescription
            return
        }
        installProgress[core.id] = 0

        var zipURL: URL?
        var extractDir: URL?

        do {
            zipURL = try await installer.downloadZip(from: downloadURL) { [weak self] fraction in
                Task { @MainActor [weak self] in
                    self?.installProgress[core.id] = fraction
                }
            }

            extractDir = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
            try installer.extractZip(at: zipURL!, to: extractDir!)
            try installer.copyToSDCard(
                extractedFolder: extractDir!, coreIdentifier: core.id, volumeRoute: route
            )

            installer.cleanup(zipURL: zipURL, extractionDir: extractDir)
            installProgress.removeValue(forKey: core.id)
            loadInstalledCores()
        } catch {
            installer.cleanup(zipURL: zipURL, extractionDir: extractDir)
            installProgress.removeValue(forKey: core.id)
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Remove

    func remove(core: InstalledCore) async {
        guard let route = volumeRoute else {
            errorMessage = CoreManagerError.sdCardNotMounted.localizedDescription
            return
        }
        do {
            try installer.removeCoreFolder(coreIdentifier: core.id, volumeRoute: route)
            loadInstalledCores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update All

    func updateAll() async {
        for core in updatableCores {
            await install(core: core)
        }
    }

}

