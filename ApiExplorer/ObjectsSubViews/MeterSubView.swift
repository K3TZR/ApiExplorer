//
//  MeterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterSubView: View {
//  let sliceId: UInt32?
//  let sliceClientHandle: UInt32?
//  let handle: UInt32
  
  @Environment(ViewModel.self) private var viewModel

//  func showMeter(_ sliceId: UInt32?, _ source: String, _ group: String) -> Bool {
//    if sliceId == nil { return true }
//    if clientHandle != handle { return false }
//    if source != "slc" { return false }
//    if UInt32(group) != sliceId { return false }
//    return true
//  }
  
  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      ForEach(viewModel.objectModel.meters ) { meter in
//        if showMeter(sliceId, meter.source, meter.group) {
          DetailView(meter: meter)
//        }
      }
      .foregroundColor(.secondary)
    }
  }
}

private struct HeadingView: View {
//  let sliceId: UInt32?
  
  var body: some View {
    GridRow {
      Text("METERS")
        .frame(width: 100, alignment: .leading)

      Text("ID")
        .frame(width: 50, alignment: .leading)

      Text("Group")
//        .gridColumnAlignment(.trailing)

      Text("Source")
      Text("Name")
      Text("Value")
//        .gridColumnAlignment(.trailing)

      Text("Units")
      Text("Fps")
//        .gridColumnAlignment(.trailing)
      Text("Description")
        .gridColumnAlignment(.leading)
    }
  }
}

private struct DetailView: View {
  @ObservedObject var meter: Meter
//  let sliceId: UInt32?
  
  func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
    if value > high { return .red }
    if value < low { return .yellow }
    return .secondary
  }
  
  @State var throttledValue: CGFloat = 0.0
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        .frame(width: 100)

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
      Text(meter.desc).foregroundColor(.secondary)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MeterSubView()
    .environment(ViewModel())

    .frame(width: 1250)
}
