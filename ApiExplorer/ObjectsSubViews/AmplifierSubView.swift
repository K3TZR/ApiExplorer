//
//  AmplifierSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct AmplifierSubView: View {
  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    
    let amplifiers = viewModel.api.amplifiers
    
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      if !amplifiers.isEmpty {
        HeadingView()
        ForEach(amplifiers) { amplifier in
          AmplifierRowView(amplifier: amplifier)
        }
        
      } else {
        GridRow {
          Text("AMP")
            .frame(width: 80, alignment: .leading)
            .accessibilityLabel("Amplifier column")
            .foregroundStyle(.yellow)

          
          Text("----- NONE PRESENT -----")
            .foregroundStyle(.red)
            .accessibilityLabel("None present")
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
}

private struct AmplifierRowView: View {
  let amplifier: Amplifier

  var body: some View {
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(amplifier.id.hex)
        .monospaced()
        .accessibilityLabel("ID: \(amplifier.id.hex)")
      Text(amplifier.model)
        .accessibilityLabel("Model: \(amplifier.model)")
      Text(amplifier.ip)
        .accessibilityLabel("Address: \(amplifier.ip)")
      Text(amplifier.port, format: .number)
        .monospacedDigit()
        .accessibilityLabel("Port: \(amplifier.port)")
      Text(amplifier.state)
        .accessibilityLabel("State: \(amplifier.state)")
    }
    .foregroundStyle(.secondary)
  }
}

private struct HeadingView: View {

  var body: some View {
    
    GridRow {
      Text("AMPLIFIER")
        .frame(width: 80, alignment: .leading)
        .accessibilityLabel("Amplifier column")
      Text("ID")
        .accessibilityLabel("ID column")
      Text("Model")
        .accessibilityLabel("Model column")
      Text("Address")
        .accessibilityLabel("Address column")
      Text("Port")
        .accessibilityLabel("Port column")
      Text("State")
        .accessibilityLabel("State column")
    }
    .gridCellAnchor(.leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AmplifierSubView()
    .environment(ViewModel(SettingsModel()))
    .frame(width: 1250)
}

