//
//  PingsView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 4/14/25.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct PingsView: View {
  let start: Date
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var radioName: String {
    if let selection = viewModel.api.activeSelection {
      if let radio = viewModel.api.radios.first(where: {$0.id == selection.radioId} ) {
        return radio.packet.nickname
      }
    }
    return "Unknown Radio"
  }
  
  func average(_ intervals: [Double]) -> Int {
    guard !intervals.isEmpty else { return 0 }
    
    let nonZero = intervals.filter {$0 != 0}
    let count = nonZero.count
    if count == 0 {
      return 0
    } else {
      let avg = nonZero.reduce(0, +) / Double(count)
      return Int(avg * 1_000)
    }
  }
  
  func peak(_ intervals: [Double]) -> Int {
    guard !intervals.isEmpty else { return 0 }
    let max = intervals.max() ?? 0
    if max == 0 {
      return 0
    } else {
      return Int(max * 1_000)
    }
  }
  
  public var body: some View {
    
    TimelineView(.periodic(from: Date(), by: 10)) { context in
      VStack(alignment: .center) {
        Text("Ping Reply Timing (ms)").font(.title)
        
        VStack(alignment: .leading) {
          Grid(alignment: .leading) {
            GridRow {
              Text("Radio Name")
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Text("Average")
                .frame(maxWidth: .infinity, alignment: .trailing)
              
              Text("Peak")
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Divider()
              .frame(height: 2)
              .background(Color.gray)
            
            GridRow {
              Text(radioName)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Text(average(viewModel.api.pingIntervals), format: .number)
                .monospacedDigit()
                .foregroundColor(average(viewModel.api.pingIntervals) > 100 ? .red : nil)
                .frame(maxWidth: .infinity, alignment: .trailing)
              
              
              Text(peak(viewModel.api.pingIntervals), format: .number)
                .monospacedDigit()
                .foregroundColor(peak(viewModel.api.pingIntervals) > 100 ? .red : nil)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
          }
          .frame(maxWidth: .infinity)
          
          Spacer()
          
          HStack {
            Text(Int(context.date.timeIntervalSince(start)), format: .number).bold()
            Text("Seconds")
            Spacer()
            Text("Interval > 100").bold()
            Text("ms shown in")
            Text("RED").foregroundColor(.red).bold()
          }
        }
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        HStack {
          Spacer()
          Button("Close") { dismiss() }
            .keyboardShortcut(.defaultAction)
        }
      }
    }
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("PingsView") {
  PingsView(start: Date())
    .environment(ViewModel(SettingsModel()))
}
