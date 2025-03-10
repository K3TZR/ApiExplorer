//
//  ObjectsView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/07/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct ObjectsView: View {

  @Environment(ViewModel.self) private var viewModel
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      HStack(spacing: 40) {
        FilterRadioObjectsView()
        FilterStationObjectsView()
      }
      
      if viewModel.isConnected {
        RadioClientTesterSplitView()
          .textSelection(.enabled)
          .font(.system(size: CGFloat(SettingsModel.shared.fontSize), weight: .regular, design: .monospaced))
          .padding(.horizontal, 10)

      } else {
        ObjectsEmptyView()
      }
    }
  }
}
  
private struct ObjectsEmptyView: View {

  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    
    VStack(alignment: .center) {
      Spacer()
      Text("RADIO Objects will be displayed here").frame(maxWidth: .infinity)
      Spacer()
      Text("STATION Objects will be displayed here").frame(maxWidth: .infinity)
      if SettingsModel.shared.isGui == false {
        Spacer()
        Text("ApiExplorer Objects will be displayed here").frame(maxWidth: .infinity)
      }
      Spacer()
    }
  }
}

private struct RadioClientTesterSplitView: View {
  @Environment(ViewModel.self) private var viewModel

  @State private var topHeight: CGFloat = 100  // Initial height for the top view

  let minHeight: CGFloat = 100                 // Minimum height for sections
  
  var body: some View {

//#if os(macOS)
//    // Use native `VSplitView` on macOS
//    VSplitView {
//      RadioSubView()
//        .frame(minHeight: 100)
//
//      Divider().frame(height: 2).background(.blue)
//      
//      if let radio = viewModel.api.activeSelection?.radio {
//        GuiClientSubView(radio: radio)
//          .frame(minHeight: 100)
//      }
//      
//      if viewModel.settings.isGui == false {
//        TesterSubView()
//      }
//    }
//
//#else
    // Custom resizable vertical split
    GeometryReader { geometry in
      VStack(spacing: 0) {
        RadioSubView()
          .frame(height: topHeight)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 3)
          .background(Color.blue)
          .onHover { hovering in
            NSCursor.resizeUpDown.push()
            if !hovering {
              NSCursor.pop()
            }
          }
          .gesture(
            DragGesture()
              .onChanged { value in
                let newHeight = topHeight + value.translation.height
                if newHeight > minHeight && newHeight < geometry.size.height - minHeight {
                  topHeight = newHeight
                }
              }
          )
        
        if let radio = viewModel.api.activeSelection?.radio {
          GuiClientSubView(radio: radio)
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
        }

        if SettingsModel.shared.isGui == false {
          TesterSubView()
//            .frame(maxHeight: 50)
            .frame(maxWidth: .infinity)
        }
      }
      .frame(maxHeight: .infinity)
    }
//#endif
  }
}

private struct FilterRadioObjectsView: View {
//  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    @Bindable var settings = SettingsModel.shared
    
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
//  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    @Bindable var settings = SettingsModel.shared

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

  .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}

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
