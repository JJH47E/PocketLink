//
//  DeviceMonitor.swift
//  Pocket
//
//  Created by JJ Hayter on 30/04/2026.
//

import Foundation
import Combine
import DiskArbitration

private let analogueVendor = "Analogue"

class DeviceMonitor: ObservableObject {
    let context = DeviceContext()
    private var session: DASession?
    // Holds the passRetained reference so we can balance it in stop().
    private var selfPtr: Unmanaged<DeviceMonitor>?
    // Forwards context's @Published changes up to DeviceMonitor so SwiftUI
    // views observing the monitor re-render when device state changes.
    private var contextSink: AnyCancellable?
    // Triggers a firmware update check whenever firmwareVersion is set.
    private var firmwareSink: AnyCancellable?

    init() {
        contextSink = context.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
        firmwareSink = context.$firmwareVersion
            .compactMap { $0 }
            .sink { [weak self] installed in
                Task { await self?.fetchFirmwareVersion(installed: installed) }
            }
        start()
    }

    private func start() {
        guard let newSession = DASessionCreate(kCFAllocatorDefault) else {
            context.daSessionFailed = true
            return
        }
        session = newSession

        // passRetained increments the retain count, guaranteeing self is alive
        // for the lifetime of any DA callback even if @StateObject is recreated.
        // Balanced by stop() on teardown.
        let retained = Unmanaged.passRetained(self)
        selfPtr = retained
        let ptr = retained.toOpaque()

        // DARegisterDiskAppearedCallback fires for all present disks at registration
        // time (already mounted) and for new disks as they appear (not yet mounted).
        // We use it to mark "connecting" and to handle the already-mounted case.
        DARegisterDiskAppearedCallback(newSession, nil, daAppearedCallback, ptr)

        // DARegisterDiskDescriptionChangedCallback fires when a disk's description
        // changes. Watching kDADiskDescriptionVolumePathKey means we're notified
        // exactly when a new disk is mounted and its path becomes available —
        // eliminating the need for any hardcoded delay.
        DARegisterDiskDescriptionChangedCallback(
            newSession,
            nil,
            [kDADiskDescriptionVolumePathKey] as CFArray,
            daDescriptionChangedCallback,
            ptr
        )

        DARegisterDiskDisappearedCallback(newSession, nil, daDisappearedCallback, ptr)
        DASessionScheduleWithRunLoop(newSession, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }

    func stop() {
        if let session {
            DASessionUnscheduleFromRunLoop(session, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            self.session = nil
        }
        selfPtr?.release()
        selfPtr = nil
    }

    fileprivate func diskAppeared(disk: DADisk) {
        guard isAnalogue(disk: disk) else { return }
        guard !context.connecting, !context.deviceConnected else { return }

        DispatchQueue.main.async { self.context.connecting = true }

        // Handle already-mounted case: app launched while device was already connected.
        // At registration time, DiskAppeared fires for present disks which are already
        // fully mounted, so kDADiskDescriptionVolumePathKey is set immediately.
        if let desc = DADiskCopyDescription(disk) as NSDictionary?,
           let volumeURL = desc[kDADiskDescriptionVolumePathKey] as? URL {
            connectDevice(disk: disk, volumeURL: volumeURL)
        }
        // For newly-plugged disks, the volume path is nil here.
        // daDescriptionChangedCallback fires once it is set.
    }

    fileprivate func diskDescriptionChanged(disk: DADisk) {
        guard isAnalogue(disk: disk) else { return }
        guard !context.deviceConnected else { return }

        guard let desc = DADiskCopyDescription(disk) as NSDictionary?,
              let volumeURL = desc[kDADiskDescriptionVolumePathKey] as? URL else { return }
        connectDevice(disk: disk, volumeURL: volumeURL)
    }

    fileprivate func diskDisappeared() {
        DispatchQueue.main.async { self.context.reset() }
    }

    private func connectDevice(disk: DADisk, volumeURL: URL) {
        let storageSize = (DADiskCopyDescription(disk) as NSDictionary?)?[kDADiskDescriptionMediaSizeKey] as? Double
        DispatchQueue.main.async {
            self.context.deviceConnected = true
            self.context.connecting = false
            self.context.volumeRoute = volumeURL
            if let storageSize { self.context.storageSize = storageSize }
        }
        readDeviceInfo(from: volumeURL, context: context)
        readPlatforms(from: volumeURL, context: context)
    }

    @MainActor
    private func fetchFirmwareVersion(installed: String) async {
        do {
            let remote = try await FirmwareService().fetchLatestVersion()
            if VersionComparator.isNewer(remote, than: installed) {
                context.latestFirmwareVersion = remote
            }
        } catch {
            // silent degradation — leave latestFirmwareVersion as nil
        }
    }

    private func isAnalogue(disk: DADisk) -> Bool {
        guard let desc = DADiskCopyDescription(disk) as NSDictionary?,
              let vendor = desc[kDADiskDescriptionDeviceVendorKey] as? String else { return false }
        return vendor.trimmingCharacters(in: .whitespaces) == analogueVendor
    }
}

// MARK: - C Callbacks

private func daAppearedCallback(disk: DADisk, ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<DeviceMonitor>.fromOpaque(ctx).takeUnretainedValue().diskAppeared(disk: disk)
}

private func daDescriptionChangedCallback(disk: DADisk, keys: CFArray, ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<DeviceMonitor>.fromOpaque(ctx).takeUnretainedValue().diskDescriptionChanged(disk: disk)
}

private func daDisappearedCallback(disk: DADisk, ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<DeviceMonitor>.fromOpaque(ctx).takeUnretainedValue().diskDisappeared()
}
