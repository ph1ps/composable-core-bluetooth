//
//  Peripheral.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import CoreBluetooth
import ComposableArchitecture
import Combine

private func couldNotFindRawServiceValue() {
    assertionFailure(
        """
        The supplied service did not have a raw value. This is considered a programmer error. \
        You should use a Service object returned to you.
        """
    )
}

private func couldNotFindRawCharacteristicValue() {
    assertionFailure(
        """
        The supplied characteristic did not have a raw value. This is considered a programmer error. \
        You should use a Characteristic object returned to you.
        """
    )
}

private func couldNotFindRawDescriptorValue() {
    assertionFailure(
        """
        The supplied descriptor did not have a raw value. This is considered a programmer error. \
        You should use a Descriptor object returned to you.
        """
    )
}

private func convertToResult<T, E>(_ value: T?, error: E?) -> Result<T, BluetoothError> where E: Error {
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

extension Peripheral {
    
    public static func live(from cbPeripheral: CBPeripheral, subscriber: Effect<BluetoothManager.Action, Never>.Subscriber) -> Self {

        var peripheral = Peripheral()
        
        peripheral.rawValue = cbPeripheral
        peripheral.delegate = Delegate(subscriber)
        peripheral.identifier = { cbPeripheral.identifier }
        peripheral.name = { cbPeripheral.name }
        peripheral.services = { cbPeripheral.services?.map(Service.init) }
        peripheral.state = { cbPeripheral.state }
        peripheral.canSendWriteWithoutResponse = { cbPeripheral.canSendWriteWithoutResponse }
        peripheral.maximumWriteValueLength = cbPeripheral.maximumWriteValueLength
        
        peripheral.readRSSI = {
            .fireAndForget { cbPeripheral.readRSSI() }
        }
        
        peripheral.openL2CAPChannel = { psm in
            .fireAndForget { cbPeripheral.openL2CAPChannel(psm) }
        }

        peripheral.discoverServices = { ids in
            .fireAndForget { cbPeripheral.discoverServices(ids) }
        }
        
        #if os(iOS) || os(watchOS) || os(tvOS) || targetEnvironment(macCatalyst)
        peripheral.ancsAuthorized = { cbPeripheral.ancsAuthorized }
        #endif
        
        peripheral.discoverIncludedServices = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverIncludedServices(ids, for: rawService) }
        }
        
        peripheral.discoverCharacteristics = { ids, service in
            
            guard let rawService = service.rawValue else {
                couldNotFindRawServiceValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverCharacteristics(ids, for: rawService) }
        }
        
        peripheral.discoverDescriptors = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.discoverDescriptors(for: rawCharacteristic) }
        }
        
        peripheral.readCharacteristicValue = { characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.readValue(for: rawCharacteristic) }
        }
        
        peripheral.readDescriptorValue = { descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.readValue(for: rawDescriptor) }
        }
        
        peripheral.writeCharacteristicValue = { data, characteristic, writeType in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.writeValue(data, for: rawCharacteristic, type: writeType) }
        }
        
        peripheral.writeDescriptorValue = { data, descriptor in
            
            guard let rawDescriptor = descriptor.rawValue else {
                couldNotFindRawDescriptorValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.writeValue(data, for: rawDescriptor) }
        }
        
        peripheral.setNotifyValue = { value, characteristic in
            
            guard let rawCharacteristic = characteristic.rawValue else {
                couldNotFindRawCharacteristicValue()
                return .none
            }
            
            return .fireAndForget { cbPeripheral.setNotifyValue(value, for: rawCharacteristic) }
        }
        
        return peripheral
    }
    
    class Delegate: NSObject, CBPeripheralDelegate {
        let subscriber: Effect<BluetoothManager.Action, Never>.Subscriber
        
        init(_ subscriber: Effect<BluetoothManager.Action, Never>.Subscriber) {
            self.subscriber = subscriber
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .didDiscoverServices(convertToResult(peripheral.services?.map(Service.init(from:)) ?? [], error: error))
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .service(
                        service.uuid,
                        .didDiscoverIncludedServices(convertToResult(service.includedServices?.map(Service.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .service(
                        service.uuid,
                        .didDiscoverCharacteristics(convertToResult(service.characteristics?.map(Characteristic.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid,
                        .didDiscoverDescriptors(convertToResult(characteristic.descriptors?.map(Descriptor.init) ?? [], error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid,
                        .didUpdateValue(convertToResult(characteristic.value, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .descriptor(
                        descriptor.uuid,
                        .didUpdateValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid, descriptor.value), error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid,
                        .didWriteValue(convertToResult(characteristic.value, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .descriptor(
                        descriptor.uuid,
                        .didWriteValue(convertToResult(Descriptor.anyToValue(uuid: descriptor.uuid, descriptor.value), error: error))
                    )
                )
            )
        }
        
        func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .isReadyToSendWriteWithoutResponse
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .characteristic(
                        characteristic.uuid,
                        .didUpdateNotificationState(convertToResult(characteristic.isNotifying, error: error))
                    )
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .didReadRSSI(convertToResult(RSSI, error: error))
                )
            )
        }
        
        func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .didUpdateName(peripheral.name)
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .didModifyServices(invalidatedServices.map(Service.init))
                )
            )
        }
        
        func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
            subscriber.send(
                .peripheral(
                    peripheral.identifier,
                    .didOpenL2CAPChannel(convertToResult(channel, error: error))
                )
            )
        }
    }
}
