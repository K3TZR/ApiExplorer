//
//  BandSettingsSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct BandSettingSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    let bandSettings = viewModel.api.bandSettings

    Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
      HeadingView()
      if !bandSettings.isEmpty {
        ForEach(bandSettings.sorted(by: { Int($0.name) ?? 0 < Int($1.name) ?? 0 })) { bandSetting in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            
            Text(bandSetting.name)
            Text(bandSetting.rfPower, format: .number).monospacedDigit()
            Text(bandSetting.tunePower, format: .number).monospacedDigit()
            Text("\(bandSetting.inhibit ? "ON" : "OFF")").foregroundStyle(bandSetting.inhibit ? .green : .red)
            Text("\(bandSetting.accTxEnabled ? "ON" : "OFF")").foregroundStyle(bandSetting.accTxEnabled ? .green : .red)
            Text("\(bandSetting.rcaTxReqEnabled ? "ON" : "OFF")").foregroundStyle(bandSetting.rcaTxReqEnabled ? .green : .red)
            Text("\(bandSetting.accTxReqEnabled ? "ON" : "OFF")").foregroundStyle(bandSetting.accTxReqEnabled ? .green : .red)
            Text("\(bandSetting.tx1Enabled ? "ON" : "OFF")").foregroundStyle(bandSetting.tx1Enabled ? .green : .red)
            Text("\(bandSetting.tx2Enabled ? "ON" : "OFF")").foregroundStyle(bandSetting.tx2Enabled ? .green : .red)
            Text("\(bandSetting.tx3Enabled ? "ON" : "OFF")").foregroundStyle(bandSetting.tx3Enabled ? .green : .red)
            Text("\(bandSetting.hwAlcEnabled ? "ON" : "OFF")").foregroundStyle(bandSetting.hwAlcEnabled ? .green : .red)
          }
        }

      } else {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("----- NONE PRESENT -----").foregroundStyle(.red)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .textSelection(.enabled)
  }
}

private struct HeadingView: View {

  var body: some View {
    
    GridRow {
      Text("BAND SET")
        .frame(width: 80, alignment: .leading)

      Text("Band")
      Text("Rf Power")
      Text("Tune Power")
      Text("PTT Inhibit")
      Text("ACC TX")
      Text("RCA Req")
      Text("ACC Req")
      Text("RCA TX1")
      Text("RCA TX2")
      Text("RCA TX3")
      Text("HW ALC")
    }
    .gridCellAnchor(.leading)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BandSettingSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1250)
}
