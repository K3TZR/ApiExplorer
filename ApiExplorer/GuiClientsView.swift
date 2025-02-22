//
//  GuiClientsView.swift
//  ApiViewer
//
//  Created by Douglas Adams on 12/2/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct GuiClientsView: View {

  @Environment(ViewModel.self) private var viewModel

  private var stationCount: Int {
    var count = 0
    
    for radio in viewModel.objectModel.radios {
      for _ in radio.guiClients {
        count += 1
      }
    }
    return count
  }
  
 private var guiClients: [GuiClient] {
    return viewModel.objectModel.radios
      .flatMap(\.guiClients)
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      HeaderView()
      
      Divider()
      
      if stationCount == 0 {
        VStack {
          HStack {
            Spacer()
            Text("----------  NO Gui Clients FOUND  ----------")
              .foregroundColor(.red)
            Spacer()
          }.frame(minWidth: 140, minHeight: 100, alignment: .leading)
        }
        
        
      } else {
        // ----- List of Gui Clients -----
        List() {
//          ForEach(viewModel.objectModel.radios, id: \.id) { radio in
            ForEach(guiClients, id: \.id) { guiClient in
              VStack(alignment: .leading) {
                HStack(spacing: 0) {
                  Group {
                    Text(guiClient.station)
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
//          }
        }.frame(minHeight: 100)
      }
      Divider()
      FooterView()
    }
    .padding(.vertical)
    .frame(minHeight: 250)
  }
}

private struct HeaderView: View {
  
  var body: some View {
    VStack {
      Text("Gui Clients").font(.title2)
      
      HStack(spacing: 0) {
        Group {
          Text("Station")
          Text("Handle")
          Text("Program")
          Text("Ip")
          Text("Host")
        }
        .frame(width: 140, alignment: .leading)
      }
    }
    .padding(.horizontal)
    .font(.title3)
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
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("GuiClientsView") {
  GuiClientsView()
    .environment(ViewModel())
}
