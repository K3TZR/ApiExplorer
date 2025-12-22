//
//  InterlockSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/1/22.
//

import SwiftUI

import ApiPackage

struct InterlockSubView: View {
  
  @Environment(ViewModel.self) var viewModel
  
  // Consistent label width for alignment
  private let labelWidth: CGFloat = 80
  
  var body: some View {
    let interlock = viewModel.api.interlock
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      GridRow {
        Text("INTLCK")
          .frame(width: labelWidth, alignment: .leading)
          .foregroundStyle(.yellow)
        
        ToggleRow(label: "Tx Allowed", isOn: interlock.txAllowed)
        ToggleRow(label: "Tx1 Enabled", isOn: interlock.tx1Enabled)
        ToggleRow(label: "Tx2 Enabled", isOn: interlock.tx2Enabled)
        ToggleRow(label: "Tx3 Enabled", isOn: interlock.tx3Enabled)
        ToggleRow(label: "Acc Tx", isOn: interlock.accTxEnabled)
        ToggleRow(label: "Acc Req", isOn: interlock.accTxReqEnabled)
        ToggleRow(label: "Rca Req", isOn: interlock.rcaTxReqEnabled)
      }
      
      GridRow {
        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        
        LabeledValue(label: "Delay", value: interlock.txDelay.formatted(), valueColor: .secondary)
        LabeledValue(label: "Delay", value: interlock.tx1Delay.formatted(), valueColor: .secondary)
        LabeledValue(label: "Delay", value: interlock.tx2Delay.formatted(), valueColor: .secondary)
        LabeledValue(label: "Delay", value: interlock.tx3Delay.formatted(), valueColor: .secondary)
        LabeledValue(label: "Delay", value: interlock.accTxDelay.formatted(), valueColor: .secondary)
        LabeledValue(label: "Polarity", value: interlock.accTxReqPolarity ? "+" : "-", valueColor: .secondary)
        LabeledValue(label: "Polarity", value: interlock.rcaTxReqPolarity ? "+" : "-", valueColor: .secondary)
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
    .accessibilityValue(Text(isOn ? "Yes" : "No"))
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

#Preview {
  InterlockSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}
