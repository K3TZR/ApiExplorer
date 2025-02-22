//
//  MiscSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/20/22.
//

import SwiftUI

//import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MiscSubView: View {

  @Environment(ViewModel.self) private var viewModel

  @MainActor func list(_ array: [String]) -> String {
    array.formatted(.list(type: .and)).replacingOccurrences(of: ", and ", with: ", ")
  }

  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 30) {
      GridRow {
        Text("Software Version").foregroundColor(.yellow)
        Text(viewModel.objectModel.radio?.softwareVersion ?? "---").foregroundColor(.secondary)
      }
      GridRow {
        Text("Hardware Version").foregroundColor(.yellow)
        Text(viewModel.objectModel.hardwareVersion ?? "---").foregroundColor(.secondary)
      }
      GridRow {
        Text("Antenna List").foregroundColor(.yellow)
        Text(list(viewModel.objectModel.radio?.antList ?? [])).foregroundColor(.secondary)
      }
      GridRow {
        Text("Microphone List").foregroundColor(.yellow)
        Text(list(viewModel.objectModel.radio?.micList ?? [])).foregroundColor(.secondary)
      }
      GridRow {
        Text("Radio Uptime").foregroundColor(.yellow)
        Text(viewModel.objectModel.radio?.uptime ?? 0, format: .number).foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MiscSubView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
