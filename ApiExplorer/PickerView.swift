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
  @State var selectedStation: String = "ApiExplorer"
  
  private var guiClients: [GuiClient] {
    return viewModel.api.radios
      .flatMap(\.guiClients)
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      
      HeaderView()
      
      if (settings.isGui && viewModel.api.radios.count == 0) || (!settings.isGui && guiClients.count == 0) {
        NothingView()
      }
      else if settings.isGui {
        GuiView(selectedRadioId: $selectedRadioId)
      }
      else {
        NonGuiView(selectedRadioId: $selectedRadioId, selectedStation: $selectedStation)
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
      Text("Select a \(settings.isGui ? "RADIO" : "STATION")")
        .font(.title)
      Spacer()
    }
    
    HStack(spacing: 0) {
      Text("\(settings.isGui ? "Radio" : "Station")")
        .frame(width: 200, alignment: .leading)
      
      Text("Type")
        .frame(width: 70, alignment: .leading)
      
      Text("Status")
        .frame(width: 100, alignment: .leading)
      
      Text("\(settings.isGui  ? "Station(s)" : "Radio")")
        .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
    }
    .padding(.leading, 10)
    .font(.title3)
    
    Divider()
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
        Text("----------  NO \(settings.isGui ? "RADIOS" : "STATIONS") FOUND  ----------")
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
        .foregroundColor(settings.defaultGui == radio.id ? .red : nil)
      }
    }
    .listStyle(.plain)
  }
}

private struct NonGuiView: View {
  let selectedRadioId: Binding<String?>
  let selectedStation: Binding<String>
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  var body: some View {

    // ----- List of Stations -----
    List {
      ForEach(viewModel.api.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
        ForEach(radio.guiClients, id: \.self) { guiClient in
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
          .foregroundColor(settings.defaultNonGui == radio.id ? .red : nil)
          
          .background(selectedRadioId.wrappedValue == radio.id ? Color.blue.opacity(0.3) : Color.clear) // Highlight selection
          .cornerRadius(8)
          .onTapGesture { // Update selection manually
            selectedRadioId.wrappedValue = radio.id
            selectedStation.wrappedValue = guiClient.station
          }
        }
      }
      .listStyle(.plain)
    }
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
    
    HStack {
      Button("Test") { viewModel.smartlinkTestButtonTapped(selectedRadioId.wrappedValue!)}
        .disabled(selectedRadioIsNotSmartlink || selectedRadioId.wrappedValue == nil)
      Circle()
        .fill(viewModel.api.smartlinkTestResult.success ? Color.green : Color.red)
        .frame(width: 20, height: 20)
      
      Spacer()
      
      Button("Default") {
        viewModel.defaultButtonTapped(selectedRadioId.wrappedValue!)
      }
      .disabled(selectedRadioId.wrappedValue == nil)
      
      Spacer()
      
      Button("Cancel") { dismiss() }
        .keyboardShortcut(.cancelAction)
      
      Spacer()
      
      Button("Connect") {
        viewModel.pickerConnectButtonTapped(selectedRadioId.wrappedValue!, selectedStation.wrappedValue)
//        dismiss()
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
