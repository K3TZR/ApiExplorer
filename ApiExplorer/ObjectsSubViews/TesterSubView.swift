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
    
    if viewModel.isConnected && viewModel.settingModel.isGui == false {
      VStack(alignment: .leading) {
        HStack(spacing: 20) {
          
          Text("SDRApi").foregroundColor(.green)
            .font(.title)
          
          HStack(spacing: 5) {
            Text("Bound to Station")
            Text("\(viewModel.objectModel.activeSelection!.station)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Handle")
            Text(viewModel.objectModel.connectionHandle?.hex ?? "???").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Client Id")
            Text("\(viewModel.objectModel.boundClientId ?? "???")").foregroundColor(.secondary)
          }
        }
      }.frame(maxWidth: .infinity, minHeight: 50)
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
