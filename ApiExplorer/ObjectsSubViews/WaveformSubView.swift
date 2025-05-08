//
//  WaveformSubView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 5/7/25.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct WaveformSubView: View {

  @Environment(ViewModel.self) private var viewModel
  

  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
//        HeaderView()

        GridRow {
          Text("Waveforms")
            .frame(width: 70, alignment: .leading)

          Text("----- NOT IMPLEMENTED -----").foregroundColor(.red)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeaderView: View {

  var body: some View {
    
    GridRow {
      Text("Waveforms")
        .frame(width: 70, alignment: .leading)

      Text("Name")
        .frame(width: 50, alignment: .leading)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  WaveformSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

