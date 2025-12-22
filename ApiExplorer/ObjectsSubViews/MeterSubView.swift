//
//  MeterSubView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 3/6/25.
//


import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  // Consistent label width for alignment
  private let labelWidth: CGFloat = 80

  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 5) {
      HeadingView(labelWidth: labelWidth)
      ForEach(viewModel.api.meters.sorted(by: { $0.id < $1.id })) { meter in
        DetailView(meter: meter, labelWidth: labelWidth)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {
  let labelWidth: CGFloat
  
  var body: some View {
    GridRow {
      Text("METERS")
        .frame(width: labelWidth, alignment: .leading)
        .accessibilityLabel("Meters column")

      Text("ID")
      Text("Group")
      Text("Source")
      Text("Name")
      Text("Value")
      Text("Units")
      Text("Fps")
      Text("Description")
    }
    .gridCellAnchor(.leading)
    .foregroundStyle(.yellow)
  }
}

private struct DetailView: View {
  @ObservedObject var meter: Meter
  let labelWidth: CGFloat
  
  func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
    if value > high { return .red }
    if value < low { return .yellow }
    return .green
  }
  
  @State var throttledValue: CGFloat = 0.0
  
  var body: some View {
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        .frame(width: labelWidth)

      Text("\(meter.id)")
        .monospacedDigit()
        .accessibilityLabel("ID: \(meter.id)")
      
      Text(meter.group)
        .accessibilityLabel("Group: \(meter.group)")
      Text(meter.source)
        .accessibilityLabel("Source: \(meter.source)")
      Text(meter.name)
        .accessibilityLabel("Name: \(meter.name)")
      Text(String(format: "%-4.2f", throttledValue))
        .help("        range: \(String(format: "%-4.2f", meter.low)) to \(String(format: "%-4.2f", meter.high))")
        .foregroundStyle(valueColor(meter.value, meter.low, meter.high))
        .onReceive(meter.$value.throttle(for: 1, scheduler: RunLoop.main, latest: true)) { throttledValue = CGFloat($0) }
        .monospacedDigit()
        .accessibilityLabel("Value: \(meter.value)")
      
      Text(meter.units)
        .accessibilityLabel("Units: \(meter.units)")
      Text(String(format: "% 2d", meter.fps))
        .monospacedDigit()
        .accessibilityLabel("Frames per second: \(meter.fps)")
      Text(meter.desc)
        .gridColumnAlignment(.leading)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Description: \(meter.desc)")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MeterSubView()
    .environment(ViewModel(SettingsModel()))

    .frame(width: 1000)
}
