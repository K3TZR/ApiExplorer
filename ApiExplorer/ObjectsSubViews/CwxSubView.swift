//
//  CwxSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {

  @Environment(ViewModel.self) var viewModel
  
  // Consistent label width for alignment
  private let labelWidth: CGFloat = 80
  
  var body: some View {
    let cwx = viewModel.api.cwx
    
    Grid(alignment: .leading, horizontalSpacing: 40) {
      GridRow {
        Text("CWX")
          .frame(width: labelWidth, alignment: .leading)
          .foregroundStyle(.yellow)
        
        LabeledValue(label: "Delay", value: cwx.breakInDelay.formatted(), valueColor: .secondary)
        ToggleRow(label: "QSK", isOn: cwx.qskEnabled, onText: "ON", offText: "OFF")
        LabeledValue(label: "Speed", value: cwx.wpm.formatted(), valueColor: .secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// MARK: - Helper Views

private struct ToggleRow: View {
  let label: String
  let isOn: Bool
  var onText: String = "Y"
  var offText: String = "N"
  
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(isOn ? onText : offText)
        .foregroundStyle(isOn ? .green : .red)
        .monospacedDigit()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(label))
    .accessibilityValue(Text(isOn ? "On" : "Off"))
  }
}

private struct LabeledValue: View {
  let label: String
  let value: String
  var valueColor: Color = .primary
  
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(value)
        .foregroundStyle(valueColor)
        .monospacedDigit()
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text(label))
    .accessibilityValue(Text(value))
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  CwxSubView()
    .environment(ViewModel(SettingsModel()))
    .frame(width: 1250)
}
