//
//  UsbCableSubView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 4/12/25.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct UsbCableSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  private func depthName(_ depth: UInt) -> String {
    switch depth {
    case 1: return "Normal"
    case 2: return "Deep"
    case 3: return "Very Deep"
    default:  return "Invalid"
    }
  }

  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      if viewModel.api.usbCables.count > 0 {
        HeaderView()
        
//        ForEach(viewModel.api.usbCables, id: \.id) { cable in
//          GridRow {
//            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
//            
//            Text(tnf.id.formatted(.number))
//            Text(tnf.frequency, format: .number)
//            Text(tnf.width, format: .number)
//            Text(depthName(tnf.depth))
//            Text(tnf.permanent ? "Y" : "N")
//              .foregroundColor(tnf.permanent ? .green : .red)
//          }
//          .foregroundColor(.secondary)
//        }
        
      } else {
        GridRow {
          Text("USB Cables")
            .frame(width: 110, alignment: .leading)

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
      Text("USB Cables")
        .frame(width: 110, alignment: .leading)

      Text("Name")
        .frame(width: 50, alignment: .leading)

      Text("Serial")
      Text("Enabled")
      Text("Logging")
      Text("Type")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  UsbCableSubView()
    .environment(ViewModel())
  
    .frame(minWidth: 1000)
}
