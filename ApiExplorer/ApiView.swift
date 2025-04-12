//
//  ApiView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/06/24.
//

import Foundation
import SwiftUI

import ApiPackage

public enum ActiveSheet: Identifiable {
  case discovery, guiClients, multiflex, picker, smartlinkLogin, settings
  
  public var id: Int { hashValue }
}

// ----------------------------------------------------------------------------
// MARK: - View

struct ApiView: View {      
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  var isMultiflex: Bool {
    if let selection = viewModel.api.activeSelection {
      if let radio = viewModel.api.radios.first(where: {$0.id == selection.radioId }) {
        return radio.guiClients.count > 1
      }
    }
    return false
  }

  var body: some View {
    @Bindable var viewModel = viewModel

    // primary view
    VStack(alignment: .leading, spacing: 10) {
      TopButtonsView()

      SendView()

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      ObjectsMessagesSplitView()
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      BottomButtonsView()
    }
#if os(macOS)
    .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 600, alignment: .leading)
#endif
    .padding(10)
    
    // initialize
    .onAppear {
      viewModel.onAppear()
    }
    
    // Sheets
    .sheet(item: $viewModel.activeSheet) { sheet in
      switch sheet {
      case .discovery:
        DiscoveryView()
          .frame(width: 500, height: 600)
      case .guiClients:
        GuiClientsView()
          .frame(width: 800, height: 300)
      case .multiflex:
        MultiflexView()
          .frame(width: 300)
      case .picker:
        PickerView()
          .frame(height: 300)
      case .smartlinkLogin:
        SmartlinkLoginView()
      case .settings:
        SettingsView()
      }
    }

    // Alerts
    .alert((viewModel.alertInfo?.title ?? "Alert"), isPresented: $viewModel.showAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(viewModel.alertInfo?.message ?? "")
    }

    // Toolbar
#if os(macOS)
    .toolbar {
      if isMultiflex {
        Text("MultiFlex")
          .foregroundColor(.blue)
          .padding(10)
          .border(Color.blue, width: 2)
      }
      Button("Discovery") {
        viewModel.activeSheet = .discovery
      }
      Button("Gui Clients") {
        viewModel.activeSheet = .guiClients
      }
      if viewModel.api.activeSelection == nil {
        Label( "Settings", systemImage: "gearshape")
          .onTapGesture {
            viewModel.activeSheet = .settings
          }
      }
    }
#endif

    // LogAlert Notification (an Error or Warning occurred)
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlert)
      .receive(on: RunLoop.main)) { note in
        if settings.alertOnError {
          viewModel.alertInfo = note.object! as? AlertInfo
          viewModel.showAlert = true
        }
    }
    .preferredColorScheme(settings.darkMode ? .dark : .light)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
  
    .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}

// ----------------------------------------------------------------------------
// MARK: - Custom Split View

struct ObjectsMessagesSplitView: View {

  var body: some View {
    
    GeometryReader { geometry in
      VStack(spacing: 10) {
        ObjectsView()
          .frame(height: (2 * (geometry.size.height/3)) - 20)
          .frame(maxWidth: .infinity)
        
        MessagesView()
          .frame(height: geometry.size.height/3)
          .frame(maxWidth: .infinity)
      }
      .frame(maxHeight: .infinity)
    }
  }
}
