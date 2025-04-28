//
//  ObjectsView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/07/24.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

public struct ObjectsView: View {
  let viewMode: ViewMode
  
  @Environment(ViewModel.self) private var viewModel
  
  var radio: Radio? {
    if let selection = viewModel.api.activeSelection {
      return viewModel.api.radios.first(where: {$0.id == selection.radioId})
    }
    return nil
  }
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    // Custom vertical split, works for macOS and iOS
    VStack(alignment: .leading, spacing: 10) {
      if viewMode == .standard || viewMode == .objects {
        HStack {
          Text("RADIO Objects")
            .frame(width: 130, alignment: .leading)
          
          Picker("", selection: $settings.radioObjectFilter) {
            ForEach(RadioObjectFilter.allCases, id: \.self) {
              Text($0.rawValue.capitalized).tag($0)
            }
          }
          .pickerStyle(MenuPickerStyle())
          .frame(width: 180)
        }
      }
      
      RadioSubView(radio: radio, viewMode: viewMode)
        .frame(maxWidth: .infinity)
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      if viewMode == .standard || viewMode == .objects {
        HStack {
          Text("STATION Objects")
            .frame(width: 130, alignment: .leading) // Fixed width label
          
          Picker("", selection: $settings.stationObjectFilter) {
            ForEach(StationObjectFilter.allCases, id: \.self) {
              Text($0.rawValue).tag($0)
            }
          }
          .pickerStyle(MenuPickerStyle())
          .frame(width: 180)
        }
      }
      
      GuiClientSubView(radio: radio, viewMode: viewMode)
        .frame(maxWidth: .infinity)
    }
    .textSelection(.enabled)
    .font(.system(size: CGFloat(settings.fontSize), weight: .regular, design: .monospaced))
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView(viewMode: .standard)
    .environment(ViewModel(SettingsModel()))
}

// ----------------------------------------------------------------------------
// MARK: - Structs & Enums

public enum RadioObjectFilter: String, CaseIterable, Sendable {
  case all
  case amplifiers
  case atu
  case bandSettings = "band settings"
  case cwx
  case equalizers
  case gps
  case interlocks
  case lists
  case memories
  case meters
  case network
  case profiles
  case tnf
  case transmit
  case usbCable
  case wan
  case waveforms
  case xvtrs
}

public enum StationObjectFilter: String, CaseIterable, Sendable {
  case all
  case noMeters = "w/o meters"
  case streams
}
