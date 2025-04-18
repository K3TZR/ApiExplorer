//
//  ListsView.swift
//  SDRApi
//
//  Created by Douglas Adams on 5/2/24.
//

import SwiftUI

import ApiPackage

struct ListsView: View {
  let radio: Radio?

  @Environment(ViewModel.self) var viewModel

  var body: some View {
   
    if let radio {
      Grid(alignment: .leading, horizontalSpacing: 10) {
        GridRow {
          Text("LISTS")
            .frame(width: 110, alignment: .leading)
          
          HStack(spacing: 5) {
            Text("Ant List")
            Text(radio.antList.joined(separator: ", ")).foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Mic List")
            Text(radio.micList.joined(separator: ", ")).foregroundColor(.secondary)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ListsView(radio: nil)
    .environment(ViewModel())
  
    .frame(width: 1000)
}
