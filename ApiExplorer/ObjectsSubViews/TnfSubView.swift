//
//  TnfSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct TnfSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
 var body: some View {
    
    let tnfs = viewModel.api.tnfs.sorted { $0.frequency < $1.frequency }
    
    Grid(alignment: .trailing, horizontalSpacing: 40, verticalSpacing: 0) {
      if !tnfs.isEmpty {
        HeaderView()
        
        ForEach(tnfs, id: \.id) { tnf in
          GridRow {
            Color.clear
              .frame(width: 40)
              .gridCellUnsizedAxes([.horizontal, .vertical])
            
            Text(tnf.id.formatted(.number))
              .monospacedDigit()
            Text(tnf.frequency, format: .number)
              .monospacedDigit()
            Text(tnf.width, format: .number)
              .monospacedDigit()
            Text(tnf.depth.rawValue)
            Text(tnf.permanent ? "Y" : "N")
              .foregroundStyle(tnf.permanent ? .green : .red)
          }
          .accessibilityElement(children: .ignore)
          .accessibilityLabel("ID \(tnf.id), Frequency \(tnf.frequency), Width \(tnf.width), Depth \(tnf.depth.rawValue), Permanent \(tnf.permanent ? "yes" : "no")")
        }
        
      } else {
        GridRow {
          Text("TNFs")
            .frame(width: 40, alignment: .leading)

          Text("No TNFs present").foregroundStyle(.secondary)
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
      Text("TNFs")
        .frame(width: 40, alignment: .leading)

      Text("ID")
        .frame(width: 50, alignment: .leading)

      Text("Frequency")
      Text("Width")
      Text("Depth")
      Text("Permanent")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TnfSubView()    
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

