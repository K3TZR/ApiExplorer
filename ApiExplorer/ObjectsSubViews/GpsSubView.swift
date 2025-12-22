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
  let radio: Radio?

  @Environment(ViewModel.self) var viewModel
  
  // Consistent label width for alignment
  private let labelWidth: CGFloat = 80
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 5) {
      if let radio {
        if radio.gpsPresent {
          headerRow
          let gps = viewModel.api.gps
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            LabeledValue(label: "Altitude", value: gps.altitude, valueColor: .secondary)
            LabeledValue(label: "Frequency Error", value: gps.frequencyError.formatted(.percent.precision(.fractionLength(4))), valueColor: .secondary)
            LabeledValue(label: "Grid", value: gps.grid, valueColor: .secondary)
            LabeledValue(label: "Latitude", value: gps.latitude, valueColor: .secondary)
            LabeledValue(label: "Longitude", value: gps.longitude, valueColor: .secondary)
            LabeledValue(label: "Speed", value: gps.speed, valueColor: .secondary)
            LabeledValue(label: "Time", value: gps.time, valueColor: .secondary)
            LabeledValue(label: "Track", value: gps.track.formatted(.percent.precision(.fractionLength(4))), valueColor: .secondary)
            ToggleRow(label: "Tracked", isOn: gps.tracked, onText: "Y", offText: "N")
            ToggleRow(label: "Visible", isOn: gps.visible, onText: "Y", offText: "N")
          }
        } else {
          GridRow {
            Text("GPS")
              .frame(width: labelWidth, alignment: .leading)
              .foregroundStyle(.yellow)

            Text("----- NOT INSTALLED -----")
              .foregroundStyle(.red)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  private var headerRow: some View {
    GridRow {
      Text("GPS")
        .frame(width: labelWidth, alignment: .leading)
      Text("Altitude")
      Text("Frequency Error")
      Text("Grid")
      Text("Latitude")
      Text("Longitude")
      Text("Speed")
      Text("Time")
      Text("Track")
      Text("Tracked")
      Text("Visible")
    }
    .foregroundStyle(.yellow)
  }
}

// MARK: - Helper Views

private struct ToggleRow: View {
  let label: String
  let isOn: Bool
  var onText: String = "Y"
  var offText: String = "N"
  
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(isOn ? onText : offText)
        .foregroundStyle(isOn ? .green : .red)
        .monospacedDigit()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(label))
    .accessibilityValue(Text(isOn ? "Yes" : "No"))
  }
}

private struct LabeledValue: View {
  let label: String
  let value: String
  var valueColor: Color = .primary
  
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(value)
        .foregroundStyle(valueColor)
        .monospacedDigit()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(label))
    .accessibilityValue(Text(value))
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GpsSubView(radio: nil)
    .environment(ViewModel(SettingsModel()))

    .frame(width: 1000)
}
