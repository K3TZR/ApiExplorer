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
  
//  private var guiClients: [GuiClient] {
//    return viewModel.api.radios
//      .flatMap(\.guiClients)
//  }
  
  public var body: some View {
    
    VStack(alignment: .center) {
      
      Text("Gui Clients").font(.title)
      
      Grid (alignment: .leading, horizontalSpacing: 0, verticalSpacing: 10) {
        HeaderView()
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)

        if viewModel.api.guiClients.count == 0 {
          HStack {
            Spacer()
            Text("----------  NO Gui Clients FOUND  ----------")
              .foregroundColor(.red)
            Spacer()
          }
          //        .frame(minHeight: 150)
          
        } else {
          // ----- List of Gui Clients -----
          ForEach(viewModel.api.guiClients, id: \.id) { guiClient in
            GridRow {
              Text(guiClient.station)
                .truncationMode(.tail)
                .lineLimit(1)   // This is critical
                .clipped()
                .help(guiClient.station)
              
              Text(guiClient.handle)
              Text(guiClient.program)
                .truncationMode(.tail)
                .lineLimit(1)   // This is critical
                .clipped()
                .help(guiClient.program)
              
              Text(guiClient.ip)
              Text(guiClient.host)
              Text(guiClient.clientId?.uuidString ?? "Unknown")
            }
            .padding(.horizontal, 10)

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
