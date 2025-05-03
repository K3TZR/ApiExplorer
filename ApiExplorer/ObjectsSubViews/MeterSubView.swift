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

  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      ForEach(viewModel.api.meters.sorted(by: {$0.id < $1.id})) { meter in
        DetailView(meter: meter)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {
  
  var body: some View {
    
    GridRow {
      Text("METERS")
        .frame(width: 80, alignment: .leading)

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
  }
}

private struct DetailView: View {
  @ObservedObject var meter: Meter
  
  func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
    if value > high { return .red }
    if value < low { return .yellow }
    return .green
  }
  
  @State var throttledValue: CGFloat = 0.0
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        .frame(width: 80)

      Text("\(meter.id)")
      
      Text(meter.group)
      Text(meter.source)
      Text(meter.name)
      Text(String(format: "%-4.2f", throttledValue))
        .help("        range: \(String(format: "%-4.2f", meter.low)) to \(String(format: "%-4.2f", meter.high))")
        .foregroundColor(valueColor(meter.value, meter.low, meter.high))
        .onReceive(meter.$value.throttle(for: 1, scheduler: RunLoop.main, latest: true)) { throttledValue = CGFloat($0) }
      
      Text(meter.units)
      Text(String(format: "% 2d", meter.fps))
      Text(meter.desc)
        .gridColumnAlignment(.leading)
    }
//    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MeterSubView()
    .environment(ViewModel(SettingsModel()))

    .frame(width: 1000)
}
