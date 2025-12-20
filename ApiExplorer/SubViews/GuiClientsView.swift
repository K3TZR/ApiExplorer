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
    
    VStack(alignment: .leading, spacing: 0) {
      
      HeaderView()
      
      if guiClients.count == 0 {
        NoClientsView()
        
      } else {
        ClientsView(guiClients: guiClients)
      }
      
      FooterView(useSmartlink: $useSmartlink)
    }
    .frame(minHeight: 200)
    .padding()
  }
}

private struct HeaderView: View {
  
  var body: some View {
    
    VStack(alignment: .leading) {
      HStack {
        Spacer()
        Text("Gui Clients").font(.title)
        Spacer()
      }
      
      HStack(spacing: 15) {
        Text("Radio")
          .frame(width: 100, alignment: .leading)
          .border(.red)
        Text("Station")
          .frame(width: 100, alignment: .leading)
        Text("Program")
          .frame(width: 100, alignment: .leading)
        Text("Handle")
        Spacer()
      }
    }
    //    .font(.title3)
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
  }
}

private struct NoClientsView: View {
  
  var body: some View {
    Spacer()
    HStack {
      Spacer()
      Text("----------  NO Gui Clients FOUND  ----------")
        .foregroundColor(.red)
      Spacer()
    }
    Spacer()
  }
}

private struct ClientsView: View {
  let guiClients: [(String, GuiClient)]
  
  var body: some View {
    // ----- List of Gui Clients -----
    //        ScrollView {
    let sortedGuiClients = guiClients.sorted(by: { $0.1.station < $1.1.station })
    ForEach(sortedGuiClients, id: \.1.clientId) { (name, guiClient) in
      VStack(alignment: .leading) {
        HStack(spacing: 15) {
          Text(name)
            .frame(width: 100)
            .lineLimit(1)
            .truncationMode(.tail)
            .help(name)
            .border(.green)
          
          Text(guiClient.station)
            .frame(width: 100)
            .lineLimit(1)
            .truncationMode(.tail)
            .help(guiClient.station)
          
          Text(guiClient.program)
            .frame(width: 100)
            .lineLimit(1)
            .truncationMode(.tail)
            .help(guiClient.program)
          
          Text(guiClient.handle)
        }
        
        HStack {
          Text("Client ID = \(guiClient.clientId?.uuidString ?? "Unknown")")
          Spacer()
        }
        //          .padding(.bottom, 10)
      }
      .frame(minHeight: 200)
    }
  }
}

private struct FooterView: View {
  let useSmartlink: Binding<Bool>
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack {
//      Toggle("Use SmartLink", isOn: useSmartlink)
//        .frame(width: 200)
      HStack(spacing: 5) {
        Text("Use SmartLink: ")
        Toggle("", isOn: useSmartlink)
          .labelsHidden()
      }

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
