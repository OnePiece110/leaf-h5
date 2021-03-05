//
//  DengTa.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/17.
//  Copyright © 2021 dt. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct DengTa<Base> {
    public var base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
    
    public var build:Base {
        return base
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Value>) -> (Value) -> DengTa<Base> {
        return { value in
            let object = build
            object[keyPath: keyPath] = value
            return self
        }
    }
}

public protocol DengTaCompatible {
    associatedtype CompatibleType
    var dt: DengTa<Self.CompatibleType> { get }
    static var dt: DengTa<Self.CompatibleType>.Type { get }
}

extension DengTaCompatible {
    public var dt: DengTa<Self> {
        return DengTa(self)
    }
    
    public static var dt: DengTa<Self>.Type {
        get {
            return DengTa<Self>.self
        }
    }
}

extension NSObject: DengTaCompatible {}
