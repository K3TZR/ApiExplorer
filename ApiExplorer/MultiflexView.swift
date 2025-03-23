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
  
  public var body: some View {
    
    VStack(spacing: 20) {
      Text("Multiflex").font(.title)

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      if viewModel.api.guiClients.count == 1 {
        Button("MultiFlex connect") {
          viewModel.multiflexConnectButtonTapped(nil)
        }
        .keyboardShortcut(.defaultAction)
        .frame(width: 150)
        
        Button("Close " + viewModel.api.guiClients[0].station) {
          viewModel.multiflexConnectButtonTapped(viewModel.api.guiClients[0].handle)
        }
        .frame(width: 150)
        
      } else if viewModel.api.guiClients.count == 2 {
        Button("Close " + viewModel.api.guiClients[0].station) {
          viewModel.multiflexConnectButtonTapped(viewModel.api.guiClients[0].handle)
        }
        Button("Close " + viewModel.api.guiClients[1].station) {
          viewModel.multiflexConnectButtonTapped(viewModel.api.guiClients[1].handle)
        }
      }
    
      Divider()
        .frame(height: 2)
        .background(Color.gray)

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

