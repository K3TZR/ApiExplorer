//
//  EqualizerSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 8/8/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct EqualizerSubView: View {

  @Environment(ViewModel.self) private var viewModel

  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      ForEach(viewModel.apiModel.equalizers) { eq in
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])

          Text(eq.id)

          Text("\(eq.eqEnabled ? "ON" : "OFF")")
            .foregroundColor(eq.eqEnabled ? .green : .red)
          Text(eq.hz63.formatted(.number))
          Text(eq.hz125.formatted(.number))
          Text(eq.hz250.formatted(.number))
          Text(eq.hz500.formatted(.number))
          Text(eq.hz1000.formatted(.number))
          Text(eq.hz2000.formatted(.number))
          Text(eq.hz4000.formatted(.number))
          Text(eq.hz8000.formatted(.number))
        }
        .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {

  var body: some View {
    GridRow {
      Text("EQUALIZERS")
        .frame(width: 110, alignment: .leading)

      Text("ID")
      Text("Enabled")
      Text("63 Hz")
      Text("125 Hz")
      Text("250 Hz")
      Text("500 Hz")
      Text("1000 Hz")
      Text("2000 Hz")
      Text("4000 Hz")
      Text("8000 Hz")
    }
    .gridCellAnchor(.leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  EqualizerSubView()
    .environment(ViewModel())
  
    .frame(minWidth: 1250)
}
