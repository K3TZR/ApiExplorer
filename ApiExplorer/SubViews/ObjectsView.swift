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
      
//      if viewModel.isConnected {
        RadioClientTesterSplitView()
          .textSelection(.enabled)
          .font(.system(size: CGFloat(settings.fontSize), weight: .regular, design: .monospaced))

//      } else {
//        ObjectsEmptyView()
//      }
    }
  }
}
  
//private struct ObjectsEmptyView: View {
//
//  @Environment(SettingsModel.self) private var settings
//
//  var body: some View {
//    
//    VStack(alignment: .center) {
//      Spacer()
//      Text("RADIO Objects will be displayed here").frame(maxWidth: .infinity)
//      Spacer()
//      Text("STATION Objects will be displayed here").frame(maxWidth: .infinity)
//      if settings.isNonGui {
//        Spacer()
//        Text("ApiExplorer Objects will be displayed here").frame(maxWidth: .infinity)
//      }
//      Spacer()
//    }
//  }
//}

private struct RadioClientTesterSplitView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  
//#if os(macOS)
//  @State private var topHeight: CGFloat = 200  // Initial height for the top view
//  let minHeight: CGFloat = 100                 // Minimum height for sections
//#else
//  @State private var topHeight: CGFloat = 50  // Initial height for the top view
//  let minHeight: CGFloat = 25                 // Minimum height for sections
//#endif

  var radio: Radio? {
    if let selection = viewModel.api.activeSelection {
      return viewModel.api.radios.first(where: {$0.id == selection.radioId})
    }
    return nil
  }
  
  var body: some View {

    // Custom resizable vertical split, works for macOS and iOS
    GeometryReader { geometry in
      VStack(spacing: 0) {
        RadioSubView(radio: radio)
          .frame(height: geometry.size.height/2)
          .frame(maxWidth: .infinity)
//          .border(.green)

        Divider()
          .frame(height: 3)
          .background(Color.gray)
//        #if os(macOS)
//          .onHover { hovering in
//            NSCursor.resizeUpDown.push()
//            if !hovering {
//              NSCursor.pop()
//            }
//          }
//        #endif
//          .gesture(
//            DragGesture()
//              .onChanged { value in
//                let newHeight = topHeight + value.translation.height
//                if newHeight > minHeight && newHeight < geometry.size.height - minHeight {
//                  topHeight = newHeight
//                }
//              }
//          )
        
        GuiClientSubView(radio: radio)
          .frame(height: geometry.size.height/2)
          .frame(maxWidth: .infinity)
//          .border(.red)

//        if settings.isNonGui{
//          TesterSubView()
//            .frame(height: 50)
//            .frame(maxWidth: .infinity)
//        }
      }
//      .frame(maxHeight: .infinity)
    }
  }
}

private struct FilterRadioObjectsView: View {
 
  @Environment(SettingsModel.self) private var settings

  var body: some View {
    @Bindable var settings = settings
    
    Picker("RADIO Objects", selection: $settings.radioObjectFilter) {
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

    Picker("STATION Objects", selection: $settings.stationObjectFilter) {
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
