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
  
  var body: some View {
    
    let interlock = viewModel.api.interlock
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      GridRow {
        Text("INTERLOCK")
          .frame(width: 110, alignment: .leading)
        
        Text("Tx Allowed")
        Text(interlock.txAllowed ? "Y" : "N")
          .foregroundColor(interlock.txAllowed ? .green : .red)
                
        Text("Tx1 Enabled")
        Text(interlock.tx1Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx1Enabled ? .green : .red)
        
        Text("Tx2 Enabled")
        Text(interlock.tx2Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx2Enabled ? .green : .red)
        
        Text("Tx3 Enabled")
        Text(interlock.tx3Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx3Enabled ? .green : .red)
        
        Text("Acc Tx Enabled")
        Text(interlock.accTxEnabled ? "Y" : "N")
          .foregroundColor(interlock.accTxEnabled ? .green : .red)
        
        Text("Acc Tx Req Enabled")
        Text(interlock.accTxReqEnabled ? "Y" : "N")
          .foregroundColor(interlock.accTxReqEnabled ? .green : .red)
        
        Text("Rca Tx Req Enabled")
        Text(interlock.rcaTxReqEnabled ? "Y" : "N")
          .foregroundColor(interlock.rcaTxReqEnabled ? .green : .red)
      }
      
      GridRow {
        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        
        Text("Delay")
        Text(interlock.txDelay, format: .number)

        Text("Delay")
        Text(interlock.tx1Delay, format: .number)
          .foregroundColor(.secondary)

        Text("Delay")
        Text(interlock.tx2Delay, format: .number)
          .foregroundColor(.secondary)

        Text("Delay")
        Text(interlock.tx3Delay, format: .number)
          .foregroundColor(.secondary)

        Text("Delay")
        Text(interlock.accTxDelay, format: .number)
          .foregroundColor(.secondary)

        Text("Polarity")
        Text(interlock.accTxReqPolarity ? "+" : "-")
          .foregroundColor(.secondary)

        Text("Polarity")
        Text(interlock.rcaTxReqPolarity ? "+" : "-")
          .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  InterlockSubView()
    .environment(ViewModel())

    .frame(width: 1250)
}
