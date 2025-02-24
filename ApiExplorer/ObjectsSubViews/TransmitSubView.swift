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
    
    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 0) {
      TransmitView(transmit: viewModel.objectModel.transmit)
      CwView(transmit: viewModel.objectModel.transmit)
    }
  }
}

private struct TransmitView: View {
  var transmit: Transmit

  var body: some View {
    
    GridRow {
      Text("PHONE")
        .frame(width: 100, alignment: .leading)
      Group {
        HStack(spacing: 5) {
          Text("Compander")
          Text("\(transmit.companderEnabled ? "ON" : "OFF")").foregroundColor(transmit.companderEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Processor")
          Text("\(transmit.speechProcessorEnabled ? "ON" : "OFF")").foregroundColor(transmit.speechProcessorEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Monitor")
          Text("\(transmit.txMonitorEnabled ? "ON" : "OFF")").foregroundColor(transmit.txMonitorEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Mic Acc")
          Text("\(transmit.micAccEnabled ? "ON" : "OFF")").foregroundColor(transmit.micAccEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Dax")
          Text("\(transmit.daxEnabled ? "ON" : "OFF")").foregroundColor(transmit.daxEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Vox")
          Text("\(transmit.voxEnabled ? "ON" : "OFF")").foregroundColor(transmit.voxEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Vox Delay")
          Text(transmit.voxDelay, format: .number).foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Vox Level")
          Text(transmit.voxLevel, format: .number).foregroundColor(.secondary)
        }
      }.frame(alignment: .leading)
    }
  }
}

private struct CwView: View {
  var transmit: Transmit

  var body: some View {
    
    GridRow {
      Text("CW")
        .frame(width: 100, alignment: .leading)
      
      Group {
        HStack(spacing: 5) {
          Text("Sidetone")
          Text("\(transmit.cwSidetoneEnabled ? "ON" : "OFF")").foregroundColor(transmit.cwSidetoneEnabled ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Level")
          Text(transmit.cwMonitorGain, format: .number).foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Pan")
          Text(transmit.cwMonitorPan, format: .number).foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Pitch")
          Text(transmit.cwPitch, format: .number).foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Speed")
          Text(transmit.cwSpeed, format: .number).foregroundColor(.secondary)
        }
      }.frame(alignment: .leading)
    }
  }
}
  
  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
#Preview {
  TransmitSubView()
    .environment(ViewModel())

    .frame(minWidth: 1250)
}
