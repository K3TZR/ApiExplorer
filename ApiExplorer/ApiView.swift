//
//  ApiView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/06/24.
//

import Foundation
import SwiftUI

import ApiPackage

public enum DaxChoice: String, CaseIterable, Sendable {
  case none
  case mic
  case rx0
  case rx1
  case rx2
  case rx3
}


// ----------------------------------------------------------------------------
// MARK: - View

struct ApiView: View {      
  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    @Bindable var viewModel = viewModel

    VStack(alignment: .leading, spacing: 10) {
      TopButtonsView()

      SendView()

      Divider().background(Color(.gray))
            
      ObjectsMessagesSplitView()
      
      Spacer()
      Divider().background(Color(.gray))
      BottomButtonsView()
    }
    .padding(10)
    
    // initialize
    .onAppear {
      viewModel.onAppear()
    }

    // Sheets
    .sheet(isPresented: $viewModel.showDiscovery, onDismiss: {} ) {
      DiscoveryView()
    }
    .sheet(isPresented: $viewModel.showGuiClients, onDismiss: {} ) {
      GuiClientsView()
    }
    .sheet(isPresented: $viewModel.showMultiflex, onDismiss: {} ) {
      MultiflexView()
        .environment(viewModel)
    }
    .sheet(isPresented: $viewModel.showPicker, onDismiss: {} ) {
      PickerView()
        .frame(width: 600, height: 300)
        .padding(10)
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
        if viewModel.settings.alertOnError {
          viewModel.alertInfo = note.object! as? AlertInfo
          viewModel.showAlert = true
        }
    }

//      .sheet(item: $store.scope(state: \.destination?.directItem, action: \.destination.directItem))
//    { store in DirectView(store: store) }
//
//    .sheet(item: $store.scope(state: \.destination?.loginItem, action: \.destination.loginItem))
//    { store in LoginView(store: store) }
    
//    .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  }
}

struct ObjectsMessagesSplitView: View {
  @State private var topHeight: CGFloat = 300  // Initial height for the top view
  let minHeight: CGFloat = 100                 // Minimum height for sections
  
  var body: some View {
#if os(macOS)
    // Use native `VSplitView` on macOS
    VSplitView {
      ObjectsView()
        .frame(minHeight: minHeight)
      
      MessagesView()
        .frame(minHeight: minHeight)
    }
#else
    // Custom resizable vertical split for iOS
    GeometryReader { geometry in
      VStack(spacing: 0) {
        ObjectsView()
          .frame(height: topHeight)
          .frame(maxWidth: .infinity)
          .background(Color.blue.opacity(0.2)) // Just for visualization
        
        Divider()
          .frame(height: 5)
          .background(Color.gray)
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
          .background(Color.green.opacity(0.2)) // Just for visualization
      }
      .frame(maxHeight: .infinity)
    }
#endif
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
