//
//  MemorySubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

//import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MemorySubView: View {
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
      HeadingView()
      if viewModel.objectModel.memories.count == 0 {
        GridRow {
          Text("None present").foregroundColor(.red)
        }
      } else {
        ForEach(viewModel.objectModel.memories) { memory in
          DetailView(memory: memory)
        }
      }
    } 
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("MEMORIES")
        .frame(width: 100, alignment: .leading)
      
      Text("ID")
        .frame(width: 50, alignment: .leading)
      
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
      Text("Sq Level")
      Text("Rpt Mode")
      Text("Rpt Offset")
      Text("Tone")
      Text("Tone Value")
      Text("Mark")
      Text("Shift")
      Text("DIGL Upper")
      Text("DIGU Lower")
    }
  }
}

private struct DetailView: View {
  var memory: Memory
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        .frame(width: 100)

      Text("\(memory.id)")
      
      Text(memory.name).help(memory.name)
      Text(memory.group.isEmpty ? "none" : memory.group).help(memory.group)
      Text(memory.owner).help(memory.owner)
      Text("\(memory.frequency)")
      Text(memory.mode)
      Text("\(memory.step)")
      Text("\(memory.rfPower)")
      Text("\(memory.filterLow)")
      Text("\(memory.filterHigh)")
      Text(memory.squelchEnabled ? "Y" : "N").foregroundColor(memory.squelchEnabled ? .green : nil)
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
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MemorySubView()  
    .environment(ViewModel())
  
    .frame(width: 1250)
}
