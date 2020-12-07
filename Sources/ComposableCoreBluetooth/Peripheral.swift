//
//  Peripheral.swift
//  ComposableCoreBluetooth
//
//  Created by Philipp Gabriel on 15.07.20.
//  Copyright © 2020 Philipp Gabriel. All rights reserved.
//

import CoreBluetooth
import Combine
import ComposableArchitecture

public enum Peripheral {
    
    public struct State: Equatable {
        
        public let identifier: UUID
        public var name: String?
        public var state: CBPeripheralState
        public let canSendWriteWithoutResponse: Bool
        public var services: [Service]
        
        #if !os(macOS)
        public var isANCSAuthorized: Bool
        
        init(
            identifier: UUID,
            name: String?,
            state: CBPeripheralState,
            canSendWriteWithoutResponse: Bool,
            isANCSAuthorized: Bool,
            services: [Service]
        ) {
            self.identifier = identifier
            self.name = name
            self.state = state
            self.canSendWriteWithoutResponse = canSendWriteWithoutResponse
            self.isANCSAuthorized = isANCSAuthorized
            self.services = services
        }
        #else
        init(
            identifier: UUID,
            name: String?,
            state: CBPeripheralState,
            canSendWriteWithoutResponse: Bool,
            services: [Service]
        ) {
            self.identifier = identifier
            self.name = name
            self.state = state
            self.canSendWriteWithoutResponse = canSendWriteWithoutResponse
            self.services = services
        }
        #endif
    }
    
    public struct Environment {
        
        var rawValue: CBPeripheral?
        var delegate: CBPeripheralDelegate?
        var stateCancelable: AnyCancellable?
        
        public internal(set) var readRSSI: () -> Effect<Never, Never>
        var discoverServices: ([CBUUID]?) -> Effect<Never, Never>
        var discoverIncludedServices: ([CBUUID]?, Service) -> Effect<Never, Never>
        var discoverCharacteristics: ([CBUUID]?, Service) -> Effect<Never, Never>
        var discoverDescriptors: (Characteristic) -> Effect<Never, Never>
        var readCharacteristicValue: (Characteristic) -> Effect<Never, Never>
        var readDescriptorValue: (Descriptor) -> Effect<Never, Never>
        var writeCharacteristicValue: (Data, Characteristic, CBCharacteristicWriteType) -> Effect<Never, Never>
        var writeDescriptorValue: (Data, Descriptor) -> Effect<Never, Never>
        var setNotifyValue: (Bool, Characteristic) -> Effect<Never, Never>
        var openL2CAPChannel: (CBL2CAPPSM) -> Effect<Never, Never>
        var maximumWriteValueLength: (CBCharacteristicWriteType) -> Int

        init(
            rawValue: CBPeripheral? = nil,
            delegate: CBPeripheralDelegate? = nil,
            stateCancelable: AnyCancellable? = nil,
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
        ) {
            self.rawValue = rawValue
            self.delegate = delegate
            self.stateCancelable = stateCancelable
            self.readRSSI = readRSSI
            self.discoverServices = discoverServices
            self.discoverIncludedServices = discoverIncludedServices
            self.discoverCharacteristics = discoverCharacteristics
            self.discoverDescriptors = discoverDescriptors
            self.readCharacteristicValue = readCharacteristicValue
            self.readDescriptorValue = readDescriptorValue
            self.writeCharacteristicValue = writeCharacteristicValue
            self.writeDescriptorValue = writeDescriptorValue
            self.setNotifyValue = setNotifyValue
            self.openL2CAPChannel = openL2CAPChannel
            self.maximumWriteValueLength = maximumWriteValueLength
        }
        
        public func discoverServices(_ uuids: [CBUUID]? = nil) -> Effect<Never, Never> {
            discoverServices(uuids)
        }
        
        public func discoverIncludedServices(_ uuids: [CBUUID]? = nil, for service: Service) -> Effect<Never, Never> {
            discoverIncludedServices(uuids, service)
        }
        
        public func discoverCharacteristics(_ uuids: [CBUUID]? = nil, for service: Service) -> Effect<Never, Never> {
            discoverCharacteristics(uuids, service)
        }
        
        public func discoverDescriptors(for characteristic: Characteristic) -> Effect<Never, Never> {
            discoverDescriptors(characteristic)
        }
        
        public func readValue(for characteristic: Characteristic) -> Effect<Never, Never> {
            readCharacteristicValue(characteristic)
        }
        
        public func readValue(for descriptor: Descriptor) -> Effect<Never, Never> {
            readDescriptorValue(descriptor)
        }
        
        public func writeValue(_ data: Data, for characteristic: Characteristic, type: CBCharacteristicWriteType) -> Effect<Never, Never> {
            writeCharacteristicValue(data, characteristic, type)
        }
        
        public func writeValue(_ data: Data, for descriptor: Descriptor) -> Effect<Never, Never> {
            writeDescriptorValue(data, descriptor)
        }
            
        public func setNotifyValue(_ enabled: Bool, for characteristic: Characteristic) -> Effect<Never, Never> {
            setNotifyValue(enabled, characteristic)
        }
        
        public func openL2CAPChannel(_ psm: CBL2CAPPSM) -> Effect<Never, Never> {
            openL2CAPChannel(psm)
        }
        
        public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
            maximumWriteValueLength(type)
        }
    }
}

extension Peripheral.State: Identifiable {
    public var id: UUID {
        identifier
    }
}

extension Peripheral {
    public enum Action: Equatable {
        case isReadyToSendWriteWithoutResponse
        case didUpdateName(String?)
        case didUpdateState(CBPeripheralState)
        case didModifyServices([Service])
        case didReadRSSI(Result<NSNumber, BluetoothError>)
        case didOpenL2CAPChannel(Result<CBL2CAPChannel, BluetoothError>)
        case didDiscoverServices(Result<[Service], BluetoothError>)
        
        case didConnect
        case didDisconnect(BluetoothError?)
        case didFailToConnect(BluetoothError)
        
        @available(macOS, unavailable)
        case didUpdateANCSAuthorization(Bool)
        
        @available(macOS, unavailable)
        case connectionEventDidOccur(CBConnectionEvent)

        case service(CBUUID, Service.Action)
        case characteristic(CBUUID, Characteristic.Action)
        case descriptor(CBUUID, Descriptor.Action)
    }
}
