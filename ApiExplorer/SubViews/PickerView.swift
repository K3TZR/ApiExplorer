//
//  PickerView.swift
//  ViewFeatures/PickerFeature
//
//  Created by Douglas Adams on 11/13/21.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct PickerView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var selectedRadioId: String? = nil
  @State var selectedStation: String = ""
  
  private var guiClients: [GuiClient] {
    viewModel.api.radios.flatMap { $0.guiClients }
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      
      HeaderView()
      
      if (viewModel.settings.isGui && viewModel.api.radios.count == 0) || (!viewModel.settings.isGui && guiClients.count == 0) {
        NothingView()
      }
      else if viewModel.settings.isGui {
        GuiView(selectedRadioId: $selectedRadioId)
      }
      else {
        NonGuiView(selectedRadioId: $selectedRadioId, selectedStation: $selectedStation, guiClients: guiClients)
      }
      
      FooterView(selectedRadioId: $selectedRadioId, selectedStation: $selectedStation)
    }
//    .frame(minHeight: 200)
    .padding(10)
  }
}

private struct HeaderView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    HStack {
      Spacer()
      Text("Select a \(viewModel.settings.isGui ? "RADIO" : "STATION")")
        .font(.title)
      Spacer()
    }
    
    HStack(spacing: 0) {
      Text("\(viewModel.settings.isGui ? "Radio" : "Station")")
        .frame(width: 200, alignment: .leading)
      
      Text("Type")
        .frame(width: 70, alignment: .leading)
      
      Text("Status")
        .frame(width: 100, alignment: .leading)
      
      Text("\(viewModel.settings.isGui  ?  "Station(s)" : "Radio")")
        .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
    }
    .padding(.leading, 10)
    .font(.title3)
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
  }
}

private struct NothingView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("----------  NO \(viewModel.settings.isGui ? "RADIOS" : "STATIONS") FOUND  ----------")
          .foregroundColor(.red)
        Spacer()
      }
      Spacer()
    }
  }
}

private struct GuiView: View {
  @Binding var selectedRadioId: String?
  @Environment(ViewModel.self) private var viewModel

  
  private func isDefaut(_ id: String) -> Bool {
    return id == viewModel.settings.defaultGui?.radioId
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 10) {
        ForEach(viewModel.api.radios.sorted(by: { $0.packet.nickname < $1.packet.nickname }), id: \.id) { radio in
          let isSelected = selectedRadioId == radio.id

          HStack(spacing: 0) {
            Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname)
              .frame(width: 200, alignment: .leading)
              .lineLimit(1)
              .truncationMode(.middle)

            Text(radio.packet.source.rawValue)
              .frame(width: 70, alignment: .leading)

            Text(radio.packet.status)
              .frame(width: 100, alignment: .leading)

            Text(radio.packet.guiClientStations.joined(separator: ", "))
              .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
              .lineLimit(1)
              .truncationMode(.middle)
          }
          .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
          .foregroundColor(isDefaut(radio.id) ? Color.red : nil)
          .cornerRadius(4)
          .contentShape(Rectangle())
          .onTapGesture {
            selectedRadioId = isSelected ? nil : radio.id
          }
        }
      }
      .padding(.horizontal)
    }
    .frame(minHeight: 200)
  }
}

private struct NonGuiView: View {
  let selectedRadioId: Binding<String?>
  let selectedStation: Binding<String>
  let guiClients: [GuiClient]
  
  @Environment(ViewModel.self) private var viewModel
  
  private func isDefaut(_ id: String, _ station: String) -> Bool {
    return id == viewModel.settings.defaultNonGui?.radioId && station == viewModel.settings.defaultNonGui?.station
  }

  var body: some View {
    
    // ----- List of Stations -----
    ScrollView {
      LazyVStack(spacing: 2) {
        ForEach(viewModel.api.radios, id:\.id) { radio in
          ForEach(radio.guiClients.sorted(by: {$0.station < $1.station}), id: \.id) { guiClient in
            
            if radio.packet.status != "In_Use" {
              
              let isSelected = selectedRadioId.wrappedValue == radio.id && selectedStation.wrappedValue == guiClient.station
              
              HStack(spacing: 0) {
                Text(guiClient.station)
                  .frame(width: 200, alignment: .leading)
                  .truncationMode(.middle)
                
                Text(radio.packet.source.rawValue)
                  .frame(width: 70, alignment: .leading)
                
                Text(radio.packet.status)
                  .frame(width: 100, alignment: .leading)
                
                Text(radio.packet.nickname)
                  .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                  .truncationMode(.middle)
              }
              .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
              .foregroundColor(isDefaut(radio.id, guiClient.station) ? Color.red : nil)
              .cornerRadius(4)
              .contentShape(Rectangle()) // Makes entire row tappable
              .onTapGesture {
                selectedRadioId.wrappedValue = isSelected ? nil : radio.id
                selectedStation.wrappedValue = guiClient.station
              }
            }
          }
        }
      }
    }
    .frame(minHeight: 200)
  }
}

private struct FooterView: View {
  let selectedRadioId: Binding<String?>
  let selectedStation: Binding<String>
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var selectedRadioIsNotSmartlink: Bool {
    guard let selectedRadioId = selectedRadioId.wrappedValue else { return false }
    return viewModel.api.radios.first(where: { $0.id == selectedRadioId })?.packet.source != .smartlink
  }
  
  var body: some View {
    Spacer()
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack {
      Button("Test") { viewModel.pickerTestButtonTapped(selectedRadioId.wrappedValue!)}
        .disabled(selectedRadioIsNotSmartlink || selectedRadioId.wrappedValue == nil)
      Circle()
        .fill(viewModel.api.smartlinkTestResult.success ? Color.green : Color.red)
        .frame(width: 20, height: 20)
      
      Spacer()
      
      Button("Default") {
        viewModel.pickerDefaultButtonTapped(PickerSelection(selectedRadioId.wrappedValue!, viewModel.settings.isGui ? viewModel.settings.stationName : selectedStation.wrappedValue, nil))
      }
      .disabled(selectedRadioId.wrappedValue == nil)
      
      Spacer()
      
      Button("Cancel") { dismiss() }
        .keyboardShortcut(.cancelAction)
      
      Spacer()
      
      Button("Connect") {
        viewModel.pickerConnectButtonTapped(PickerSelection(selectedRadioId.wrappedValue!, viewModel.settings.isGui ? viewModel.settings.stationName : selectedStation.wrappedValue, nil))
      }
      .keyboardShortcut(.defaultAction)
      .disabled(selectedRadioId.wrappedValue == nil)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("Picker") {
  PickerView()
    .environment(ViewModel(SettingsModel()))
}
