//
//  Peripheral+Mock.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import ComposableArchitecture
import CoreBluetooth

extension Peripheral.State {
    
    #if !os(macOS)
    public static func mock(
        identifier: UUID,
        name: String?,
        state: CBPeripheralState,
        canSendWriteWithoutResponse: Bool,
        isANCSAuthorized: Bool,
        services: [Service]
    ) -> Self {
        Self(
            identifier: identifier,
            name: name,
            state: state,
            canSendWriteWithoutResponse: canSendWriteWithoutResponse,
            isANCSAuthorized: isANCSAuthorized,
            services: services
        )
    }
    
    #else
    public static func mock(
        identifier: UUID,
        name: String?,
        state: CBPeripheralState,
        canSendWriteWithoutResponse: Bool,
        services: [Service]
    ) -> Self {
        Self(
            identifier: identifier,
            name: name,
            state: state,
            canSendWriteWithoutResponse: canSendWriteWithoutResponse,
            services: services
        )
    }
    #endif
}

import class Combine.AnyCancellable

extension Peripheral.Environment {
    
    public static func mock(
        readRSSI: @escaping () -> Effect<Never, Never> = { _unimplemented("readRSSI") },
        discoverServices: @escaping ([CBUUID]?) -> Effect<Never, Never> = { _ in _unimplemented("discoverServices") },
        discoverIncludedServices: @escaping ([CBUUID]?, Service) -> Effect<Never, Never> = { _, _ in _unimplemented("discoverIncludedServices") },
        discoverCharacteristics: @escaping ([CBUUID]?, Service) -> Effect<Never, Never> = { _, _ in _unimplemented("discoverCharacteristics") },
        discoverDescriptors: @escaping (Characteristic) -> Effect<Never, Never> = { _ in _unimplemented("discoverDescriptors") },
        readCharacteristicValue: @escaping (Characteristic) -> Effect<Never, Never> = { _ in _unimplemented("readCharacteristicValue")},
        readDescriptorValue: @escaping (Descriptor) -> Effect<Never, Never> = { _ in _unimplemented("readDescriptorValue") },
        writeCharacteristicValue: @escaping (Data, Characteristic, CBCharacteristicWriteType) -> Effect<Never, Never> = { _, _, _ in _unimplemented("writeCharacteristicValue") },
        writeDescriptorValue: @escaping (Data, Descriptor) -> Effect<Never, Never> = { _, _ in _unimplemented("writeDescriptorValue") },
        setNotifyValue: @escaping (Bool, Characteristic) -> Effect<Never, Never> = { _, _ in _unimplemented("setNotifyValue") },
        openL2CAPChannel: @escaping (CBL2CAPPSM) -> Effect<Never, Never> = { _ in _unimplemented("openL2CAPChannel") },
        maximumWriteValueLength: @escaping (CBCharacteristicWriteType) -> Int = { _ in _unimplemented("maximumWriteValueLength") }
    ) -> Self {
        Self(
            rawValue: nil,
            delegate: nil,
            stateCancelable: nil,
            readRSSI: readRSSI,
            discoverServices: discoverServices,
            discoverIncludedServices: discoverIncludedServices,
            discoverCharacteristics: discoverCharacteristics,
            discoverDescriptors: discoverDescriptors,
            readCharacteristicValue: readCharacteristicValue,
            readDescriptorValue: readDescriptorValue,
            writeCharacteristicValue: writeCharacteristicValue,
            writeDescriptorValue: writeDescriptorValue,
            setNotifyValue: setNotifyValue,
            openL2CAPChannel: openL2CAPChannel,
            maximumWriteValueLength: maximumWriteValueLength
        )
    }
    
    public static func failing(
        readRSSI: @escaping () -> Effect<Never, Never> = { .failing("readRSSI") },
        discoverServices: @escaping ([CBUUID]?) -> Effect<Never, Never> = { _ in .failing("discoverServices") },
        discoverIncludedServices: @escaping ([CBUUID]?, Service) -> Effect<Never, Never> = { _, _ in .failing("discoverIncludedServices") },
        discoverCharacteristics: @escaping ([CBUUID]?, Service) -> Effect<Never, Never> = { _, _ in .failing("discoverCharacteristics") },
        discoverDescriptors: @escaping (Characteristic) -> Effect<Never, Never> = { _ in .failing("discoverDescriptors") },
        readCharacteristicValue: @escaping (Characteristic) -> Effect<Never, Never> = { _ in .failing("readCharacteristicValue")},
        readDescriptorValue: @escaping (Descriptor) -> Effect<Never, Never> = { _ in .failing("readDescriptorValue") },
        writeCharacteristicValue: @escaping (Data, Characteristic, CBCharacteristicWriteType) -> Effect<Never, Never> = { _, _, _ in .failing("writeCharacteristicValue") },
        writeDescriptorValue: @escaping (Data, Descriptor) -> Effect<Never, Never> = { _, _ in .failing("writeDescriptorValue") },
        setNotifyValue: @escaping (Bool, Characteristic) -> Effect<Never, Never> = { _, _ in .failing("setNotifyValue") },
        openL2CAPChannel: @escaping (CBL2CAPPSM) -> Effect<Never, Never> = { _ in .failing("openL2CAPChannel") },
        maximumWriteValueLength: @escaping (CBCharacteristicWriteType) -> Int = { _ in
            fail("maximumWriteValueLength")
            return 0
        }
    ) -> Self {
        Self(
            rawValue: nil,
            delegate: nil,
            stateCancelable: nil,
            readRSSI: readRSSI,
            discoverServices: discoverServices,
            discoverIncludedServices: discoverIncludedServices,
            discoverCharacteristics: discoverCharacteristics,
            discoverDescriptors: discoverDescriptors,
            readCharacteristicValue: readCharacteristicValue,
            readDescriptorValue: readDescriptorValue,
            writeCharacteristicValue: writeCharacteristicValue,
            writeDescriptorValue: writeDescriptorValue,
            setNotifyValue: setNotifyValue,
            openL2CAPChannel: openL2CAPChannel,
            maximumWriteValueLength: maximumWriteValueLength
        )
    }
}
