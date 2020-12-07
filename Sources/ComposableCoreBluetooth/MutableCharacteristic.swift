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
    
    public init(
        type: CBUUID,
        properties: CBCharacteristicProperties,
        value: Data?,
        permissions: CBAttributePermissions,
        descriptors: [MutableDescriptor]?
    ) {
        self.type = type
        self.properties = properties
        self.value = value
        self.permissions = permissions
        self.descriptors = descriptors
    }
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    var cbMutableCharacteristic: CBMutableCharacteristic {
        let characteristic = CBMutableCharacteristic(type: type, properties: properties, value: value, permissions: permissions)
        characteristic.descriptors = descriptors?.map(\.cbMutableDescriptor)
        return characteristic
    }
}
