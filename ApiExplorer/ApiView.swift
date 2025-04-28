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
  case pings, discovery, guiClients, multiflex, picker, smartlinkLogin, settings
  
  public var id: Int { hashValue }
}

public enum ViewMode: String {
  case messages = "rectangle.portrait.bottomhalf.filled"
  case objects = "rectangle.portrait.tophalf.filled"
  case standard = "rectangle.portrait"
}
// ----------------------------------------------------------------------------
// MARK: - View

struct ApiView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
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
      
      ObjectsMessagesSplitView(viewMode: viewModel.settings.viewMode)
      
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
      case .pings:
        PingsView(start: Date())
          .frame(width: 400, height: 180)
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
      // Left side
      ToolbarItem(placement: .navigation) {
        Button(action: {
          viewModel.toggleViewMode()
        }) {
          Image(systemName: viewModel.settings.viewMode.rawValue)
        }
      }
      
      // Middle items (automatic placement)
      ToolbarItemGroup {
        if isMultiflex {
          Text("MultiFlex")
            .foregroundColor(.blue)
            .padding(10)
            .border(Color.blue, width: 2)
        }
        
        Button("Pings") {
          if viewModel.api.activeSelection == nil {
            viewModel.alertInfo = AlertInfo("No Selection", "Please select a radio first")
            viewModel.showAlert = true
          } else {
            viewModel.api.pingIntervalIndex = 0
            viewModel.api.pingIntervals = Array(repeating: 0, count: 60)
            viewModel.activeSheet = .pings
          }
        }
        
        Button("Discovery") {
          viewModel.activeSheet = .discovery
        }
        
        Button("Gui Clients") {
          viewModel.activeSheet = .guiClients
        }
        
        Button(action: {
          if viewModel.api.activeSelection == nil {
            viewModel.activeSheet = .settings
          } else {
            viewModel.alertInfo = AlertInfo("Not Available", "Use only when not connected")
            viewModel.showAlert = true
          }
        }) {
          Label("Settings", systemImage: "gearshape")
        }
      }
    }#endif
    
    // LogAlert Notification (an Error or Warning occurred)
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlert)
      .receive(on: RunLoop.main)) { note in
        if viewModel.settings.alertOnError {
          viewModel.alertInfo = note.object! as? AlertInfo
          viewModel.showAlert = true
        }
      }
      .preferredColorScheme(viewModel.settings.darkMode ? .dark : .light)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
    .padding()
}

// ----------------------------------------------------------------------------
// MARK: - Custom Split View

struct ObjectsMessagesSplitView: View {
  let viewMode: ViewMode
  
  var body: some View {
    
    VStack(spacing: 10) {
      ObjectsView(viewMode: viewMode)
        .frame(maxWidth: .infinity)
      
      if viewMode == .standard || viewMode == .messages {
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        MessagesView()
          .frame(maxWidth: .infinity)
      }
    }
    .frame(maxHeight: .infinity)
  }
}
