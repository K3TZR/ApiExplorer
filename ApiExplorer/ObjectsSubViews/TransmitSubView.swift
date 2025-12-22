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
    Group {
      let transmit = viewModel.api.transmit
      Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 0) {
        header
        TransmitView(transmit: transmit)
        CwView(transmit: transmit)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
  
  @ViewBuilder
  private var header: some View {
    GridRow {
      Text("Xmit")
        .frame(width: 50, alignment: .leading)
//      Text("Setting")
//        .foregroundStyle(.secondary)
      Color.clear
      Color.clear
      Color.clear
      Color.clear
      Color.clear
      Color.clear
      Color.clear
      Color.clear
    }
  }
}

private struct TransmitView: View {
  var transmit: Transmit
  
  @ViewBuilder
  private func onOffBadge(_ isOn: Bool) -> some View {
    Text(isOn ? "ON" : "OFF")
      .foregroundStyle(isOn ? .green : .red)
      .accessibilityLabel(isOn ? "On" : "Off")
  }
  
  var body: some View {
    
    GridRow {
      Color.clear
        .frame(width: 50, alignment: .leading)
      
      Text("PHONE")
        .frame(width: 50, alignment: .leading)

      HStack(spacing: 6) {
        Text("Compander")
        onOffBadge(transmit.companderEnabled)
      }

      HStack(spacing: 6) {
        Text("Processor")
        onOffBadge(transmit.speechProcessorEnabled)
      }

      HStack(spacing: 6) {
        Text("Monitor")
        onOffBadge(transmit.txMonitorEnabled)
      }

      HStack(spacing: 6) {
        Text("Mic Acc")
        onOffBadge(transmit.micAccEnabled)
      }

      HStack(spacing: 6) {
        Text("Dax")
        onOffBadge(transmit.daxEnabled)
      }

      HStack(spacing: 6) {
        Text("Vox")
        onOffBadge(transmit.voxEnabled)
      }

      HStack(spacing: 6) {
        Text("Vox Delay")
        Text(transmit.voxDelay, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }

      HStack(spacing: 6) {
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
  
  @ViewBuilder
  private func onOffBadge(_ isOn: Bool) -> some View {
    Text(isOn ? "ON" : "OFF")
      .foregroundStyle(isOn ? .green : .red)
      .accessibilityLabel(isOn ? "On" : "Off")
  }
  
  var body: some View {
    
    GridRow {
      Color.clear
        .frame(width: 50, alignment: .leading)
      
      Text("CW")
        .frame(width: 50, alignment: .leading)

      HStack(spacing: 6) {
        Text("Sidetone")
        onOffBadge(transmit.cwSidetoneEnabled)
      }

      HStack(spacing: 6) {
        Text("Level")
        Text(transmit.cwMonitorGain, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }

      HStack(spacing: 6) {
        Text("Pan")
        Text(transmit.cwMonitorPan, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }

      HStack(spacing: 6) {
        Text("Pitch")
        Text(transmit.cwPitch, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }

      HStack(spacing: 6) {
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

