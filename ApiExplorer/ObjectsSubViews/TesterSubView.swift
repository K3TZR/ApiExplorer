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
    
    if viewModel.objectModel.activeSelection != nil {
      Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
        GridRow {
          Text("ApiExplorer").foregroundColor(.blue)
            .frame(width: 110, alignment: .leading)
            .font(.title)
          
            Text("Bound to Station")
            Text("\(viewModel.objectModel.activeSelection!.station)")
              .foregroundColor(.secondary)

          Text("Handle")
            Text(viewModel.objectModel.connectionHandle?.hex ?? "???")
              .foregroundColor(.secondary)

          Text("Client Id")
            Text("\(viewModel.objectModel.boundClientId ?? "???")")
              .foregroundColor(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TesterSubView()    
    .environment(ViewModel())
  
    .frame(minWidth: 1250)
}
