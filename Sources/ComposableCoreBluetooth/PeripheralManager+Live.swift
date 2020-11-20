//
//  PeripheralManager+Live.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 29.10.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import Foundation
import CoreBluetooth
import ComposableArchitecture
import Combine
import CasePaths

@available(tvOS, unavailable)
@available(watchOS, unavailable)
private var dependencies: [AnyHashable: Dependencies] = [:]

@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct Dependencies {
    let manager: CBPeripheralManager
    let delegate: PeripheralManager.Delegate
    let subscriber: Effect<PeripheralManager.Action, Never>.Subscriber
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension PeripheralManager {
    
    public static let live: PeripheralManager = { () -> PeripheralManager in
        var manager = PeripheralManager()
        
        manager.create = { id, queue, options in
            .concatenate(
                Effect.run { subscriber in
                    let delegate = Delegate(subscriber)
                    let manager = CBPeripheralManager(delegate: delegate, queue: queue, options: options?.toDictionary())
                    
                    dependencies[id] = Dependencies(manager: manager, delegate: delegate, subscriber: subscriber)
                    
                    subscriber.send(.didUpdateState(manager.state))
                    subscriber.send(.didUpdateAuthorization(manager.authorization))
                    
                    return AnyCancellable {
                        dependencies[id] = nil
                    }
                },
                Deferred(createPublisher: { () -> AnyPublisher<PeripheralManager.Action, Never> in
                    dependencies[id]?
                        .manager
                        .publisher(for: \.authorization)
                        .map(PeripheralManager.Action.didUpdateAuthorization)
                        .eraseToAnyPublisher() ?? Effect.none.eraseToAnyPublisher()
                }).eraseToEffect(),
                Deferred(createPublisher: { () -> AnyPublisher<PeripheralManager.Action, Never> in
                    dependencies[id]?
                        .manager
                        .publisher(for: \.isAdvertising)
                        .map((/PeripheralManager.Action.didUpdateAdvertisingState..Result<Bool, BluetoothError>.success).embed)
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
        
        manager.addService = { id, service in
            .fireAndForget {
                dependencies[id]?.manager.add(service.cbMutableService)
            }
        }
        
        manager.removeService = { id, service in
            .fireAndForget {
                dependencies[id]?.manager.remove(service.cbMutableService)
            }
        }
        
        manager.removeAllServices = { id in
            .fireAndForget {
                dependencies[id]?.manager.removeAllServices()
            }
        }
        
        manager.startAdvertising = { id, advertismentData in
            .fireAndForget {
                dependencies[id]?.manager.startAdvertising(advertismentData?.toDictionary())
            }
        }
        
        manager.stopAdvertising = { id in
            .fireAndForget {
                dependencies[id]?.manager.stopAdvertising()
            }
        }
        
        manager.updateValue = { id, data, characteristic, centrals in
            .fireAndForget {
                dependencies[id]?.manager.updateValue(data, for: characteristic.cbMutableCharacteristic, onSubscribedCentrals: centrals?.compactMap(\.rawValue))
            }
        }
        
        manager.respondToRequest = { id, request, result in
            
            guard let rawRequest = request.rawValue else {
                couldNotFindRawRequestValue()
                return .none
            }
            
            return .fireAndForget {
                dependencies[id]?.manager.respond(to: rawRequest, withResult: result)
            }
        }
        
        manager.setDesiredConnectionLatency = { id, latency, central in
            
            guard let rawCentral = central.rawValue else {
                couldNotFindRawRequestValue()
                return .none
            }
            
            return .fireAndForget {
                dependencies[id]?.manager.setDesiredConnectionLatency(latency, for: rawCentral)
            }
        }
        
        manager.publishL2CAPChannel = { id, encryption in
            .fireAndForget {
                dependencies[id]?.manager.publishL2CAPChannel(withEncryption: encryption)
            }
        }
        
        manager.unpublishL2CAPChannel = { id, psm in
            .fireAndForget {
                dependencies[id]?.manager.unpublishL2CAPChannel(psm)
            }
        }

        return manager
    }()
    
    class Delegate: NSObject, CBPeripheralManagerDelegate {
        
        let subscriber: Effect<PeripheralManager.Action, Never>.Subscriber
        
        init(_ subscriber: Effect<PeripheralManager.Action, Never>.Subscriber) {
            self.subscriber = subscriber
        }
        
        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            subscriber.send(.didUpdateState(peripheral.state))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
            subscriber.send(.willRestore(RestorationOptions(from: dict)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
            subscriber.send(.didAddService(convertToResult(Service(from: service), error: error)))
        }
        
        func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
            subscriber.send(.didUpdateAdvertisingState(convertToResult(true, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
            subscriber.send(.didSubscribeTo(Characteristic(from: characteristic), Central(from: central)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
            subscriber.send(.didUnsubscribeFrom(Characteristic(from: characteristic), Central(from: central)))
        }
        
        func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
            subscriber.send(.isReadyToUpdateSubscribers)
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
            subscriber.send(.didReceiveRead(ATTRequest(from: request)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
            subscriber.send(.didReceiveWrite(requests.map(ATTRequest.init)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
            subscriber.send(.didPublishL2CAPChannel(convertToResult(PSM, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
            subscriber.send(.didUnpublishL2CAPChannel(convertToResult(PSM, error: error)))
        }
        
        func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
            subscriber.send(.didOpen(convertToResult(channel, error: error)))
        }
    }
}
