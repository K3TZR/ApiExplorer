//
//  PickerView.swift
//  ViewFeatures/PickerFeature
//
//  Created by Douglas Adams on 11/13/21.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct PickerView: View {

  @Environment(ViewModel.self) private var viewModel
  
  @State var selection: String? = nil

  private var stationCount: Int {
    var count = 0

    for radio in viewModel.objectModel.radios {
      for _ in radio.guiClients {
        count += 1
      }
    }
    return count
  }

  public var body: some View {
    VStack(alignment: .leading) {
      HeaderView(isGui: viewModel.settingModel.isGui)
      
      Divider()
      if (viewModel.settingModel.isGui && viewModel.objectModel.radios.count == 0) || (!viewModel.settingModel.isGui && stationCount == 0) {
        //
        VStack {
          HStack {
            Spacer()
            Text("----------  NO \(viewModel.settingModel.isGui ? "RADIOS" : "STATIONS") FOUND  ----------")
              .foregroundColor(.red)
            Spacer()
          }
        }
        .frame(minHeight: 200)
        
        
      } else {
        if viewModel.settingModel.isGui {
          // ----- List of Radios -----
          List(selection: $selection) {
            ForEach(viewModel.objectModel.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
              HStack(spacing: 0) {
                Group {
                  Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname)
                  Text(radio.packet.source.rawValue)
                  Text(radio.packet.status)
                  Text(radio.packet.stations.joined(separator: ", "))
                }
                .font(.title3)
                .foregroundColor(viewModel.settingModel.defaultGui == radio.id ?.red : nil )
                .frame(minWidth: 140, alignment: .leading)
              }
            }
          }.frame(minHeight: 200)
          
        } else {
          // ----- List of Stations -----
          List(selection: $selection) {
            ForEach(viewModel.objectModel.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
              //              HStack(spacing: 0) {
              ForEach(Array(radio.guiClients), id: \.id) { guiClient in
                HStack(spacing: 0) {
                  Group {
                    Text(guiClient.station)
                    Text(radio.packet.source.rawValue)
                    Text(radio.packet.status)
                    Text(radio.packet.nickname)
                  }
                  .font(.title3)
                  .foregroundColor(viewModel.settingModel.defaultNonGui == radio.id ?.red : nil )
                  .frame(minWidth: 140, alignment: .leading)
                  //                  }
                }
              }
            }
          }.frame(minHeight: 200)
        }
      }
      Divider()
      //    FooterView(selection: selection, selectionIsSmartlink: isSmartlink)
      FooterView(selection: selection)
    }
  }
}

private struct HeaderView: View {
  let isGui: Bool
  
  var body: some View {
    VStack {
      Text("Select a \(isGui ? "RADIO" : "STATION")")
        .font(.title)
      
      HStack(spacing: 0) {
        Group {
          Text("\(isGui ? "Radio" : "Station")")
          Text("Type")
          Text("Status")
          Text("\(isGui ? "Station(s)" : "Radio")")
        }
        .frame(width: 140, alignment: .leading)
      }
    }
    .font(.title2)
    .padding(.horizontal)
  }
}

private struct FooterView: View {
  let selection: String?
  //  let selectionIsSmartlink: Bool
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    
    HStack(){
      //      Button("Test") { viewModel.testButtonTapped(selection!) }
      //        .disabled(!selectionIsSmartlink)
      //      Circle()
      //        .fill(listenerModel.smartlinkTestResult.success ? Color.green : Color.red)
      //        .frame(width: 20, height: 20)
      
      Spacer()
      Button("Default") {
        viewModel.defaultButtonTapped(selection!)
      }
      .disabled(selection == nil)
      
      Spacer()
      Button("Cancel") { dismiss() }
        .keyboardShortcut(.cancelAction)
      
      Spacer()
      Button("Connect") {
        viewModel.pickerConnectButtonTapped(selection!)
        dismiss()
      }
      .keyboardShortcut(.defaultAction)
      .disabled(selection == nil)
    }
    .padding(.vertical, 10)
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("Picker") {
  PickerView()
    .environment(ViewModel())
}
