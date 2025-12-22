//
//  WanSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct WanSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 0) {
      GridRow {
        Text("WAN")
          .frame(width: 40, alignment: .leading)
        
        HStack(spacing: 5) {
          Text("Authenticated")
          Text(viewModel.api.wan.radioAuthenticated ? "Y" : "N")
            .foregroundStyle(viewModel.api.wan.radioAuthenticated ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("Server Connected")
          Text(viewModel.api.wan.serverConnected ? "Y" : "N")
            .foregroundStyle(viewModel.api.wan.serverConnected ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("Public TLS Port")
          Text(viewModel.api.wan.publicTlsPort, format: .number)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        
        HStack(spacing: 5) {
          Text("Public UDP Port")
          Text(viewModel.api.wan.publicUdpPort, format: .number)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
      }
      
      GridRow {
        Color.clear
          .frame(width: 40)
          .gridCellUnsizedAxes([.horizontal, .vertical])

        HStack(spacing: 5) {
          Text("Public Upnp TLS Port")
          Text(viewModel.api.wan.publicUpnpTlsPort, format: .number)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }

        HStack(spacing: 5) {
          Text("Public Upnp UDP Port")
          Text(viewModel.api.wan.publicUpnpUdpPort, format: .number)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        
        HStack(spacing: 5) {
          Text("UPNP Supported")
          Text(viewModel.api.wan.upnpSupported ? "Y" : "N")
            .foregroundStyle(viewModel.api.wan.upnpSupported ? .green : .red)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  WanSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

