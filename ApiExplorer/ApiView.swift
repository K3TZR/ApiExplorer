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
    .frame(maxWidth: .infinity, alignment: .leading) // <- This makes VStack take full width
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
          .frame(height: 600)
      case .guiClients:
        GuiClientsView()
      case .multiflex:
        MultiflexView()
          .frame(height: 200)
      case .picker:
        PickerView()
          .frame(height: 300)
      case .smartlinkLogin:
        SmartlinkLoginView()
      case .settings:
        SettingsView()
          .frame(width: 400)
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
          .foregroundColor(.red)
      }
      Button("Discovery") {
        viewModel.activeSheet = .discovery
      }
      Button("Gui Clients") {
        viewModel.activeSheet = .guiClients
      }
      Label( "Settings", systemImage: "gearshape")
        .onTapGesture {
          viewModel.activeSheet = .settings
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
  @State private var topHeight: CGFloat = 600  // Initial height for the top view
  let minHeight: CGFloat = 200                 // Minimum height for sections
  
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
#if os(macOS)
          .onHover { hovering in
            NSCursor.resizeUpDown.push()
            if !hovering {
              NSCursor.pop()
            }
          }
#endif
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
