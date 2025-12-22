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
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 0) {
      TransmitView(transmit: viewModel.api.transmit)
      CwView(transmit: viewModel.api.transmit)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
}

private struct TransmitView: View {
  var transmit: Transmit
  
  var body: some View {
    
    GridRow {
      Text("PHONE")
        .frame(width: 50, alignment: .leading)
      
      HStack( spacing: 5) {
        Text("Compander")
        Text("\(transmit.companderEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.companderEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Processor")
        Text("\(transmit.speechProcessorEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.speechProcessorEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Monitor")
        Text("\(transmit.txMonitorEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.txMonitorEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Mic Acc")
        Text("\(transmit.micAccEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.micAccEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Dax")
        Text("\(transmit.daxEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.daxEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Vox")
        Text("\(transmit.voxEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.voxEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Vox Delay")
        Text(transmit.voxDelay, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      
      HStack( spacing: 5) {
        Text("Vox Level")
        Text(transmit.voxLevel, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
  }
}

private struct CwView: View {
  var transmit: Transmit
  
  var body: some View {
    
    GridRow {
      Text("CW")
        .frame(width: 50, alignment: .leading)
      
      HStack( spacing: 5) {
        Text("Sidetone")
        Text("\(transmit.cwSidetoneEnabled ? "ON" : "OFF")")
          .foregroundStyle(transmit.cwSidetoneEnabled ? .green : .red)
      }
      
      HStack( spacing: 5) {
        Text("Level")
        Text(transmit.cwMonitorGain, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      
      HStack( spacing: 5) {
        Text("Pan")
        Text(transmit.cwMonitorPan, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      
      HStack( spacing: 5) {
        Text("Pitch")
        Text(transmit.cwPitch, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
      
      HStack( spacing: 5) {
        Text("Speed")
        Text(transmit.cwSpeed, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TransmitSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

