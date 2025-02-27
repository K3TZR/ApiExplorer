//
//  ApiView.swift
//  ApiViewer
//
//  Created by Douglas Adams on 10/06/24.
//

import Foundation
import SwiftUI

//import ClientFeature
//import DirectFeature
import ApiPackage
//import LoginFeature
//import PickerFeature

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

      VSplitView {
        VStack(alignment: .leading) {
          ObjectsView()

          Divider().background(Color(.cyan))
          
          MessagesView()
        }
      }
      Spacer()
      Divider().background(Color(.gray))
      BottomButtonsView()
    }.padding(10)
    
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
      MultiflexView(activeSelection: viewModel.objectModel.activeSelection!)
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
    }

    // LogAlert Notification (an Error or Warning occurred)
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlert)
      .receive(on: RunLoop.main)) { note in
        if viewModel.settingModel.alertOnError {
          viewModel.alertInfo = note.object! as? AlertInfo
          viewModel.showAlert = true
        }
    }

//      .sheet(item: $store.scope(state: \.destination?.directItem, action: \.destination.directItem))
//    { store in DirectView(store: store) }
//
//    .sheet(item: $store.scope(state: \.destination?.loginItem, action: \.destination.loginItem))
//    { store in LoginView(store: store) }
    
    .frame(minWidth: 1300, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(ViewModel())
    
  .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}
