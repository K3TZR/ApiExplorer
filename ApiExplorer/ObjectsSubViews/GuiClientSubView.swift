//
//  GuiClientSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  let radio: Radio?
  let viewMode: ViewMode

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    if let radio {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(radio.guiClients, id: \.id) { guiClient in
          Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 0) {
            GridRow {
              Text(guiClient.station)
                .foregroundColor(.yellow)
                .bold()
                .underline()
//                .font(.title)
                .frame(width: 200, alignment: .leading)
                .truncationMode(.tail)
                .lineLimit(1)   // This is critical
                .clipped()
                .help(guiClient.station)
              
              HStack(spacing: 5) {
                Text("Handle")
                Text(guiClient.handle)
                  .foregroundColor(.secondary)
                  .gridColumnAlignment(.trailing)
              }
              
              HStack(spacing: 5) {
                Text("Program")
                Text("\(guiClient.program)")
                  .foregroundColor(.secondary)
                  .gridColumnAlignment(.trailing)
              }
              
              HStack(spacing: 5) {
                Text("LocalPtt")
                Text(guiClient.pttEnabled ? "Y" : "N")
                  .foregroundColor(guiClient.pttEnabled ? .green : .red)
                  .gridColumnAlignment(.trailing)
              }
              
              HStack(spacing: 5) {
                Text("ClientId")
                Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)")
                  .foregroundColor(.secondary)
                  .gridColumnAlignment(.trailing)
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
          
          if viewMode != .messages {
            GuiClientDetailView(filters: viewModel.settings.stationObjectFilters, handle: guiClient.handle.handle!)
            
            if radio.guiClients.last != guiClient {
              Divider()
                .frame(height: 2)
                .background(Color.gray)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
    } else {
      Spacer()
    }
  }
}

private struct GuiClientDetailView: View {
  let filters: Set<String>
  let handle: UInt32
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    ScrollView([.vertical]) {
      VStack(alignment: .leading) {
        PanadapterSubView(handle: handle, filters: filters)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
    .textSelection(.enabled)
    .font(.system(size: CGFloat(viewModel.settings.fontSize), weight: .regular, design: .monospaced))
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

//#Preview {
//  GuiClientSubView()
//    .environment(ViewModel(SettingsModel()))
//  
//    .frame(width: 1250)
//}
