//
//  Manager+Live.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import ComposableArchitecture

private var dependencies: [AnyHashable: Dependencies] = [:]

private struct Dependencies {
    let manager: CBCentralManager
    let delegate: BluetoothManager.Delegate
    let subscriber: Effect<BluetoothManager.Action, Never>.Subscriber
}

extension BluetoothManager {
    
    public static let live: BluetoothManager = { () -> BluetoothManager in
        var manager = BluetoothManager()
        
        manager.create = { id, queue, options in
            return .merge(
                Effect.run { subscriber in
                    let delegate = Delegate(subscriber)
                    let manager = CBCentralManager(delegate: delegate, queue: queue, options: options?.toDictionary())
                    
                    dependencies[id] = Dependencies(manager: manager, delegate: delegate, subscriber: subscriber)
                    
                    return AnyCancellable {
                        dependencies[id] = nil
                    }
                },
                Deferred(createPublisher: {
                    dependencies[id]?
                        .manager
                        .publisher(for: \.isScanning)
                        .map(BluetoothManager.Action.didUpdateScanningState)
                        .eraseToAnyPublisher() ?? Effect.none.eraseToAnyPublisher()
                }).eraseToEffect()
            )
        }
        
        manager.destroy = { id in
            .fireAndForget {
                dependencies[id]?.subscriber.send(completion: .finished)
                dependencies[id] = nil
            }
        }
        
        manager.connect = { id, peripheral, options in
            
            guard let rawPeripheral = peripheral.rawValue else {
                couldNotFindRawPeripheralValue()
                return .none
            }
            
            return .fireAndForget { dependencies[id]?.manager.connect(rawPeripheral, options: options?.toDictionary()) }
        }
        
        manager.cancelConnection = { id, peripheral  in
            
            guard let rawPeripheral = peripheral.rawValue else {
                couldNotFindRawPeripheralValue()
                return .none
            }
            
            return .fireAndForget { dependencies[id]?.manager.cancelPeripheralConnection(rawPeripheral) }
        }
        
        manager.retrieveConnectedPeripherals = { id, uuids in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return []
            }
            
            return dependency
                .manager
                .retrieveConnectedPeripherals(withServices: uuids)
                .map { Peripheral.live(from: $0, subscriber: dependency.subscriber) }
        }
        
        manager.retrievePeripherals = { id, uuids in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return []
            }
            
            return dependency
                .manager
                .retrieveConnectedPeripherals(withServices: uuids.map(CBUUID.init))
                .map { Peripheral.live(from: $0, subscriber: dependency.subscriber) }
        }
        
        manager.scanForPeripherals = { id, services, options in
            .fireAndForget { dependencies[id]?.manager.scanForPeripherals(withServices: services, options: options?.toDictionary()) }
        }
        
        manager.stopScan = { id in
            .fireAndForget { dependencies[id]?.manager.stopScan() }
        }
        
        if #available(iOS 13.1, macOS 10.15, macCatalyst 13.1, tvOS 13.0, watchOS 6.0, *) {
            manager._authorization = {
                CBCentralManager.authorization
            }
        }
        
        manager.state = { id in
            
            guard let dependency = dependencies[id] else {
                couldNotFindBluetoothManager(id: id)
                return .unknown
            }
            
            return dependency.manager.state
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        manager.registerForConnectionEvents = { id, options in
            .fireAndForget { dependencies[id]?.manager.registerForConnectionEvents(options: options?.toDictionary()) }
        }
        #endif
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        manager.supports = CBCentralManager.supports
        #endif

        return manager
    }()
    
    class Delegate: NSObject, CBCentralManagerDelegate {
        let subscriber: Effect<BluetoothManager.Action, Never>.Subscriber
        
        init(_ subscriber: Effect<BluetoothManager.Action, Never>.Subscriber) {
            self.subscriber = subscriber
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            subscriber.send(.didConnect(.live(from: peripheral, subscriber: subscriber)))
        }
        
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            if let error = error {
                if let error = error as? CBError {
                    subscriber.send(.didDisconnect(.coreBluetooth(error)))
                } else {
                    subscriber.send(.didDisconnect(.unknown(error.localizedDescription)))
                }
            } else {
                subscriber.send(.didDisconnect(nil))
            }
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            if let error = error {
                if let error = error as? CBError {
                    subscriber.send(.didFailToConnect(.coreBluetooth(error)))
                } else {
                    subscriber.send(.didFailToConnect(.unknown(error.localizedDescription)))
                }
            } else {
                subscriber.send(.didFailToConnect(.unknown(nil)))
            }
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
            subscriber.send(.connectionEventDidOccur(event, .live(from: peripheral, subscriber: subscriber)))
        }
        #endif
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
            subscriber.send(.didDiscover(.live(from: peripheral, subscriber: subscriber), .init(from: advertisementData), RSSI))
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            subscriber.send(.didUpdateState(central.state))
        }
        
        func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
            subscriber.send(.willRestore(.init(from: dict, subscriber: subscriber)))
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
            subscriber.send(.didUpdateANCSAuthorization(.live(from: peripheral, subscriber: subscriber)))
        }
        #endif
    }
}
