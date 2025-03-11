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
  
  private var guiClients: [GuiClient] {
    return viewModel.api.radios
      .flatMap(\.guiClients)
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      HeaderView()
      
      Divider()
      
      if guiClients.count == 0 {
        HStack {
          Spacer()
          Text("----------  NO Gui Clients FOUND  ----------")
            .foregroundColor(.red)
          Spacer()
        }
        .frame(minHeight: 150)
        
      } else {
        // ----- List of Gui Clients -----
        List() {
          ForEach(guiClients, id: \.id) { guiClient in
            VStack(alignment: .leading) {
              HStack(spacing: 0) {
                Group {
                  Text(guiClient.station).border(.red)
                  Text(guiClient.handle)
                  Text(guiClient.program)
                  Text(guiClient.ip)
                  Text(guiClient.host)
                }
                .font(.title3)
                .frame(minWidth: 140, alignment: .leading)
              }
              Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)")
            }
          }
        }
        .listStyle(.plain)
        .frame(minHeight: 150)
      }
      Divider()
      FooterView()
    }
    .padding(10)
  }
}

private struct HeaderView: View {
  
  var body: some View {
    VStack {
      Text("Gui Clients").font(.title)
      
      HStack(spacing: 0) {
        Group {
          Text("Station").border(.red)
          Text("Handle")
          Text("Program")
          Text("Ip")
          Text("Host")
        }
        .font(.title3)
        .frame(width: 140, alignment: .leading)
      }
      .padding(.leading, 10)
    }
  }
}

private struct FooterView: View {
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    HStack {
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
    .environment(ViewModel())
}
