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
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      GridRow {
        Text("Explorer").foregroundColor(.blue)
          .frame(width: 80, alignment: .leading)
          .font(.title)
        
        Text("Bound to Station")
        Text("\(viewModel.api.activeSelection?.station ?? "Unknown")")
          .foregroundColor(.secondary)
        
        Text("Handle")
        Text(viewModel.api.connectionHandle?.hex ?? "???")
          .foregroundColor(.secondary)
        
        Text("Client Id")
        Text("\(viewModel.api.boundClientId ?? "???")")
          .foregroundColor(.secondary)
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
