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

  @Environment(ViewModel.self) private var viewModel
//  @Environment(SettingsModel.self) private var settings

  var radio: Radio? {
    if let selection = viewModel.api.activeSelection {
      return viewModel.api.radios.first(where: {$0.id == selection.radioId})
    }
    return nil
  }

  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    // Custom vertical split, works for macOS and iOS
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: 10) {
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
        
        RadioSubView(radio: radio)
          .frame(height: (geometry.size.height/2) - 40)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
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
        
        GuiClientSubView(radio: radio)
          .frame(height: (geometry.size.height/2) - 40)
          .frame(maxWidth: .infinity)
      }
    }
    .textSelection(.enabled)
    .font(.system(size: CGFloat(settings.fontSize), weight: .regular, design: .monospaced))
  }
}
  
//private struct RadioClientTesterSplitView: View {
//  
//  @Environment(ViewModel.self) private var viewModel
//  @Environment(SettingsModel.self) private var settings
//  
//  var radio: Radio? {
//    if let selection = viewModel.api.activeSelection {
//      return viewModel.api.radios.first(where: {$0.id == selection.radioId})
//    }
//    return nil
//  }
//  
//  var body: some View {
//    @Bindable var settings = settings
//
//    // Custom resizable vertical split, works for macOS and iOS
//    GeometryReader { geometry in
//      VStack(alignment: .leading, spacing: 0) {
//        Picker("RADIO Objects", selection: $settings.radioObjectFilter) {
//          ForEach(RadioObjectFilter.allCases, id: \.self) {
//            Text($0.rawValue).tag($0)
//          }
//        }
//        .pickerStyle(MenuPickerStyle())
//        .frame(width: 300)
//
//        RadioSubView(radio: radio)
//          .frame(height: geometry.size.height/2)
//          .frame(maxWidth: .infinity)
//
//        Divider()
//          .frame(height: 3)
//          .background(Color.gray)
//        
//        Picker("STATION Objects", selection: $settings.stationObjectFilter) {
//          ForEach(StationObjectFilter.allCases, id: \.self) {
//            Text($0.rawValue).tag($0)
//          }
//        }
//        .pickerStyle(MenuPickerStyle())
//        .frame(width: 300)
//
//        GuiClientSubView(radio: radio)
//          .frame(height: geometry.size.height/2)
//          .frame(maxWidth: .infinity)
//      }
//    }
//  }
//}

//private struct FilterRadioObjectsView: View {
// 
//  @Environment(SettingsModel.self) private var settings
//
//  var body: some View {
//    @Bindable var settings = settings
//    
//    Picker("RADIO Objects", selection: $settings.radioObjectFilter) {
//      ForEach(RadioObjectFilter.allCases, id: \.self) {
//        Text($0.rawValue).tag($0)
//      }
//    }
//    .pickerStyle(MenuPickerStyle())
//    .frame(width: 300)
//  }
//}
//
//private struct FilterStationObjectsView: View {
//
//  @Environment(SettingsModel.self) private var settings
//
//  var body: some View {
//    @Bindable var settings = settings
//
//    Picker("STATION Objects", selection: $settings.stationObjectFilter) {
//      ForEach(StationObjectFilter.allCases, id: \.self) {
//        Text($0.rawValue).tag($0)
//      }
//    }
//    .pickerStyle(MenuPickerStyle())
//    .frame(width: 300)
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView()
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
