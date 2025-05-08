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
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 0) {
      GridRow {
        Text("INTLCK")
          .frame(width: 50, alignment: .leading)
        
        HStack(spacing: 5){
          Text("Tx Allowed")
          Text(interlock.txAllowed ? "Y" : "N")
            .foregroundColor(interlock.txAllowed ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Tx1 Enabled")
          Text(interlock.tx1Enabled ? "Y" : "N")
            .foregroundColor(interlock.tx1Enabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Tx2 Enabled")
          Text(interlock.tx2Enabled ? "Y" : "N")
            .foregroundColor(interlock.tx2Enabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Tx3 Enabled")
          Text(interlock.tx3Enabled ? "Y" : "N")
            .foregroundColor(interlock.tx3Enabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Acc Tx")
          Text(interlock.accTxEnabled ? "Y" : "N")
            .foregroundColor(interlock.accTxEnabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Acc Req")
          Text(interlock.accTxReqEnabled ? "Y" : "N")
            .foregroundColor(interlock.accTxReqEnabled ? .green : .red)
        }
        
        HStack(spacing: 5){
          Text("Rca Req")
          Text(interlock.rcaTxReqEnabled ? "Y" : "N")
            .foregroundColor(interlock.rcaTxReqEnabled ? .green : .red)
        }
      }
      
      GridRow {
        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        
        HStack(spacing: 5){
          Text("Delay")
          Text(interlock.txDelay, format: .number)
        }
        
        HStack(spacing: 5){
          Text("Delay")
          Text(interlock.tx1Delay, format: .number)
            .foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("Delay")
          Text(interlock.tx2Delay, format: .number)
            .foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("Delay")
          Text(interlock.tx3Delay, format: .number)
            .foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("Delay")
          Text(interlock.accTxDelay, format: .number)
            .foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("Polarity")
          Text(interlock.accTxReqPolarity ? "+" : "-")
            .foregroundColor(.secondary)
        }
        
        HStack(spacing: 5){
          Text("Polarity")
          Text(interlock.rcaTxReqPolarity ? "+" : "-")
            .foregroundColor(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  InterlockSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}
