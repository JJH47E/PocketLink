//
//  GlobalCallbacks.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation
import DiskArbitration

let ANALOGUE_VENDOR_KEY = "Analogue"

// TODO: run callback when mounted
func checkForMountedDisks(sessionContext: DASession) -> Void {
    let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])
    
    mountedVolumes?.forEach { volumeURL in
        if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, sessionContext, volumeURL as CFURL) {
            diskAppearedCallback(disk: disk, sessionContext: Unmanaged.passUnretained(sessionContext).toOpaque())
        }
    }
}

func diskMountedCallback(disk: DADisk, sessionContext: Optional<UnsafeMutableRawPointer>) -> Optional<Unmanaged<DADissenter>> {
    diskAppearedCallback(disk: disk, sessionContext: sessionContext)
    return nil
}

func diskUnmountedCallback(disk: DADisk, sessionContext: UnsafeMutableRawPointer?) -> Void {
    print("[DiskUnmountedCallback] Unmounting disk")
    let context = Unmanaged<DeviceContext>.fromOpaque(sessionContext!).takeUnretainedValue()
    
    DispatchQueue.main.async() {
        print("[DiskUnmountedCallback] Resetting context")
        context.reset()
    }
}

func diskAppearedCallback(disk: DADisk, sessionContext: Optional<UnsafeMutableRawPointer>) -> Void {
    let context = Unmanaged<DeviceContext>.fromOpaque(sessionContext!).takeUnretainedValue()
    
    if let diskDesc = DADiskCopyDescription(disk) as NSDictionary? {
        if let vendorKey = diskDesc[kDADiskDescriptionDeviceVendorKey] as? String {
            if vendorKey == ANALOGUE_VENDOR_KEY {
                if let volumeName = diskDesc[kDADiskDescriptionVolumeNameKey] as? String {
                    if let volumeURL = getVolumePath(for: volumeName) {
                        DispatchQueue.main.async {
                            context.connecting = true
                        }
                        print("[DiskAppearedCallback] Connecting")
                        let jsonFilePath = volumeURL.appendingPathComponent("Analogue_Pocket.json").path
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Allow some time for volume to be mounted. Can be improved!
                            print("[DiskAppearedCallback] Checking if info desc file exists")
                            if FileManager.default.fileExists(atPath: jsonFilePath) {
                                DispatchQueue.main.async {
                                    print("[DiskAppearedCallback] Connected")
                                    context.deviceConnected = true
                                    context.volumeRoute = volumeURL
                                    context.connecting = false
                                    if let storageSize = diskDesc[kDADiskDescriptionMediaSizeKey] as? Double {
                                        context.storageSize = storageSize
                                    }
                                    readDeviceInfo(from: volumeURL, context: context)
                                    readPlatforms(from: volumeURL, context: context)
                                }
                            } else {
                                print("[DiskAppearedCallback] Unable to find info json file")
                                context.connecting = false
                            }
                        }
                    }
                }
            }
        }
    }
}
