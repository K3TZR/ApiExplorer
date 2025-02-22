//
//  GpsSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

//import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct GpsSubView: View {

  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      if let radio = viewModel.objectModel.radio {
        if radio.gpsPresent {
          HeadingView()
          DetailView(gps: viewModel.objectModel.gps)
          
        } else {
          GridRow {
            Text("GPS")
              .frame(width: 100, alignment: .leading)

            Text("----- NOT INSTALLED -----").foregroundColor(.red)
          }
        }
      }
    }
  }
}

private struct HeadingView: View {

  var body: some View {
    GridRow {
      Text("GPS")
        .frame(width: 100)

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
/*
 public var altitude = ""
 public var frequencyError: Double = 0
 public var grid = ""
 public var installed = false
 public var latitude = ""
 public var longitude = ""
 public var speed = ""
 public var time = ""
 public var track: Double = 0
 public var tracked = false
 public var visible = false

 */
private struct DetailView: View {
  var gps: Gps

  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(gps.altitude)
      Text(gps.frequencyError.formatted(.percent.precision(.fractionLength(4)))).gridColumnAlignment(.trailing)
      Text(gps.grid)
      Text(gps.latitude)
      Text(gps.longitude)
      Text(gps.speed)
      Text(gps.time)
      Text(gps.track.formatted(.percent.precision(.fractionLength(4)))).gridColumnAlignment(.trailing)
      Text(gps.tracked ? "Y" : "N").foregroundColor(gps.tracked ? .green : nil)
      Text(gps.visible ? "Y" : "N").foregroundColor(gps.visible ? .green : nil)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GpsSubView()
    .environment(ViewModel())

    .frame(width: 1250)
}
