//
//  ATTRequest.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 29.10.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct ATTRequest: Equatable {
    
    let rawValue: CBATTRequest?
    public let characteristic: Characteristic
    public let value: Data?
    public let offset: Int
    
    init(from request: CBATTRequest) {
        rawValue = request
        characteristic = Characteristic(from: request.characteristic)
        value = request.value
        offset = request.offset
    }
    
    init(
       characteristic: Characteristic,
       value: Data?,
       offset: Int
   ) {
       rawValue = nil
       self.characteristic = characteristic
       self.value = value
       self.offset = offset
   }
}

extension ATTRequest {
    
    public static func mock(
        characteristic: Characteristic,
        value: Data?,
        offset: Int
    ) -> Self {
        return ATTRequest(
            characteristic: characteristic,
            value: value,
            offset: offset
        )
    }
}
