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

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 5) {
      if let radio = viewModel.objectModel.activeSelection?.radio {
        if radio.atuPresent {
          DetailView(atu: viewModel.objectModel.atu)
          
        } else {
          GridRow {
            Text("ATU")
              .frame(width: 100, alignment: .leading)
            
            Text("----- NONE -----").foregroundColor(.red)
          }
        }
      }
    }
  }
}

private struct DetailView: View {
  var atu: Atu

  var body: some View {
    GridRow {
      Text("ATU")
        .frame(width: 100, alignment: .leading)
      
      HStack(spacing: 5){
        Text("ATU Enabled")
        Text(atu.enabled ? "Y" : "N").foregroundColor(atu.enabled ? .green : .red)
      }
      
      HStack(spacing: 5){
        Text("Memories Enabled")
        Text(atu.memoriesEnabled ? "Y" : "N").foregroundColor(atu.memoriesEnabled ? .green : .red)
      }
      
      HStack(spacing: 5){
        Text("Using Memories")
        Text(atu.usingMemory ? "Y" : "N").foregroundColor(atu.usingMemory ? .green : .red)
      }
      HStack(spacing: 5){
        Text("Tune Status")
        Text(atu.status.rawValue).foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView()  
    .environment(ViewModel())
  
    .frame(width: 1250)
}
