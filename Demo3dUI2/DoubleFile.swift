//
//  double.swift
//  Demo3dUI2
//
//  Created by Omay Operations on 12/1/23.
//

import Foundation

struct DoubleFile {}

extension DoubleFile {
    static func fromCSV(fileName: String, completion: @escaping ([[Double]]) -> Void) {
        var result: [[Double]] = []
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "csv") {
            do {
                let content = try String(contentsOf: url).replacingOccurrences(of: " ", with: "")
                let scanner = Scanner(string: content)
                scanner.charactersToBeSkipped = .whitespaces
                
                while !scanner.isAtEnd {
                    var row: [Double] = []
                    
                    // Scan each element in a row separated by a comma
                    while let value = scanner.scanDouble() {
                        row.append(value)
                        
                        // Skip the comma
                        scanner.scanString(",")
                    }
                    
                    result.append(row)
                    
                    // Skip the newline character
                    scanner.scanString("\n")
                }
                
                completion(result)  // Call the completion handler with the result
            } catch {
                print("Unable to load file.")
                completion([])  // Call the completion handler with an empty result
            }
        } else {
            print("File not found.")
            completion([])  // Call the completion handler with an empty result
        }
    }
}
