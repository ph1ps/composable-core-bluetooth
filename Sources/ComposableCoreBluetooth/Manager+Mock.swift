//
//  Manager+Mock.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture

extension BluetoothManager {
    
    @available(macOS, unavailable)
    public static func mock(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action, Never> = { _, _, _ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never, Never> = { _, _, _ in
            _unimplemented("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never, Never> = { _, _ in
            _unimplemented("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrieveConnectedPeripherals")
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrievePeripherals")
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never, Never> = { _, _, _ in
            _unimplemented("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            _unimplemented("state")
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            _unimplemented("peripheralEnvironment")
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            _unimplemented("authorization")
        },
        registerForConnectionEvents: @escaping (AnyHashable, ConnectionEventOptions?) -> Effect<Never, Never> = { _, _ in
            _unimplemented("registerForConnectionEvents")
        },
        supports: @escaping (CBCentralManager.Feature) -> Bool = { _ in
            _unimplemented("supports")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization,
            registerForConnectionEvents: registerForConnectionEvents,
            supports: supports
        )
    }
    
    public static func mock(
        create: @escaping (AnyHashable, DispatchQueue?, InitializationOptions?) -> Effect<Action, Never> = { _, _, _ in
            _unimplemented("create")
        },
        destroy: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("destroy")
        },
        connect: @escaping (AnyHashable, Peripheral.State, ConnectionOptions?) -> Effect<Never, Never> = { _, _, _ in
            _unimplemented("connect")
        },
        cancelConnection: @escaping (AnyHashable, Peripheral.State) -> Effect<Never, Never> = { _, _ in
            _unimplemented("cancelConnection")
        },
        retrieveConnectedPeripherals: @escaping (AnyHashable, [CBUUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrieveConnectedPeripherals")
        },
        retrievePeripherals: @escaping (AnyHashable, [UUID]) -> [Peripheral.State] = { _, _ in
            _unimplemented("retrievePeripherals")
        },
        scanForPeripherals: @escaping (AnyHashable, [CBUUID]?, ScanOptions?) -> Effect<Never, Never> = { _, _, _ in
            _unimplemented("scanForPeripherals")
        },
        stopScan: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
            _unimplemented("stopScan")
        },
        state: @escaping (AnyHashable) -> CBManagerState = { _ in
            _unimplemented("state")
        },
        peripheralEnvironment: @escaping (AnyHashable, UUID) -> Peripheral.Environment? = { _, _ in
            _unimplemented("peripheralEnvironment")
        },
        authorization: @escaping () -> CBManagerAuthorization = {
            _unimplemented("authorization")
        }
    ) -> Self {
        Self(
            create: create,
            destroy: destroy,
            connect: connect,
            cancelConnection: cancelConnection,
            retrieveConnectedPeripherals: retrieveConnectedPeripherals,
            retrievePeripherals: retrievePeripherals,
            scanForPeripherals: scanForPeripherals,
            stopScan: stopScan,
            state: state,
            peripheralEnvironment: peripheralEnvironment,
            _authorization: authorization
        )
    }
}
