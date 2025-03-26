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
      viewModel.api.radios.flatMap { $0.guiClients }
  }

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
          ForEach(viewModel.api.radios, id:\.id) { radio in
            ForEach(radio.guiClients.sorted(by: {$0.station < $1.station}), id: \.id) { guiClient in
              //            ForEach(guiClients, id: \.id) { guiClient in
              GridRow {
                Text(radio.packet.nickname)
                  .frame(width: 120, alignment: .leading)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(radio.packet.nickname)

                Text(guiClient.station)
                  .frame(width: 120, alignment: .leading)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(guiClient.station)
                
                Text(guiClient.handle)
                
                Text(guiClient.program)
                  .frame(width: 120, alignment: .leading)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(guiClient.program)
                
                Text(guiClient.ip)
                  .frame(width: 120, alignment: .leading)
                
                Text(guiClient.host)
                  .frame(width: 120, alignment: .leading)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(guiClient.host)
                
                Text(guiClient.clientId?.uuidString ?? "Unknown")
                  .frame(width: 300, alignment: .leading)
              }
              .monospaced()
              .padding(.horizontal, 10)
            }
          }
        }
      }
      Spacer()
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      FooterView()
    }
  }
}

private struct HeaderView: View {
  
  var body: some View {
    
    GridRow {
      Text("Radio")
      Text("Station")
      Text("Handle")
      Text("Program")
      Text("Ip")
      Text("Host")
      Text("Client Id")
        .frame(width: 150, alignment: .leading)
    }
    .frame(width: 100, alignment: .leading)
    .font(.title3)
    .padding(.leading, 10)
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
    .padding(.trailing, 10)
    .padding(.bottom, 10)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("GuiClientsView") {
  GuiClientsView()
    .environment(ViewModel())
}
