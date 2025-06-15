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
  
//  @State private var selectedFilters: Set<String> = []
  @State private var showObjectFilterSettings: Bool = false
  @State private var showStationFilterSettings: Bool = false

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
      if viewMode != .messages {
        HStack {
          Button("RADIO Properties") {showObjectFilterSettings.toggle()}
          Text(settings.radioObjectFilters.map(\.self).joined(separator: ", "))
            .foregroundColor(.secondary)
        }
      }
      
      RadioSubView(radio: radio, viewMode: viewMode)
        .frame(maxWidth: .infinity)
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      if viewMode != .messages {
        HStack {
          Button("STATION Properties") {showStationFilterSettings.toggle()}
          Text(settings.stationObjectFilters.map(\.self).joined(separator: ", ")).foregroundColor(.secondary)
        }
      }
      
      GuiClientSubView(radio: radio, viewMode: viewMode)
        .frame(maxWidth: .infinity)
    }
    
    // Sheet
    .sheet(isPresented: $showObjectFilterSettings) {
      ObjectsFilterView()
        .frame(width: 140, height: 400)
        .padding(10)
    }
    .sheet(isPresented: $showStationFilterSettings) {
      StationsFilterView()
        .frame(width: 140, height: 200)
        .padding(10)
    }
  }
}

public struct ObjectsFilterView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  public var body: some View {
    @Bindable var settings = viewModel.settings

    VStack(alignment: .leading) {
      Text("Choose ONE or MORE")

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Text("all")
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        settings.radioObjectFilters = Set(RadioObjectFilter.allCases.map(\.rawValue))
      }
      
      HStack {
        Text("none")
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        settings.radioObjectFilters.removeAll()
      }

      Divider()
      
      ForEach(RadioObjectFilter.allCases, id: \.self) { item in
        HStack {
          Text(item.rawValue)
          
          Spacer()
          if settings.radioObjectFilters.contains(item.rawValue) {
            Image(systemName: "checkmark")
              .foregroundColor(.accentColor)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          if settings.radioObjectFilters.contains(item.rawValue) {
            settings.radioObjectFilters.remove(item.rawValue)
          } else {
            settings.radioObjectFilters.insert(item.rawValue)
          }
        }
        
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Spacer()
        Button("Close") {
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
      }
    }
  }
}

public struct StationsFilterView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  public var body: some View {
    @Bindable var settings = viewModel.settings

    VStack {
      Text("Choose ONE or MORE")
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Text("all")
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        settings.stationObjectFilters = Set(StationObjectFilter.allCases.map(\.rawValue))
      }
      
      HStack {
        Text("none")
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        settings.stationObjectFilters.removeAll()
      }

      Divider()
      
      ForEach(StationObjectFilter.allCases, id: \.self) { item in
        HStack {
          Text(item.rawValue)
          
          Spacer()
          if settings.stationObjectFilters.contains(item.rawValue) {
            Image(systemName: "checkmark")
              .foregroundColor(.accentColor)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          if settings.stationObjectFilters.contains(item.rawValue) {
            settings.stationObjectFilters.remove(item.rawValue)
          } else {
            settings.stationObjectFilters.insert(item.rawValue)
          }
        }
        
      }

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Spacer()
        Button("Close") {
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView(viewMode: .all)
    .environment(ViewModel(SettingsModel()))
}

// ----------------------------------------------------------------------------
// MARK: - Structs & Enums

public enum RadioObjectFilter: String, CaseIterable, Sendable {
  case amplifiers
  case atu
  case bandSettings = "band settings"
  case cwx
  case equalizers
  case gps
  case interlocks
  case memories
  case meters
  case profiles
  case streams
  case tnfs
  case transmit
  case usbCables
  case wan
  case waveforms
  case xvtrs
}

public enum StationObjectFilter: String, CaseIterable, Sendable {
  case panadapters
  case waterfalls
  case slices
  case meters
  case streams
}
