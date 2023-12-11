//
//  index.swift
//  Demo3dUI2
//
//  Created by Leonard Maculo on 12/7/23.
//

import SwiftUI

struct index: View {
    @EnvironmentObject var Latitude: LatLong
    var body: some View {
        NavigationStack {
            NavigationLink(destination: nasaapptest().environmentObject(Latitude), label: {
                Text("2D map")
            })
            NavigationLink(destination: Demo3dUI2(heightData: Latitude.Height).environmentObject(Latitude), label: {
                Text("3D map")
            })
        }
    }
}

#Preview {
    index()
}
