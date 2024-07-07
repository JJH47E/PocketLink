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
                        let jsonFilePath = volumeURL.appendingPathComponent("Analogue_Pocket.json").path
                        if FileManager.default.fileExists(atPath: jsonFilePath) {
                            DispatchQueue.main.async {
                                print("CONNECTED")
                                context.deviceConnected = true
                                context.volumeRoute = volumeURL
                                if let storageSize = diskDesc[kDADiskDescriptionMediaSizeKey] as? Double {
                                    context.storageSize = storageSize
                                }
                                readDeviceInfo(from: volumeURL, context: context)
                            }
                        }
                    }
                }
            }
        }
    }
}
