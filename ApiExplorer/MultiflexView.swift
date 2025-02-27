//
//  MultiflexView.swift
//
//
//  Created by Douglas Adams on 1/19/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct MultiflexView: View {
  let activeSelection: ActiveSelection
  
  @Environment(ViewModel.self) var viewModel
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)
      Divider().background(Color.blue)
      
      if activeSelection.radio.guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnect(activeSelection)
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150) }
      
      ForEach(activeSelection.radio.guiClients) { guiClient in
        Button("Close " + guiClient.station) {
          var adjustedActiveSelection = activeSelection
          adjustedActiveSelection.disconnectHandle = guiClient.handle
          
          viewModel.multiflexConnect( adjustedActiveSelection)
          dismiss()
        }
        .frame(width: 150)
      }
      
      Divider().background(Color.blue)
      
      Button("Cancel") {
        dismiss()
      }
      .keyboardShortcut(.cancelAction)
    }
    .frame(width: 250)
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

//#Preview() {
//  @Previewable @Environment(ViewModel.self) var viewModel
//  
//  MultiflexView(activeSelection: viewModel.objectModel.activeSelection!)
//    
//    .environment(ViewModel())
//}

