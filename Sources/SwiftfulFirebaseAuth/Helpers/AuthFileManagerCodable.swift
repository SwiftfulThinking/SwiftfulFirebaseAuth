//
//  AuthFileManagerCodable.swift
//  
//
//  Created by Nick Sarno on 4/10/24.
//

import Foundation
import SwiftUI

@propertyWrapper
struct AuthFileManagerCodable<T:Codable>: DynamicProperty {
    
    @State private var value: T?
    let key: String
    
    var wrappedValue: T? {
        get {
            value
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
    var projectedValue: Binding<T?> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    init(_ key: String) {
        self.key = key
        
        do {
            let url = FileManager.documentsPath(key: key)
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
        } catch {
            _value = State(wrappedValue: nil)
        }
    }
    
    private func save(newValue: T?) {
        let url = FileManager.documentsPath(key: key)
        
        guard let newValue else {
            try? FileManager.default.removeItem(at: url)
            value = nil
            return
        }
        
        do {
            let data = try JSONEncoder().encode(newValue)
            try data.write(to: url)
            value = newValue
        } catch {
            print("🤬 SwiftfulFirebaseAuth - Failed to save mock user: \(error)")
        }
    }
}


fileprivate extension FileManager {
    
    static func documentsPath(key: String) -> URL {
        if #available(iOS 16.0, *) {
            FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appending(path: "\(key).txt")
        } else {
            FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("\(key).txt")
        }
    }
}
