//
//  MutableDescriptor.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct MutableDescriptor {
    public var value: Descriptor.Value
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    var cbMutableDescriptor: CBMutableDescriptor {
        return CBMutableDescriptor(type: value.cbuuid, value: value.associatedValue)
    }
}
