//
//  TesterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterSubView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
      // Header row
      GridRow {
        Text("Explorer")
          .foregroundStyle(.blue)
          .frame(width: 100, alignment: .leading)
          .font(.title)
        Text("Field")
          .foregroundStyle(.secondary)
        Text("Value")
          .foregroundStyle(.secondary)
        Color.clear
        Color.clear
      }

      // Data row
      GridRow {
        Text("")
          .frame(width: 100, alignment: .leading)

        Text("Bound to Station")
        Text(viewModel.api.activeSelection?.station ?? "Unknown")
          .foregroundStyle(.secondary)

        Text("Handle")
        Text(viewModel.api.connectionHandle?.hex ?? "???")
          .foregroundStyle(.secondary)
          .monospacedDigit()

        Text("Client Id")
        Text(viewModel.api.boundClientId ?? "???")
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TesterSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
