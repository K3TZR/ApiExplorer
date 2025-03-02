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
  
  @Environment(ViewModel.self) var viewModel
  @Environment(\.dismiss) var dismiss
  
  private var guiClients: [GuiClient] {
    return viewModel.objectModel.radios
      .flatMap(\.guiClients)
  }

  public var body: some View {
    
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)
      Divider().background(Color.blue)
      
      if guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnectButtonTapped()
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150) }
      
      ForEach(guiClients) { guiClient in
        Button("Close " + guiClient.station) {
          viewModel.objectModel.activeSelection?.disconnectHandle = guiClient.handle
          viewModel.multiflexConnectButtonTapped()
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
    .padding(10)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  
  MultiflexView()
    
    .environment(ViewModel())
}

