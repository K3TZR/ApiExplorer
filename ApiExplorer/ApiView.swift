//
//  ApiView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/06/24.
//

import Foundation
import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct ApiView: View {      
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  var body: some View {
    @Bindable var viewModel = viewModel

    // primary view
    VStack(alignment: .leading, spacing: 10) {
      TopButtonsView()

      SendView()

      Divider().background(Color(.gray))
            
      ObjectsMessagesSplitView()
      
      Divider().background(Color(.gray))
      
      BottomButtonsView()
    }
    .padding(10)
    
    // initialize
    .onAppear {
      viewModel.onAppear()
    }

    // Sheets
//    .sheet(isPresented: $viewModel.showDirect, onDismiss: {} ) {
//      DirectView()
//    }
    .sheet(isPresented: $viewModel.showDiscovery, onDismiss: {} ) {
      DiscoveryView()
    }
    .sheet(isPresented: $viewModel.showGuiClients, onDismiss: {} ) {
      GuiClientsView()
    }
    .sheet(isPresented: $viewModel.showMultiflex, onDismiss: {} ) {
      MultiflexView()
    }
    .sheet(isPresented: $viewModel.showPicker, onDismiss: {} ) {
      PickerView()
    }
    .sheet(isPresented: $viewModel.showSmartlinkLogin, onDismiss: viewModel.smartlinkLoginDidDismiss) {
      SmartlinkLoginView()
    }

    // Alerts
    .alert((viewModel.alertInfo?.title ?? "Alert"), isPresented: $viewModel.showAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(viewModel.alertInfo?.message ?? "")
    }

    // Toolbar
    .toolbar {
      Button("Discovery") { viewModel.showDiscovery = true }
      Button("Gui Clients") { viewModel.showGuiClients = true }
      SettingsLink{ Label( "Settings", systemImage: "gearshape") }
    }

    // LogAlert Notification (an Error or Warning occurred)
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlert)
      .receive(on: RunLoop.main)) { note in
        if settings.alertOnError {
          viewModel.alertInfo = note.object! as? AlertInfo
          viewModel.showAlert = true
        }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(ViewModel())
  .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}

// ----------------------------------------------------------------------------
// MARK: - Custom Split View

struct ObjectsMessagesSplitView: View {
  @State private var topHeight: CGFloat = 300  // Initial height for the top view
  let minHeight: CGFloat = 100                 // Minimum height for sections
  
  var body: some View {
    
    // Custom resizable vertical split, works for both macOS and iOS
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ObjectsView()
          .frame(height: topHeight)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 3)
          .background(Color.blue)
          .onHover { hovering in
            NSCursor.resizeUpDown.push()
            if !hovering {
              NSCursor.pop()
            }
          }
          .gesture(
            DragGesture()
              .onChanged { value in
                let newHeight = topHeight + value.translation.height
                if newHeight > minHeight && newHeight < geometry.size.height - minHeight {
                  topHeight = newHeight
                }
              }
          )
        
        MessagesView()
          .frame(maxHeight: .infinity)
          .frame(maxWidth: .infinity)
      }
      .frame(maxHeight: .infinity)
    }
  }
}
