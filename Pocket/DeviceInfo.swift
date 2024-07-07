//
//  DeviceInfo.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

class DeviceInfo : Decodable {
    let product: String
    let firmware: DeviceFirmware
}

class DeviceFirmware : Decodable {
    let runtime: DeviceRuntime
}

class DeviceRuntime : Decodable {
    let name: String
    let byte: Int
    let build_date: String
}
