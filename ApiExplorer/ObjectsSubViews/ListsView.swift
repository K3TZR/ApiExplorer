//
//  ListsView.swift
//  SDRApi
//
//  Created by Douglas Adams on 5/2/24.
//

import SwiftUI

import ApiPackage

struct ListsView: View {
  
  @Environment(ViewModel.self) var viewModel

//  func stringArrayToString( _ list: [String]?) -> String {
//    guard list != nil else { return "Unknown"}
//    let str = list!.reduce("") {$0 + $1 + ", "}
//    return String(str.dropLast(2))
//  }
  
//  func uint32ArrayToString( _ list: [UInt32]) -> String {
//    let str = list.reduce("") {String($0) + String($1) + ", "}
//    return String(str.dropLast(2))
//  }
  
  var body: some View {
   
    if let radio = viewModel.objectModel.activeSelection?.radio {
      Grid(alignment: .leading, horizontalSpacing: 10) {
        GridRow {
          Text("LISTS")
            .frame(width: 100, alignment: .leading)
          
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
    }
  }
}

#Preview {
  ListsView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
