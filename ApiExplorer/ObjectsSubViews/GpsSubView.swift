//
//  GpsSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct GpsSubView: View {

  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 5) {
      if let radio = viewModel.api.activeSelection?.radio {
        if radio.gpsPresent {
          HeadingView()
          let gps = viewModel.api.gps
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            Text(gps.altitude)
            Text(gps.frequencyError.formatted(.percent.precision(.fractionLength(4))))
              .gridColumnAlignment(.trailing)
            Text(gps.grid)
            Text(gps.latitude)
            Text(gps.longitude)
            Text(gps.speed)
            Text(gps.time)
            Text(gps.track.formatted(.percent.precision(.fractionLength(4)))).gridColumnAlignment(.trailing)
            Text(gps.tracked ? "Y" : "N").foregroundColor(gps.tracked ? .green : nil)
            Text(gps.visible ? "Y" : "N").foregroundColor(gps.visible ? .green : nil)
          }

        } else {
          GridRow {
            Text("GPS")
              .frame(width: 110, alignment: .leading)

            Text("----- NOT INSTALLED -----").foregroundColor(.red)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {

  var body: some View {
    GridRow {
      Text("GPS")
        .frame(width: 110, alignment: .leading)

      Text("Altitude")
      Text("Frequency Error")
      Text("Latitude")
      Text("Longitude")
      Text("Speed")
      Text("Time")
      Text("Track")
      Text("Tracked")
      Text("Visible")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GpsSubView()
    .environment(ViewModel())

    .frame(width: 1000)
}
