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
          ForEach(viewModel.api.radios, id:\.id) { radio in
            ForEach(radio.guiClients.sorted(by: {$0.station < $1.station}), id: \.id) { guiClient in
              //            ForEach(guiClients, id: \.id) { guiClient in
              GridRow {
                Text(radio.packet.nickname)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(radio.packet.nickname)
                
                HStack(spacing: 5) {
                  Text(guiClient.station)
                    .truncationMode(.tail)
                    .lineLimit(1)   // This is critical
                    .clipped()
                    .help(guiClient.station)
                  Button(action: {
                    showInfo.toggle()
                  }) {
                    Image(systemName: "info.circle")
                      .foregroundColor(.blue)
                  }
                  .popover(isPresented: $showInfo) {
                    VStack(spacing: 0) {
                      Text("Client ID")
                      Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                      Text(guiClient.clientId?.uuidString ?? "Unknown")
                        .padding()
                    }
                  }
                }
                
                Text(guiClient.program)
                  .truncationMode(.tail)
                  .lineLimit(1)   // This is critical
                  .clipped()
                  .help(guiClient.program)
                
                Text(guiClient.handle)
              }
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
      Text("Program")
      Text("Handle")
    }
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
