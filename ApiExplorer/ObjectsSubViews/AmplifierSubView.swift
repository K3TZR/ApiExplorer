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
  let radio: Radio?

  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      if viewModel.api.amplifiers.count > 0 {
        HeadingView()
        ForEach(viewModel.api.amplifiers) { amplifier in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            Text(amplifier.id.hex)
            Text(amplifier.model)
            Text(amplifier.ip)
            Text(amplifier.port, format: .number)
            Text(amplifier.state)
          }
          .foregroundColor(.secondary)
        }
        
      } else {
        GridRow {
          Text("AMPLIFIER")
            .frame(width: 110, alignment: .leading)
          
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {

  var body: some View {
    
    GridRow {
      Text("AMPLIFIER")
        .frame(width: 110, alignment: .leading)

      Text("ID")
      Text("Model")
      Text("Address")
      Text("Port")
      Text("State")
    }
    .gridCellAnchor(.leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AmplifierSubView(radio: nil)
    .environment(ViewModel(SettingsModel()))

    .frame(width: 1250)
}
