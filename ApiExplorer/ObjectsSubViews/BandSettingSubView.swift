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

    Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
      HeadingView()
      if viewModel.objectModel.bandSettings.count > 0 {
        ForEach(viewModel.objectModel.bandSettings.sorted(by: {$0.name > $1.name})) { setting in
          DetailView(bandSetting: setting)
        }

      } else {
        GridRow {
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeadingView: View {

  var body: some View {
    
    GridRow {
      Text("BAND SETTINGS")
        .frame(width: 100, alignment: .leading)

      Text("Band")
        .frame(width: 50, alignment: .leading)

      Text("Rf Power")
      Text("Tune Power")
      Text("PTT Inhibit")
      Text("ACC TX")
      Text("RCA TX Request")
      Text("ACC TX Request")
      Text("RCA TX1")
      Text("RCA TX2")
      Text("RCA TX3")
      Text("HW ALC")
    }
  }
}

private struct DetailView: View {
  let bandSetting: BandSetting

  var body: some View {
        
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      
      Text(bandSetting.name == 999 ? " GEN" : String(format: "%#4d", bandSetting.name))
      Text(bandSetting.rfPower, format: .number)
      Text(bandSetting.tunePower, format: .number)
      Text("\(bandSetting.inhibit ? "ON" : "OFF")").foregroundColor(bandSetting.inhibit ? .green : .red)
      Text("\(bandSetting.accTxEnabled ? "ON" : "OFF")").foregroundColor(bandSetting.accTxEnabled ? .green : .red)
      Text("\(bandSetting.rcaTxReqEnabled ? "ON" : "OFF")").foregroundColor(bandSetting.rcaTxReqEnabled ? .green : .red)
      Text("\(bandSetting.accTxReqEnabled ? "ON" : "OFF")").foregroundColor(bandSetting.accTxReqEnabled ? .green : .red)
      Text("\(bandSetting.tx1Enabled ? "ON" : "OFF")").foregroundColor(bandSetting.tx1Enabled ? .green : .red)
      Text("\(bandSetting.tx2Enabled ? "ON" : "OFF")").foregroundColor(bandSetting.tx2Enabled ? .green : .red)
      Text("\(bandSetting.tx3Enabled ? "ON" : "OFF")").foregroundColor(bandSetting.tx3Enabled ? .green : .red)
      Text("\(bandSetting.hwAlcEnabled ? "ON" : "OFF")").foregroundColor(bandSetting.hwAlcEnabled ? .green : .red)
    }
//    .controlSize(.small)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BandSettingSubView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
