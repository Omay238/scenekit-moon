//
//  app.swift
//  Demo3dUI2
//
//  Created by Leonard Maculo on 12/7/23.
//

import SwiftUI

@main
struct app: App {
    @StateObject var LatLongs = LatLong()
    @State var Complete1 = false
    var body: some Scene {
        WindowGroup {
            index()
                .environmentObject(LatLongs)
                .onAppear {
                        DispatchQueue.global().async{
                            let Lat: [[Double]] = DoubleFile.fromCSV(fileName: "latitude") ?? []
                            let Long: [[Double]] = DoubleFile.fromCSV(fileName: "longitude") ?? []
                            let Height: [[Double]] = DoubleFile.fromCSV(fileName: "height") ?? []
                            DispatchQueue.main.async{
                                print("Completed")
                                LatLongs.Lat = Lat
                                LatLongs.Long = Long
                                LatLongs.Height = Height
                                Complete1 = true
                            }
                        }
                }
        }
    }
}
