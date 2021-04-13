//
//  Manager.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 04.11.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture
import Combine

public func fail(_ message: String) {
    // reuse failing effect in order to fail if current function is invoked
    let cancellable = Effect<Int, Never>.failing(message).sink { _ in }
    var cancellables = [AnyCancellable]()
    cancellables.append(cancellable)
}

public func _unimplemented(_ function: StaticString, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError(
        """
        `\(function)` was called but is not implemented. Be sure to provide an implementation for this endpoint when creating the mock.
        """,
        file: file,
        line: line
    )
}

func couldNotFindBluetoothManager(id: Any) {
    assertionFailure(
        """
        A Bluetooth manager could not be found with the id \(id). This is considered a programmer error. \
        You should not invoke methods on a Bluetooth manager before it has been created or after it \
        has been destroyed. Refactor your code to make sure there is a Bluetooth manager created by the \
        time you invoke this endpoint.
        """
    )
}

func couldNotFindRawPeripheralValue() {
    assertionFailure(
        """
        The supplied peripheral did not have a raw value. This is considered a programmer error. \
        You should use the .live static function to initialize a peripheral.
        """
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

