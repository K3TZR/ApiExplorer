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
    
    Grid(alignment: .trailing, horizontalSpacing: 40, verticalSpacing: 0) {
      if viewModel.api.xvtrs.count > 0 {
        HeaderView()
        
        ForEach(viewModel.api.xvtrs, id: \.id) { xvtr in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            
            Text(xvtr.name)
            Text(xvtr.ifFrequency, format: .number)
            Text(xvtr.rfFrequency, format: .number)
            Text(xvtr.maxPower, format: .number)
            Text(xvtr.rxGain, format: .number)
            Text(xvtr.rxOnly ? "Y" : "N")
              .foregroundColor(xvtr.rxOnly ? .red : .green)
          }
//          .foregroundColor(.secondary)
        }
        
      } else {
        GridRow {
          Text("XVTR")
            .frame(width: 40, alignment: .leading)

          Text("----- NONE -----").foregroundColor(.red)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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

