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
//  @Environment(\.dismiss) var dismiss
  
  private var guiClients: [GuiClient] {
    return viewModel.api.radios.filter { $0 == viewModel.api.activeSelection?.radio }
      .flatMap(\.guiClients)
  }

  public var body: some View {
    
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)
      Divider().background(Color.blue)
      
      if guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnectButtonTapped(nil)
//          dismiss()
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150) }
      
      ForEach(guiClients) { guiClient in
        Button("Close " + guiClient.station) {
          viewModel.multiflexConnectButtonTapped(guiClient.handle)
//          dismiss()
        }
        .frame(width: 150)
      }
      
      Divider().background(Color.blue)
      
      Button("Cancel") {
        viewModel.multiflexCancelButtonTapped()
//        dismiss()
      }
      .keyboardShortcut(.cancelAction)
    }
    .padding(10)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  MultiflexView()
    .environment(ViewModel())
}

