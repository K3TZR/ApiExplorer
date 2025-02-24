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
    Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
      if viewModel.objectModel.tnfs.count > 0 {
        HeaderView()
        ForEach(viewModel.objectModel.tnfs, id: \.id) { tnf in
          DetailView(tnf: tnf)
        }
        
      } else {
        GridRow {
          Text("TNFS")
            .frame(width: 100, alignment: .leading)

          Text("----- NONE -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeaderView: View {

  var body: some View {
    GridRow {
      Text("TNFS")
        .frame(width: 100, alignment: .leading)

      Text("ID")
        .frame(width: 50, alignment: .leading)

      Text("Frequency")
      Text("Width")
      Text("Depth")
      Text("Permanent")
    }
  }
}

private struct DetailView: View {
  var tnf: Tnf
  
  func depthName(_ depth: UInt) -> String {
    switch depth {
    case 1: return "Normal"
    case 2: return "Deep"
    case 3: return "Very Deep"
    default:  return "Invalid"
    }
  }
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      
      Text(tnf.id.formatted(.number))
      Text(tnf.frequency, format: .number)
      Text(tnf.width, format: .number)
      Text(depthName(tnf.depth))
      Text(tnf.permanent ? "Yes" : "No")
    }
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TnfSubView()    
    .environment(ViewModel())

    .frame(minWidth: 1250)
}
