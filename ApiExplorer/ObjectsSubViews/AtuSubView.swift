//
//  AtuSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuSubView: View {
  let radio: Radio?
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 5) {
      if let radio {
        if radio.atuPresent {
          let atu = viewModel.api.atu
          GridRow {
            Text("ATU")
              .frame(width: 40, alignment: .leading)
            
            HStack(spacing: 5){
              Text("ATU Enabled")
              Text(atu.enabled ? "Y" : "N")
                .foregroundColor(atu.enabled ? .green : .red)
            }
            
            HStack(spacing: 5){
              Text("Memories Enabled")
              Text(atu.memoriesEnabled ? "Y" : "N")
                .foregroundColor(atu.memoriesEnabled ? .green : .red)
            }
            
            HStack(spacing: 5){
              Text("Using Memories")
              Text(atu.usingMemory ? "Y" : "N")
                .foregroundColor(atu.usingMemory ? .green : .red)
            }
            
            HStack(spacing: 5){
              Text("Tune Status")
              Text(atu.status.rawValue)
                .foregroundColor(.secondary)
            }
          }

        } else {
          GridRow {
            Text("ATU")
              .frame(width: 80, alignment: .leading)
            
            Text("----- NONE -----").foregroundColor(.red)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView(radio: nil)
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}
