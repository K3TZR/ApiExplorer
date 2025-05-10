//
//  GuiClientsView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 12/2/24.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct GuiClientsView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var useSmartlink: Bool = false
  
  private var guiClients: [(String, GuiClient)] {
    return viewModel.api.radios
        .filter { $0.packet.source == (useSmartlink ? .smartlink : .local) }
        .flatMap { radio in radio.guiClients.map { (radio.packet.nickname, $0) } }
  }
  
  @State var showInfo: Bool = false
  
  public var body: some View {
    
    VStack(alignment: .center) {
      
      Text("Gui Clients").font(.title)
      
      Grid (alignment: .leading, horizontalSpacing: 0, verticalSpacing: 10) {
        HeaderView()
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        if guiClients.count == 0 {
          HStack {
            Spacer()
            Text("----------  NO Gui Clients FOUND  ----------")
              .foregroundColor(.red)
            Spacer()
          }
          //        .frame(minHeight: 150)
          
        } else {
          // ----- List of Gui Clients -----
          let sortedGuiClients = guiClients.sorted(by: { $0.1.station < $1.1.station })
          ForEach(sortedGuiClients, id: \.1.clientId) { (name, guiClient) in
            GridRow {
              Text(name)              
              Text(guiClient.station)
              Text(guiClient.program)
              Text(guiClient.handle)
                            Text(guiClient.clientId?.uuidString ?? "Unknown")
            }
          }
        }
      }
      
      Spacer()
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      FooterView(useSmartlink: $useSmartlink)
    }
    .padding()
  }
}

private struct HeaderView: View {
  
  var body: some View {
    
    GridRow {
      Text("Radio")
      Text("Station")
      Text("Program")
      Text("Handle")
      Text("Client Id")
    }
    .font(.title3)
  }
}

private struct FooterView: View {
  let useSmartlink: Binding<Bool>
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    HStack {
      Toggle("Use SmartLink", isOn: useSmartlink)
        .frame(width: 200)
      Spacer()
      Button("Close") { dismiss() }
        .keyboardShortcut(.defaultAction)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("GuiClientsView") {
  GuiClientsView()
    .environment(ViewModel(SettingsModel()))
}
