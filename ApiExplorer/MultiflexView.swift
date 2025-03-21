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
  
  private var guiClients: [GuiClient] {
    return viewModel.api.radios.filter { $0 == viewModel.api.activeSelection?.radio }
      .flatMap(\.guiClients)
  }

  public var body: some View {
    
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)
      Divider()
      
      if guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnectButtonTapped(nil)
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150)
        
        Button("Close " + guiClients[0].station) {
          viewModel.multiflexConnectButtonTapped(guiClients[0].handle)
        }
        .frame(width: 150)
        
      } else if guiClients.count == 2 {
        Button("Close " + guiClients[0].station) {
          viewModel.multiflexConnectButtonTapped(guiClients[0].handle)
        }
        Button("Close " + guiClients[1].station) {
          viewModel.multiflexConnectButtonTapped(guiClients[1].handle)
        }
      }
    
      Divider()
      
      Button("Cancel") {
        viewModel.multiflexCancelButtonTapped()
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

