//
//  XvtrSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 4/12/25.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct XvtrSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    let xvtrs = viewModel.api.xvtrs.sorted { $0.rfFrequency < $1.rfFrequency }
    
    Grid(alignment: .trailing, horizontalSpacing: 40, verticalSpacing: 0) {
      if !xvtrs.isEmpty {
        HeaderView()
        
        ForEach(xvtrs, id: \.id) { xvtr in
          GridRow {
            Color.clear
              .frame(width: 40)
              .gridCellUnsizedAxes([.horizontal, .vertical])
            
            Text(xvtr.name)
            Text(xvtr.ifFrequency, format: .number).monospacedDigit()
            Text(xvtr.rfFrequency, format: .number).monospacedDigit()
            Text(xvtr.maxPower, format: .number).monospacedDigit()
            Text(xvtr.rxGain, format: .number).monospacedDigit()
            Text(xvtr.rxOnly ? "Y" : "N")
              .foregroundStyle(xvtr.rxOnly ? .red : .green)
          }
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("Name \(xvtr.name), IF \(xvtr.ifFrequency), RF \(xvtr.rfFrequency), Max Power \(xvtr.maxPower), Rx Gain \(xvtr.rxGain), Rx Only \(xvtr.rxOnly ? "yes" : "no")")
        }
        
      } else {
        GridRow {
          Text("XVTR")
            .frame(width: 40, alignment: .leading)

          Text("No transverters present").foregroundStyle(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
}

private struct HeaderView: View {

  var body: some View {
    
    GridRow {
      Text("XVTR")
        .frame(width: 40, alignment: .leading)

      Text("Name")
        .frame(width: 50, alignment: .leading)

      Text("If Frequency")
      Text("Rf Frequency")
      Text("Max Power")
      Text("Rx Gain")
      Text("Rx Only")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  XvtrSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

