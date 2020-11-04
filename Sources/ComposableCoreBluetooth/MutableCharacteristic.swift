//
//  MutableCharacteristic.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct MutableCharacteristic {
    public var type: CBUUID
    public var properties: CBCharacteristicProperties
    public var value: Data?
    public var permissions: CBAttributePermissions
    public var descriptors: [MutableDescriptor]?
    
    var cbMutableCharacteristic: CBMutableCharacteristic {
        let characteristic = CBMutableCharacteristic(type: type, properties: properties, value: value, permissions: permissions)
        characteristic.descriptors = descriptors?.map(\.cbMutableDescriptor)
        return characteristic
    }
}
