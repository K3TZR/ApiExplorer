//
//  CwxSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {

  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    let cwx = viewModel.api.cwx
    
    Grid(alignment: .leading, horizontalSpacing: 40) {
      GridRow {
        Text("CWX")
          .frame(width: 40, alignment: .leading)
                
        HStack(spacing: 5){
          Text("Delay")
          Text(cwx.breakInDelay, format: .number).foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("QSK")
          Text("\(cwx.qskEnabled ? "ON" : "OFF")").foregroundColor(cwx.qskEnabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Speed")
          Text(cwx.wpm, format: .number).foregroundColor(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  CwxSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1250)
}
