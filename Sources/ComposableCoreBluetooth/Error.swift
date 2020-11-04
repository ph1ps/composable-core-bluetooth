//
//  Error.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 03.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum BluetoothError: Error, Equatable {
    case valueAndErrorAreEmpty
    case coreBluetooth(CBError)
    case unknown(String?)
}
