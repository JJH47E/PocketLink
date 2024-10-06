//
//  GlobalCallbacks.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation
import DiskArbitration

let ANALOGUE_VENDOR_KEY = "Analogue"

func diskAppearedCallback(disk: DADisk, context: UnsafeMutableRawPointer?) {
    let context = Unmanaged<DeviceContext>.fromOpaque(context!).takeUnretainedValue()
    
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                                }
                            } else {
                                print("[DiskAppearedCallback] Unable to find info json file")
                            }
                        }
                    }
                }
            }
        }
    }
}
