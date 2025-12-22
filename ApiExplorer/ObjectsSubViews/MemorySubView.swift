//
//  MemorySubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct MemorySubView: View {

  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    let memories = viewModel.api.memories
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      if memories.isEmpty {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("No memories present").foregroundStyle(.secondary)
        }
        
      } else {
        ForEach(memories.sorted(by: { $0.id < $1.id })) { memory in
          GridRow {
            Color.clear.frame(width: 80).gridCellUnsizedAxes([.horizontal, .vertical])
            
            Text("\(memory.id)")
              .monospacedDigit()
            
            Text(memory.name)
              .frame(width: 50)
              .truncationMode(.tail)
              .lineLimit(1)   // This is critical
              .clipped()
              .help(memory.name)
            
            Text(memory.group.isEmpty ? "none" : memory.group)
              .frame(width: 50)
              .truncationMode(.tail)
              .lineLimit(1)   // This is critical
              .clipped()
              .help(memory.group.isEmpty ? "none" : memory.group)
            
            Text(memory.owner)
            Text("\(memory.frequency)")
              .monospacedDigit()
            Text(memory.mode)
            Text("\(memory.step)")
              .monospacedDigit()
            Text("\(memory.rfPower)")
              .monospacedDigit()
            Text("\(memory.filterLow)")
              .monospacedDigit()
            Text("\(memory.filterHigh)")
              .monospacedDigit()
            Text(memory.squelchEnabled ? "Y" : "N")
              .foregroundStyle(memory.squelchEnabled ? .green : .primary)
            Text("\(memory.squelchLevel)")
              .monospacedDigit()
            Text(memory.offsetDirection)
            Text("\(memory.offset)")
              .monospacedDigit()
            Text(memory.toneMode)
            Text("\(String(format: "%3.0f", memory.toneValue))")
              .monospacedDigit()
            Text("\(memory.rttyMark)")
              .monospacedDigit()
            Text("\(memory.rttyShift)")
              .monospacedDigit()
            Text("\(memory.digitalLowerOffset)")
              .monospacedDigit()
            Text("\(memory.digitalUpperOffset)")
              .monospacedDigit()
          }
//          .foregroundColor(.secondary)
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
      Text("MEMORIES")
        .frame(width: 80, alignment: .leading)
      
      Text("ID")
      Text("Name")
      Text("Group")
      Text("Owner")
      Text("Frequency")
      Text("Mode")
      Text("Step")
      Text("Power")
      Text("Low")
      Text("High")
      Text("Squelch")
      Text("Level")
      Text("Mode")
      Text("Offset")
      Text("Tone")
      Text("Freq")
      Text("Mark")
      Text("Shift")
      Text("DIGU")
      Text("DIGL")
    }
    .gridCellAnchor(.leading)
    .foregroundStyle(.yellow)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MemorySubView()  
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1250)
}

