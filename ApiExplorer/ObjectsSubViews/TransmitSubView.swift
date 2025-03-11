//
//  TransmitSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct TransmitSubView: View {

  @Environment(ViewModel.self) var viewModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      TransmitView(transmit: viewModel.api.transmit)
      CwView(transmit: viewModel.api.transmit)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct TransmitView: View {
  var transmit: Transmit

  var body: some View {
    
    GridRow {
      Text("PHONE")
        .frame(width: 110, alignment: .leading)
      
      Text("Compander")
      Text("\(transmit.companderEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.companderEnabled ? .green : .red)

      Text("Processor")
      Text("\(transmit.speechProcessorEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.speechProcessorEnabled ? .green : .red)

      Text("Monitor")
      Text("\(transmit.txMonitorEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.txMonitorEnabled ? .green : .red)

      Text("Mic Acc")
      Text("\(transmit.micAccEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.micAccEnabled ? .green : .red)

      Text("Dax")
      Text("\(transmit.daxEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.daxEnabled ? .green : .red)

      Text("Vox")
      Text("\(transmit.voxEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.voxEnabled ? .green : .red)

      Text("Vox Delay")
      Text(transmit.voxDelay, format: .number)
        .foregroundColor(.secondary)

      Text("Vox Level")
      Text(transmit.voxLevel, format: .number)
        .foregroundColor(.secondary)
    }
  }
}

private struct CwView: View {
  var transmit: Transmit
  
  var body: some View {
    
    GridRow {
      Text("CW")
        .frame(width: 110, alignment: .leading)
      
      Text("Sidetone")
      Text("\(transmit.cwSidetoneEnabled ? "ON" : "OFF")")
        .foregroundColor(transmit.cwSidetoneEnabled ? .green : .red)
      
      Text("Level")
      Text(transmit.cwMonitorGain, format: .number)
        .foregroundColor(.secondary)
      
      Text("Pan")
      Text(transmit.cwMonitorPan, format: .number)
        .foregroundColor(.secondary)
      
      Text("Pitch")
      Text(transmit.cwPitch, format: .number)
        .foregroundColor(.secondary)
      
      Text("Speed")
      Text(transmit.cwSpeed, format: .number)
        .foregroundColor(.secondary)
    }
  }
}

  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
#Preview {
  TransmitSubView()
    .environment(ViewModel())

    .frame(minWidth: 1000)
}
