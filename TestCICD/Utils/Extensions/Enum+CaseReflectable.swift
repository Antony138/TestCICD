//
//  Enum+CaseReflectable.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/29.
//

import Foundation

// -----------------------
//     CaseReflectable
// -----------------------

// designed for enums only
// (use it on other types not recommended)
protocol CaseReflectable {}

// default behaviors.
extension CaseReflectable {

    /// case name
    var caseName: String {
        let mirror = Mirror(reflecting: self)
        // enum cases:
        // - normal case: no children
        // - case with associated values: one child (with label)
        guard let label = mirror.children.first?.label else {
            return "\(self)"    // normal case
        }
        // case with associated values
        return label
    }
    /// associated values
    var associatedValues: Any? {

        // if no children, a normal case, no associated values.
        guard let firstChild = Mirror(reflecting: self).children.first else {
            return nil
        }

        return firstChild.value
    }
}

// --------------------------
//     custom operator ~=
// --------------------------

/// match enum cases with associated values, while disregarding the values themselves.
/// usage: `Enum.enumCase ~= instance`
func ~= <Enum: CaseReflectable, AssociatedValue>(
    // an enum case (with associated values)
    enumCase: (AssociatedValue) -> Enum,    // enum case as function
    // an instance of Enum
    instance: Enum
) -> Bool {
    // if no associated values, `instance` can't be of `enumCase`
    guard let values = instance.associatedValues else { return false }
    // if associated values not of the same type, return false
    guard values is AssociatedValue else { return false }
    // create an instance from `enumCase` (as function)
    let case2 = enumCase(values as! AssociatedValue)
    // if same case name, return true
    return case2.caseName == instance.caseName
}

// ------------
//     Enum
// ------------

// enum with associated values
// (conforms to `CaseReflectable`)
enum Enum: CaseReflectable {
    case int(Int)
    case int2(Int)
    case person(name: String, age: Int)
    case str(String)
}
