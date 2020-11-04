//
//  Characteristic.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct Characteristic: Equatable {
    
    let rawValue: CBCharacteristic?
    
    public let identifier: CBUUID
    public let properties: CBCharacteristicProperties

    init(from characteristic: CBCharacteristic) {
        rawValue = characteristic
        identifier = characteristic.uuid
        properties = characteristic.properties
    }
    
    init(identifier: CBUUID, properties: CBCharacteristicProperties) {
        rawValue = nil
        self.identifier = identifier
        self.properties = properties
    }
}

extension Characteristic {
    
    public enum Action: Equatable {
        case didDiscoverDescriptors(Result<[Descriptor], BluetoothError>)
        case didUpdateValue(Result<Data, BluetoothError>)
        case didWriteValue(Result<Data, BluetoothError>)
        case didUpdateNotificationState(Result<Bool, BluetoothError>)
    }
}

extension Characteristic {
    public static func mock(identifier: CBUUID, properties: CBCharacteristicProperties) -> Self {
        return Characteristic(identifier: identifier, properties: properties)
    }
}

extension Characteristic: Identifiable {
    public var id: CBUUID {
        return identifier
    }
}
