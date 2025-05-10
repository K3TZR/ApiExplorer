//
//  SettingsView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 3/1/25.
//


import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct SettingsView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  func version() -> String {
    let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
    let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
    return versions + ".\(build)"

  }
  public var body: some View {
    @Bindable var settings = viewModel.settings

    VStack {

      Grid(alignment: .leading) {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("Settings")
            .font(.title)
        }
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        GridRow {
          Text("Station Name")
          TextField("", text: $settings.stationName)
            .frame(width: 200)
        }
        
        GridRow {
          Text("Alert on Error / warning")
          Toggle("", isOn: $settings.alertOnError)
        }
        
        GridRow {
          Text("Clear messages on Start")
          Toggle("", isOn: $settings.clearOnStart)
        }
        
        GridRow {
          Text("Clear messages on Stop")
          Toggle("", isOn: $settings.clearOnStop)
        }
        
        GridRow {
          Text("Discovert Port")
          Picker("", selection: $settings.discoveryPort) {
            Text(4992, format: .number)
              .tag(4992)
            Text(14992, format: .number)
              .tag(14992)
          }
          .labelsHidden()
          .frame(width: 75)
          .onChange(of: settings.discoveryPort) {
            settings.localEnabled = false
          }
        }
        
        GridRow {
          Text("Ignore Gps status")
          Toggle("", isOn: $settings.ignoreGps)
        }
        
        GridRow {
          Text("Low BW Connect")
          Toggle("", isOn: $settings.lowBandwidthConnect)
        }
        
        GridRow {
          Text("Low BW Dax")
          Toggle("", isOn: $settings.lowBandwidthDax)
        }
        
        GridRow {
          Text("Require Smartlink Login")
          Toggle("", isOn: $settings.smartlinkLoginRequired)
        }
        
        GridRow {
          Text("Rx Audio compression")
          Toggle("", isOn: $settings.remoteRxAudioCompressed)
        }
        
        GridRow {
          Text("Tx Audio compression")
          Toggle("", isOn: $settings.remoteTxAudioCompressed)
        }
        
        GridRow {
          Text("Use saved Defaults")
          Toggle("", isOn: $settings.useDefaultEnabled)
        }
        
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      HStack() {
        Text("v" + version())
        Spacer()
        Button("Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
#if os(iOS)
          .buttonStyle(.bordered)
#endif
      }
    }
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("SettingsView") {
  SettingsView()
    .environment(ViewModel(SettingsModel()))
}
