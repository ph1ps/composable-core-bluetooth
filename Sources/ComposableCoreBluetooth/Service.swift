//
//  Service.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct Service: Equatable {

    let rawValue: CBService?
    public let identifier: CBUUID
    public let isPrimary: Bool
    
    init(from service: CBService) {
        rawValue = service
        identifier = service.uuid
        isPrimary = service.isPrimary
    }
    
    init(identifier: CBUUID, isPrimary: Bool) {
        rawValue = nil
        self.identifier = identifier
        self.isPrimary = isPrimary
    }
}

extension Service {
    
    public enum Action: Equatable {
        case didDiscoverIncludedServices(Result<[Service], BluetoothError>)
        case didDiscoverCharacteristics(Result<[Characteristic], BluetoothError>)
    }
}

extension Service {
    public static func mock(identifier: CBUUID, isPrimary: Bool) -> Self {
        return Service(identifier: identifier, isPrimary: isPrimary)
    }
}

extension Service: Identifiable {
    public var id: CBUUID {
        return identifier
    }
}
