//
//  AtuSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuSubView: View {
  let radio: Radio?
  
  @Environment(ViewModel.self) private var viewModel
  
  // Consistent label width for alignment across states
  private let labelWidth: CGFloat = 80
  
  var body: some View {
    Group {
      if let radio {
        if radio.atuPresent {
          atuContent
        } else {
          noAtuContent
        }
      } else {
        noRadioContent
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  // MARK: - Sections
  
  private var atuContent: some View {
    let atu = viewModel.api.atu
    return Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 5) {
      GridRow {
        Text("ATU")
          .frame(width: labelWidth, alignment: .leading)
        
        ToggleRow(label: "ATU Enabled", isOn: atu.enabled)
        ToggleRow(label: "Memories Enabled", isOn: atu.memoriesEnabled)
        ToggleRow(label: "Using Memories", isOn: atu.usingMemory)
        
        LabeledValue(label: "Tune Status", value: atu.status.rawValue, valueColor: .secondary)
      }
    }
  }
  
  private var noAtuContent: some View {
    Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 5) {
      GridRow {
        Text("ATU")
          .frame(width: labelWidth, alignment: .leading)
        Text("----- NONE -----")
          .foregroundStyle(.red)
      }
    }
  }
  
  private var noRadioContent: some View {
    Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 5) {
      GridRow {
        Text("ATU")
          .frame(width: labelWidth, alignment: .leading)
        Text("----- NO RADIO -----")
          .foregroundStyle(.red)
      }
    }
  }
}

// MARK: - Helper Views

private struct ToggleRow: View {
  let label: String
  let isOn: Bool
  
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(isOn ? "Y" : "N")
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

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView(radio: nil)
    .environment(ViewModel(SettingsModel()))
    .frame(width: 1000)
}
