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
    
    Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
      HeadingView()
      if viewModel.api.memories.count == 0 {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
        
      } else {
        ForEach(viewModel.api.memories) { memory in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])

            Text("\(memory.id)")
            
            Text(memory.name)
            Text(memory.group.isEmpty ? "none" : memory.group)
            Text(memory.owner)
            Text("\(memory.frequency)")
            Text(memory.mode)
            Text("\(memory.step)")
            Text("\(memory.rfPower)")
            Text("\(memory.filterLow)")
            Text("\(memory.filterHigh)")
            Text(memory.squelchEnabled ? "Y" : "N")
              .foregroundColor(memory.squelchEnabled ? .green : nil)
            Text("\(memory.squelchLevel)")
            Text(memory.offsetDirection)
            Text("\(memory.offset)")
            Text(memory.toneMode)
            Text("\(String(format: "%3.0f", memory.toneValue))")
            Text("\(memory.rttyMark)")
            Text("\(memory.rttyShift)")
            Text("\(memory.digitalLowerOffset)")
            Text("\(memory.digitalUpperOffset)")
          }
          .foregroundColor(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("MEMORIES")
        .frame(width: 110, alignment: .leading)
      
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
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MemorySubView()  
    .environment(ViewModel())
  
    .frame(width: 1250)
}
