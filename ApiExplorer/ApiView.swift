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
    @Bindable var vm = viewModel
    @Bindable var settings = vm.settings

    NavigationStack {
      // primary view
      VStack(alignment: .leading, spacing: 10) {
        TopButtonsView()
        
        SendView()
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        ObjectsMessagesSplitView(viewMode: vm.settings.viewMode)
      }
#if os(macOS)
      .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 600, alignment: .leading)
#endif
      .padding(10)

      // initialize
      .task {
        await vm.onAppear()
      }
      
      // Sheets
      .sheet(item: $vm.activeSheet) { sheet in
        apiSheetView(for: sheet)
          .presentationDetents([.medium])
          .environment(vm)
      }
      
      .navigationTitle("ApiExplorer  (v" + Version().string + ")")
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
      
      // Toolbar
      .apiToolbar(viewModel: vm)
      
      // LogAlert Warning Notification
      .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertWarning)
        .receive(on: RunLoop.main)) { note in
          handleLogAlert(note, when: vm.settings.alertOnWarning)
        }

      // LogAlert Error Notification
      .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertError)
        .receive(on: RunLoop.main)) { note in
          handleLogAlert(note, when: vm.settings.alertOnError)
        }
    }
  }
  
  private func handleLogAlert(_ note: Notification, when enabled: Bool) {
    guard enabled, let info = note.object as? AlertInfo else { return }
    viewModel.alertInfo = info
    viewModel.activeSheet = .alert
  }
}

// ----------------------------------------------------------------------------
// MARK: - Sheets

extension ApiView {
  private func apiSheetView(for sheet: ActiveSheet?) -> AnyView {
    switch sheet {
    case .alert:          return AnyView( AlertView(simpleAlert: false) )
    case .simpleAlert:    return AnyView( AlertView(simpleAlert: true) )
    case .pings:          return AnyView( PingsView(start: Date()) )
    case .discovery:      return AnyView( DiscoveryView(radioList: viewModel.api.radios) )
    case .guiClients:     return AnyView( GuiClientsView() )
    case .multiflex:      return AnyView( MultiflexView() )
    case .picker:         return AnyView( PickerView() )
    case .smartlinkLogin: return AnyView( SmartlinkLoginView() )
    case .settings:       return AnyView( SettingsView() )
//    case .about:          return AnyView(AboutView())
    case .none:           return AnyView(EmptyView())
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Toolbar

extension View {
  func apiToolbar(viewModel: ViewModel) -> some View {
    let isMultiflex: Bool = {
      if let activeSelection = viewModel.api.activeSelection,
         let radio = viewModel.api.radios.first(where: { $0.id == activeSelection.radioId }) {
        return radio.guiClients.count > 1
      }
      return false
    }()

    return self.toolbar {
      ToolbarItemGroup(placement: .navigation) {
        Label("Toggle View Mode", systemImage: viewModel.settings.viewMode.rawValue)
          .font(.title2)
          .onTapGesture {
            viewModel.toggleViewMode()
          }
      }

      ToolbarItemGroup(placement: .destructiveAction) {
        if isMultiflex {
          Text("MultiFlex")
            .foregroundStyle(.blue)
            .padding(10)
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .stroke(.blue, lineWidth: 2)
            )
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

