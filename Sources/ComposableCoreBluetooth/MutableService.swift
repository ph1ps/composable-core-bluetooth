//
//  MutableService.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct MutableService {
    
    public var type: CBUUID
    public var isPrimary: Bool
    public var characteristics: [MutableCharacteristic]?
    public var includedServices: [MutableService]?
    
    public init(
        type: CBUUID,
        isPrimary: Bool,
        characteristics: [MutableCharacteristic]?,
        includedServices: [MutableService]?
    ) {
        self.type = type
        self.isPrimary = isPrimary
        self.characteristics = characteristics
        self.includedServices = includedServices
    }
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    var cbMutableService: CBMutableService {
        let service = CBMutableService(type: type, primary: isPrimary)
        service.characteristics = characteristics?.map(\.cbMutableCharacteristic)
        service.includedServices = includedServices?.map(\.cbMutableService)
        return service
    }
}
