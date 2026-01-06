//
//  TopButtonsView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
//  @State private var daxChanged = false
  @State private var directChanged = false

  private var startButtonDisabled: Bool {
    return !(viewModel.settings.directEnabled || viewModel.settings.localEnabled || viewModel.settings.smartlinkEnabled)
  }
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    HStack(spacing: 0) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
//      .foregroundColor(.primary)
      .disabled(startButtonDisabled)
      
      Spacer()
      
      Toggle("Gui", isOn: $settings.isGui)
        .toggleStyle(CustomToggleStyle())
        .disabled(viewModel.isConnected)
      
      Spacer()
      
      // Connection types
      HStack(spacing: 5) {
        Toggle("Direct", isOn: $settings.directEnabled)
          .onChange(of: settings.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        Toggle("Local", isOn: $settings.localEnabled)
          .onChange(of: settings.localEnabled) {
            viewModel.localButtonChanged($1)
          }
        Toggle("Smartlink", isOn: $settings.smartlinkEnabled)
          .onChange(of: settings.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
      }
      .disabled(viewModel.isConnected)
      .toggleStyle(CustomToggleStyle())
      
      Spacer()
      
      Picker("", selection: $settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .labelsHidden()
//      .disabled(settings.isGui == false)
      .onChange(of: settings.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        Toggle("Rx Audio", isOn: $settings.remoteRxAudioEnabled)
          .disabled(settings.isGui == false)
          .toggleStyle(CustomToggleStyle())
//          .popover(isPresented: $settings.remoteRxAudioEnabled) {
//            NotImplementedView()
//          }
          .onChange(of: settings.remoteRxAudioEnabled) { oldValue, newValue in
            viewModel.remoteRxAudioEnabledButtonChanged(newValue)
          }
        
        Toggle( "Tx Audio", isOn: $settings.remoteTxAudioEnabled)
          .disabled(settings.isGui == false)
          .toggleStyle(CustomToggleStyle())
          .popover(isPresented: $settings.remoteTxAudioEnabled) {
            NotImplementedView()
          }
//          .onChange(of: settings.remoteTxAudioEnabled) {
//            viewModel.remoteTxAudioEnabledButtonChanged($1)
//          }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TopButtonsView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}


public struct CustomToggleStyle: ToggleStyle {
  public func makeBody(configuration: Configuration) -> some View {
    Button(action: {
      configuration.isOn.toggle()
    }) {
      configuration.label
        .padding(.vertical, 1)
        .padding(.horizontal, 12)
        .background(configuration.isOn ? Color.accentColor : Color.accentColor.opacity(0.3))
        .foregroundColor(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
//        .overlay(
//          RoundedRectangle(cornerRadius: 4, style: .continuous)
//            .stroke(Color.accentColor.opacity(configuration.isOn ? 1 : 0.4), lineWidth: 1)
//        )
    }
    .buttonStyle(PlainButtonStyle()) // prevents default button tinting
  }
}

