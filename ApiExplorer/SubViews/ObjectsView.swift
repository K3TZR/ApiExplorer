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
  @Environment(SettingsModel.self) private var settings

  public var body: some View {
    
    VStack(alignment: .leading) {
      HStack(spacing: 40) {
        FilterRadioObjectsView()
        FilterStationObjectsView()
      }
      
      if viewModel.isConnected {
        RadioClientTesterSplitView()
          .textSelection(.enabled)
          .font(.system(size: CGFloat(settings.fontSize), weight: .regular, design: .monospaced))
          .padding(.horizontal, 10)

      } else {
        ObjectsEmptyView()
      }
    }
  }
}
  
private struct ObjectsEmptyView: View {

  @Environment(SettingsModel.self) private var settings

  var body: some View {
    
    VStack(alignment: .center) {
      Spacer()
      Text("RADIO Objects will be displayed here").frame(maxWidth: .infinity)
      Spacer()
      Text("STATION Objects will be displayed here").frame(maxWidth: .infinity)
      if settings.isGui == false {
        Spacer()
        Text("ApiExplorer Objects will be displayed here").frame(maxWidth: .infinity)
      }
      Spacer()
    }
  }
}

private struct RadioClientTesterSplitView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  @State private var topHeight: CGFloat = 200  // Initial height for the top view

  var radio: Radio? {
    if let selection = viewModel.api.activeSelection {
      return viewModel.api.radios.first(where: {$0.id == selection.radioId})
    }
    return nil
  }

  let minHeight: CGFloat = 100                 // Minimum height for sections
  
  var body: some View {

    // Custom resizable vertical split, works for macOS and iOS
    GeometryReader { geometry in
      VStack(spacing: 0) {
        RadioSubView(radio: radio)
          .frame(height: topHeight)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 3)
          .background(Color.blue)
        #if os(macOS)
          .onHover { hovering in
            NSCursor.resizeUpDown.push()
            if !hovering {
              NSCursor.pop()
            }
          }
        #endif
          .gesture(
            DragGesture()
              .onChanged { value in
                let newHeight = topHeight + value.translation.height
                if newHeight > minHeight && newHeight < geometry.size.height - minHeight {
                  topHeight = newHeight
                }
              }
          )
        
        GuiClientSubView()
          .frame(maxWidth: .infinity)

        if settings.isGui == false {
          TesterSubView()
            .frame(height: 50)
            .frame(maxWidth: .infinity)
        }
      }
      .frame(maxHeight: .infinity)
    }
  }
}

private struct FilterRadioObjectsView: View {
 
  @Environment(SettingsModel.self) private var settings

  var body: some View {
    @Bindable var settings = settings
    
    Picker("Show RADIO Objects of type", selection: $settings.radioObjectFilter) {
      ForEach(RadioObjectFilter.allCases, id: \.self) {
        Text($0.rawValue).tag($0)
      }
    }
    .pickerStyle(MenuPickerStyle())
    .frame(width: 300)
  }
}

private struct FilterStationObjectsView: View {

  @Environment(SettingsModel.self) private var settings

  var body: some View {
    @Bindable var settings = settings

    Picker("Show STATION Objects of type", selection: $settings.stationObjectFilter) {
      ForEach(StationObjectFilter.allCases, id: \.self) {
        Text($0.rawValue).tag($0)
      }
    }
    .pickerStyle(MenuPickerStyle())
    .frame(width: 300)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
}

// ----------------------------------------------------------------------------
// MARK: - Structs & Enums

public enum RadioObjectFilter: String, CaseIterable, Sendable {
  case all
  case atu
  case bandSettings = "band settings"
  case equalizers
  case gps
  case interlocks
  case lists
  case memories
  case meters
  case network
  case tnf
  case transmit
}

public enum StationObjectFilter: String, CaseIterable, Sendable {
  case all
  case noMeters = "w/o meters"
  case amplifiers
  case cwx
  case interlock
  case memories
  case meters
  case misc
  case network
  case profiles
  case streams
  case usbCable
  case wan
  case waveforms
  case xvtrs
}
