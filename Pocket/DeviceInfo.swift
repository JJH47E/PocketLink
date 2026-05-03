//
//  DeviceInfo.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

struct DeviceInfo: Decodable {
    let product: String
    let firmware: DeviceFirmware
}

struct DeviceFirmware: Decodable {
    let runtime: DeviceRuntime
}

struct DeviceRuntime: Decodable {
    let name: String
    let byte: Int
    let buildDate: String
}
