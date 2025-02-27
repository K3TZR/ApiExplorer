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
    
    let interlock = viewModel.objectModel.interlock
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      GridRow {
        Text("INTERLOCK")
          .frame(width: 100, alignment: .leading)
        
        Text("Tx Allowed")
        Text(interlock.txAllowed ? "Y" : "N")
          .foregroundColor(interlock.txAllowed ? .green : .red)
        
        Text(interlock.txDelay, format: .number).frame(width: 30)
        
        Text("Tx1 Enabled")
        Text(interlock.tx1Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx1Enabled ? .green : .red)
        Text(interlock.tx1Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
        
        Text("Tx2 Enabled")
        Text(interlock.tx2Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx2Enabled ? .green : .red)
        Text(interlock.tx2Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
        
        Text("Tx3 Enabled")
        Text(interlock.tx3Enabled ? "Y" : "N")
          .foregroundColor(interlock.tx3Enabled ? .green : .red)
        Text(interlock.tx3Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
        
        Text("Acc Tx Enabled")
        Text(interlock.accTxEnabled ? "Y" : "N")
          .foregroundColor(interlock.accTxEnabled ? .green : .red)
        Text(interlock.accTxDelay, format: .number).frame(width: 30).foregroundColor(.secondary)
        
        Text("Acc Tx Req Enabled")
        Text(interlock.accTxReqEnabled ? "Y" : "N")
          .foregroundColor(interlock.accTxReqEnabled ? .green : .red)
        Text(interlock.accTxReqPolarity ? "+" : "-")
          .foregroundColor(.secondary)
        
        Text("Rca Tx Req Enabled")
        Text(interlock.rcaTxReqEnabled ? "Y" : "N")
          .foregroundColor(interlock.rcaTxReqEnabled ? .green : .red)
        Text(interlock.rcaTxReqPolarity ? "+" : "-")
          .foregroundColor(.secondary)
      }
    }
    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

#Preview {
  InterlockSubView()
    .environment(ViewModel())

    .frame(width: 1250)
}
