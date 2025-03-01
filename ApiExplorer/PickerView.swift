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

  private var guiClients: [GuiClient] {
    return viewModel.objectModel.radios
      .flatMap(\.guiClients)
  }

  public var body: some View {
    VStack(alignment: .leading) {
      HeaderView(isGui: viewModel.settingModel.isGui)
      
      if (viewModel.settingModel.isGui && viewModel.objectModel.radios.count == 0) || (!viewModel.settingModel.isGui && guiClients.count == 0) {
       NothingView()
        
      } else if viewModel.settingModel.isGui {
        GuiView()
        
      } else {
        NonGuiView()
      }
    }
    .padding()
  }
}

private struct HeaderView: View {
  let isGui: Bool
  
  var body: some View {
    VStack(alignment: .leading)  {
      HStack {
        Spacer()
        Text("Select a \(isGui ? "RADIO" : "STATION")")
          .font(.title)
        Spacer()
      }
      
      HStack(spacing: 10) {
        Text("\(isGui ? "Radio" : "Station")")
          .frame(width: 140, alignment: .leading)
        
        Text("Type")
          .frame(width: 60, alignment: .leading)
        
        Text("Status")
          .frame(width: 60, alignment: .leading)
        
        Text("\(isGui ? "Station(s)" : "Radio")")
      }
      Divider()
    }
    .font(.title3)
  }
}

private struct NothingView: View {

  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    VStack {
      Spacer()
      
      HStack {
        Spacer()
        Text("----------  NO \(viewModel.settingModel.isGui ? "RADIOS" : "STATIONS") FOUND  ----------")
          .foregroundColor(.red)
        Spacer()
      }
      
      
      FooterView(selectedRadioId: nil, selectedStation: nil)
    }
    .frame(minHeight: 200)
  }
}

private struct GuiView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  @State var selectedRadioId: String? = nil
  @State var selectedStation: String? = nil

  private var guiClients: [GuiClient] {
    return viewModel.objectModel.radios
      .flatMap(\.guiClients)
  }

  private var stations: [String] {
    return guiClients.map(\.self.station)
  }
  
  var body: some View {
    // ----- List of Radios -----
    VStack {
      List(selection: $selectedRadioId) {
        ForEach(viewModel.objectModel.radios.sorted(by: { $0.packet.nickname < $1.packet.nickname }), id: \.id) { radio in
          Button(action: {
            selectedRadioId = radio.id // Manually select the row
            selectedStation = "ApiExplorer"
          }) {
            HStack(spacing: 10) {
              Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname)
                .frame(minWidth: 140, alignment: .leading)
              
              Text(radio.packet.source.rawValue)
                .frame(minWidth: 60, alignment: .leading)
              
              Text(radio.packet.status)
                .frame(minWidth: 60, alignment: .leading)
              
              Text(stations.joined(separator: ", "))
            }
            .font(.title3)
            .foregroundColor(viewModel.settingModel.defaultGui == radio.id ? .red : nil)
            .contentShape(Rectangle()) // Ensures full row is clickable
          }
          .buttonStyle(PlainButtonStyle()) // Removes default button appearance
          .simultaneousGesture(
            TapGesture(count: 2).onEnded {
              dismiss()
              viewModel.pickerConnectButtonTapped(selectedRadioId!, selectedStation!)
            }
          )
        }
      }
      
      FooterView(selectedRadioId: selectedRadioId, selectedStation: selectedStation)
    }
    .frame(minHeight: 200)
  }
}

private struct NonGuiView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  @State var selectedRadioId: String? = nil
  @State var selectedStation: String? = nil

  private var guiClients: [GuiClient] {
    return viewModel.objectModel.radios
      .flatMap(\.guiClients)
  }

  var body: some View {
    VStack {
      // ----- List of Stations -----
      List(selection: $selectedRadioId) {
        ForEach(viewModel.objectModel.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
          ForEach(radio.guiClients, id: \.self) { guiClient in
            Button(action: {
              selectedRadioId = radio.id // Manually select the row
              selectedStation = guiClient.station
            }) {
              HStack(spacing: 10) {
                Text(guiClient.station)
                  .frame(minWidth: 140, alignment: .leading)
                
                Text(radio.packet.source.rawValue)
                  .frame(minWidth: 60, alignment: .leading)
                
                Text(radio.packet.status)
                  .frame(minWidth: 60, alignment: .leading)
                
                Text(radio.packet.nickname)
              }
              .font(.title3)
              .foregroundColor(viewModel.settingModel.defaultNonGui == radio.id ? .red : nil )
              .contentShape(Rectangle()) // Ensures full row is clickable
            }
            .buttonStyle(PlainButtonStyle()) // Removes default button appearance
            .simultaneousGesture(
              TapGesture(count: 2).onEnded {
                dismiss()
                viewModel.pickerConnectButtonTapped(selectedRadioId!, selectedStation!)
              }
            )
          }
        }
      }
      
      FooterView(selectedRadioId: selectedRadioId, selectedStation: selectedStation)
    }
    .frame(minHeight: 200)
  }
}

private struct FooterView: View {
  let selectedRadioId: String?
  let selectedStation: String?
  //  let selectionIsSmartlink: Bool
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    Spacer()
    
    Divider()

    HStack {
      //      Button("Test") { viewModel.testButtonTapped(selection!) }
      //        .disabled(!selectionIsSmartlink)
      //      Circle()
      //        .fill(listenerModel.smartlinkTestResult.success ? Color.green : Color.red)
      //        .frame(width: 20, height: 20)
      
      Button("Default") {
        viewModel.defaultButtonTapped(selectedRadioId!)
      }
      .disabled(selectedRadioId == nil || selectedStation == nil)

      Spacer()
      Button("Cancel") { dismiss() }
        .keyboardShortcut(.cancelAction)
      
      Spacer()
      Button("Connect") {
        viewModel.pickerConnectButtonTapped(selectedRadioId!, selectedStation!)
        dismiss()
      }
      .keyboardShortcut(.defaultAction)
      .disabled(selectedRadioId == nil || selectedStation == nil)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("Picker") {
  PickerView()
  
    .environment(ViewModel())
}
