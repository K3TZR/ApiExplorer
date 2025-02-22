//
//  MultiflexView.swift
//
//
//  Created by Douglas Adams on 1/19/22.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct MultiflexView: View {
  
  @Environment(ViewModel.self) var viewModel  
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)
      Divider().background(Color.blue)
      
      if viewModel.objectModel.activeSelection!.radio.guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnect()
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150) }
      
      ForEach(viewModel.objectModel.activeSelection!.radio.guiClients) { guiClient in
        Button("Close " + guiClient.station) {
          viewModel.objectModel.activeSelection!.disconnectHandle = guiClient.handle
          viewModel.multiflexConnect()
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

#Preview() {
  MultiflexView()
    .environment(ViewModel())
}

