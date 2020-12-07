//
//  Descriptor.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct Descriptor: Equatable {
    
    let rawValue: CBDescriptor?
    public let identifier: CBUUID
    public let characteristic: Characteristic
    public var value: Value?
    
    init(from descriptor: CBDescriptor) {
        rawValue = descriptor
        identifier = descriptor.uuid
        characteristic = Characteristic(from: descriptor.characteristic)
        value = Self.anyToValue(uuid: identifier, descriptor.value)
    }
    
    init(identifier: CBUUID, characteristic: Characteristic, value: Value?) {
        rawValue = nil
        self.identifier = identifier
        self.characteristic = characteristic
        self.value = value
    }
    
    static func anyToValue(uuid: CBUUID, _ value: Any?) -> Value? {
        switch uuid.uuidString {
        case CBUUIDCharacteristicExtendedPropertiesString: return .characteristicExtendedProperties(value as? NSNumber)
        case CBUUIDCharacteristicUserDescriptionString: return .characteristicUserDescription(value as? String)
        case CBUUIDClientCharacteristicConfigurationString: return .clientCharacteristicConfiguration(value as? NSNumber)
        case CBUUIDServerCharacteristicConfigurationString: return .serverCharacteristicConfiguration(value as? NSNumber)
        case CBUUIDCharacteristicFormatString: return .characteristicFormat(value as? Data)
        case CBUUIDCharacteristicAggregateFormatString: return .characteristicAggregateFormat(value as? Data)
        default: return nil
        }
    }
}

extension Descriptor {
    
    public enum Action: Equatable {
        case didUpdateValue(Result<Value, BluetoothError>)
        case didWriteValue(Result<Value, BluetoothError>)
    }
}

extension Descriptor {
    
    public enum Value: Equatable {
        case characteristicExtendedProperties(NSNumber?)
        case characteristicUserDescription(String?)
        case clientCharacteristicConfiguration(NSNumber?)
        case serverCharacteristicConfiguration(NSNumber?)
        case characteristicFormat(Data?)
        case characteristicAggregateFormat(Data?)
        
        var associatedValue: Any? {
            switch self {
            case .characteristicExtendedProperties(let number): return number
            case .characteristicUserDescription(let string): return string
            case .clientCharacteristicConfiguration(let number): return number
            case .serverCharacteristicConfiguration(let number): return number
            case .characteristicFormat(let data): return data
            case .characteristicAggregateFormat(let data): return data
            }
        }
        
        var cbuuid: CBUUID {
            switch self {
            case .characteristicExtendedProperties: return CBUUID(string: CBUUIDCharacteristicExtendedPropertiesString)
            case .characteristicUserDescription: return CBUUID(string: CBUUIDCharacteristicUserDescriptionString)
            case .clientCharacteristicConfiguration: return CBUUID(string: CBUUIDClientCharacteristicConfigurationString)
            case .serverCharacteristicConfiguration: return CBUUID(string: CBUUIDServerCharacteristicConfigurationString)
            case .characteristicFormat: return CBUUID(string: CBUUIDCharacteristicFormatString)
            case .characteristicAggregateFormat: return CBUUID(string: CBUUIDCharacteristicAggregateFormatString)
            }
        }
    }
}

extension Descriptor {
    
    public static func mock(
        identifier: CBUUID,
        characteristic: Characteristic,
        value: Value?
    ) -> Self {
        Self(
            identifier: identifier,
            characteristic: characteristic,
            value: value
        )
    }
}

extension Descriptor: Identifiable {
    public var id: CBUUID {
        return identifier
    }
}
