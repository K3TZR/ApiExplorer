//
//  ObjectsView.swift
//  ApiViewer/Subviews
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
      
      if viewModel.isConnected == false {
        VSplitView {
          VStack(alignment: .center) {
            Spacer()
            Text("RADIO Objects will be displayed here").frame(maxWidth: .infinity)
            Spacer()
          }
          
          VStack(alignment: .center) {
            Spacer()
            Text("STATION Objects will be displayed here").frame(maxWidth: .infinity)
            Spacer()
          }
          
          if viewModel.settingModel.isGui == false {
            VStack(alignment: .center) {
              Spacer()
              Text("ApiExplorer Objects will be displayed here").frame(maxWidth: .infinity)
              Spacer()
            }
          }
        }
        
      } else {
        VSplitView {
          RadioSubView()
            .frame(maxHeight: 150)
          
          if let radio = viewModel.objectModel.activeSelection?.radio {
            GuiClientSubView(radio: radio)
              .frame(maxHeight: 150)
          }
          
//          if viewModel.settingModel.isGui == true {
//            TesterSubView()
//          }
        }
//        .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment

        .textSelection(.enabled)
        .font(.system(size: CGFloat(viewModel.settingModel.fontSize), weight: .regular, design: .monospaced))
        .padding(.horizontal, 10)
      }
    }
  }
}
  
private struct FilterRadioObjectsView: View {
  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    @Bindable var viewModel = viewModel
    
    Picker("Show RADIO Objects of type", selection: $viewModel.settingModel.radioObjectFilter) {
      ForEach(RadioObjectFilter.allCases, id: \.self) {
        Text($0.rawValue).tag($0)
      }
    }
    .pickerStyle(MenuPickerStyle())
    .frame(width: 300)
  }
}

private struct FilterStationObjectsView: View {
  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    @Bindable var viewModel = viewModel

    Picker("Show STATION Objects of type", selection: $viewModel.settingModel.stationObjectFilter) {
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
  case lists
  case memories
  case meters
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
