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
  @Environment(SettingsModel.self) private var settings
  
  @State var selectedRadioId: String? = nil
  @State var selectedStation: String = ""
  
  private var guiClients: [GuiClient] {
      viewModel.api.radios.flatMap { $0.guiClients }
  }

  public var body: some View {
    
    VStack(alignment: .leading) {
      
      HeaderView()
      
      if (!settings.isNonGui && viewModel.api.radios.count == 0) || (settings.isNonGui && guiClients.count == 0) {
        NothingView()
      }
      else if !settings.isNonGui {
        GuiView(selectedRadioId: $selectedRadioId)
      }
      else {
        NonGuiView(selectedRadioId: $selectedRadioId, selectedStation: $selectedStation, guiClients: guiClients)
      }
      
      FooterView(selectedRadioId: $selectedRadioId, selectedStation: $selectedStation)
    }
    .padding(10)
  }
}

private struct HeaderView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    
    HStack {
      Spacer()
      Text("Select a \(settings.isNonGui ? "STATION" : "RADIO")")
        .font(.title)
      Spacer()
    }
    
    HStack(spacing: 0) {
      Text("\(settings.isNonGui ? "Station" : "Radio")")
        .frame(width: 200, alignment: .leading)
      
      Text("Type")
        .frame(width: 70, alignment: .leading)
      
      Text("Status")
        .frame(width: 100, alignment: .leading)
      
      Text("\(settings.isNonGui  ?  "Radio" : "Station(s)")")
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
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("----------  NO \(settings.isNonGui ? "STATIONS" : "RADIOS") FOUND  ----------")
          .foregroundColor(.red)
        Spacer()
      }
      Spacer()
    }
  }
}

private struct GuiView: View {
  let selectedRadioId: Binding<String?>
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    
    // ----- List of Radios -----
    List(selection: selectedRadioId) {
      ForEach(viewModel.api.radios.sorted(by: { $0.packet.nickname < $1.packet.nickname }), id: \.id) { radio in
        HStack(spacing: 0) {
          Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname)
            .frame(width: 200, alignment: .leading)
            .truncationMode(.middle)
          
          Text(radio.packet.source.rawValue)
            .frame(width: 70, alignment: .leading)
          
          Text(radio.packet.status)
            .frame(width: 100, alignment: .leading)
          
          Text(radio.packet.guiClientStations.joined(separator: ", "))
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
            .truncationMode(.middle)
        }
        .font(.title3)
        .foregroundColor(settings.defaultGui?.radioId == radio.id ? .red : nil)
      }
    }
    .listStyle(.plain)
  }
}

private struct NonGuiView: View {
  let selectedRadioId: Binding<String?>
  let selectedStation: Binding<String>
  let guiClients: [GuiClient]
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    
    // ----- List of Stations -----
    List(selection: selectedRadioId) {
      ForEach(viewModel.api.radios, id:\.id) { radio in
        ForEach(radio.guiClients.sorted(by: {$0.station < $1.station}), id: \.id) { guiClient in
          if radio.packet.status != "In_Use" {
            VStack {
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
              .font(.title3)
              .foregroundColor(settings.defaultNonGui == PickerSelection(radio.id, guiClient.station, nil) ? .red : nil)
              .overlay(
                Rectangle()
                  .foregroundColor(selectedRadioId.wrappedValue == radio.id ? Color.blue.opacity(0.2) : Color.clear)
              )
              .onTapGesture { // Update selection manually
                selectedRadioId.wrappedValue = radio.id
                selectedStation.wrappedValue = guiClient.station
              }
            }
          }
        }
      }
    }
    .listStyle(.plain)
  }
}

private struct FooterView: View {
  let selectedRadioId: Binding<String?>
  let selectedStation: Binding<String>
  
  @Environment(SettingsModel.self) private var settings
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
      ButtonX(title: "Test") { viewModel.pickerTestButtonTapped(selectedRadioId.wrappedValue!)}
        .disabled(selectedRadioIsNotSmartlink || selectedRadioId.wrappedValue == nil)
      Circle()
        .fill(viewModel.api.smartlinkTestResult.success ? Color.green : Color.red)
        .frame(width: 20, height: 20)
      
      Spacer()
      
      ButtonX(title: "Default") {
        viewModel.pickerDefaultButtonTapped(PickerSelection(selectedRadioId.wrappedValue!, settings.isNonGui ? selectedStation.wrappedValue : settings.stationName, nil))
      }
      .disabled(selectedRadioId.wrappedValue == nil)
      
      Spacer()
      
      ButtonX(title: "Cancel") { dismiss() }
        .keyboardShortcut(.cancelAction)
      
      Spacer()
      
      ButtonX(title: "Connect") {
        //        viewModel.pickerConnectButtonTapped(selectedRadioId.wrappedValue! + "|" + "\(settings.isGui ? settings.stationName : selectedStation.wrappedValue)")
        viewModel.pickerConnectButtonTapped(PickerSelection(selectedRadioId.wrappedValue!, settings.isNonGui ? selectedStation.wrappedValue : settings.stationName, nil))
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
    .environment(ViewModel())
}
