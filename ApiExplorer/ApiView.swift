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
  case alert, simpleAlert, pings, discovery, guiClients, multiflex, picker, smartlinkLogin, settings
  
  public var id: Int { hashValue }
}

public enum ViewMode: String {
  case messages = "arrow.down.square"
  case objects = "arrow.up.square"
  case all = "arrow.up.and.down.square"
}

// ----------------------------------------------------------------------------
// MARK: - View

struct ApiView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = viewModel.settings

    NavigationStack {
      // primary view
      VStack(alignment: .leading, spacing: 10) {
        TopButtonsView()
        
        SendView()
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        ObjectsMessagesSplitView(viewMode: viewModel.settings.viewMode)
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
        apiSheetView(for: sheet)
          .environment(viewModel)
      }
      
      .navigationTitle("ApiExplorer  (v" + Version().string + ")")
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
      
      // Toolbar
      .apiToolbar(viewModel: viewModel)
      
      // LogAlert Warning Notification
      .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertWarning)
        .receive(on: RunLoop.main)) { note in
          if viewModel.settings.alertOnWarning {
            viewModel.alertInfo = note.object! as? AlertInfo
            viewModel.activeSheet = .alert
          }
        }

      // LogAlert Error Notification
      .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertError)
        .receive(on: RunLoop.main)) { note in
          if viewModel.settings.alertOnError {
            viewModel.alertInfo = note.object! as? AlertInfo
            viewModel.activeSheet = .alert
          }
        }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Sheets

extension ApiView {
  @ViewBuilder
  func apiSheetView(for sheet: ActiveSheet?) -> some View {
    switch sheet {
    case .alert:
      AlertView(simpleAlert: false)
    case .simpleAlert:
      AlertView(simpleAlert: true)
    case .pings:
      PingsView(start: Date())
        .frame(width: 400, height: 180)
    case .discovery:
      DiscoveryView()
        .frame(width: 600, height: 600)
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
    case .none:
      EmptyView()
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Toolbar

extension View {
  func apiToolbar(viewModel: ViewModel) -> some View {
    let isMultiflex: Bool = {
      if let selection = viewModel.api.activeSelection,
         let radio = viewModel.api.radios.first(where: { $0.id == selection.radioId }) {
        return radio.guiClients.count > 1
      }
      return false
    }()

    return self.toolbar {
      ToolbarItemGroup(placement: .navigation) {
        Label("", systemImage: viewModel.settings.viewMode.rawValue).font(.title2)
          .onTapGesture {
            viewModel.toggleViewMode()
          }
      }

      ToolbarItemGroup(placement: .destructiveAction) {
        if isMultiflex {
          Text("MultiFlex")
            .foregroundColor(.blue)
            .padding(10)
            .border(Color.blue, width: 2)
        }

        Button("Pings") {
          if viewModel.api.activeSelection == nil {
            viewModel.alertInfo = AlertInfo("No Connection", "Please connect to a radio")
            viewModel.activeSheet = .simpleAlert
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

        Button {
          if viewModel.api.activeSelection == nil {
            viewModel.activeSheet = .settings
          } else {
            viewModel.alertInfo = AlertInfo("Not Available", "Use only when not connected")
            viewModel.activeSheet = .simpleAlert
          }
        } label: {
          Label("Settings", systemImage: "gearshape")
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(ViewModel(SettingsModel()))
#if os(macOS)
    .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
    .padding(10)
#endif
}
