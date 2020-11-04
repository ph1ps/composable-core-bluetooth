//
//  Manager.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth

public func _unimplemented(_ function: StaticString, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(
        """
        `\(function)` was called but is not implemented. Be sure to provide an implementation for this endpoint when creating the mock.
        """,
        file: file,
        line: line
    )
}

func couldNotFindRawServiceValue() {
    assertionFailure(
        """
        The supplied service did not have a raw value. This is considered a programmer error. \
        You should use a Service object returned to you.
        """
    )
}

func couldNotFindRawCharacteristicValue() {
    assertionFailure(
        """
        The supplied characteristic did not have a raw value. This is considered a programmer error. \
        You should use a Characteristic object returned to you.
        """
    )
}

func couldNotFindRawDescriptorValue() {
    assertionFailure(
        """
        The supplied descriptor did not have a raw value. This is considered a programmer error. \
        You should use a Descriptor object returned to you.
        """
    )
}


func couldNotFindRawRequestValue() {
    assertionFailure(
        """
        The supplied request did not have a raw value. This is considered a programmer error. \
        You should use a ATTRequest object returned to you.
        """
    )
}

func couldNotFindRawCentralValue() {
    assertionFailure(
        """
        The supplied central did not have a raw value. This is considered a programmer error. \
        You should use a Central object returned to you.
        """
    )
}

func convertToResult<T, E>(_ value: T?, error: E?) -> Result<T, BluetoothError> where E: Error {
    if let error = error {
        if let cbError = error as? CBError {
            return .failure(.coreBluetooth(cbError))
        } else {
            return .failure(.unknown(error.localizedDescription))
        }
    } else {
        if let value = value {
            return .success(value)
        } else {
            return .failure(.valueAndErrorAreEmpty)
        }
    }
}

