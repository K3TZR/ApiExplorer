//
//  ProfileSubView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 4/12/25.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct ProfileSubView: View {

  @Environment(ViewModel.self) private var viewModel
  
  private func name(_ id: String) -> String {
    id.components(separatedBy: " ").first ?? "???"
  }
  
  var body: some View {
    
    Grid(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 0) {
      if viewModel.api.profiles.count > 0 {
        HeaderView()
        
        ForEach(viewModel.api.profiles.sorted(by: {$0.id < $1.id}), id: \.id) { profile in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
              .frame(width: 70)

            Text(name(profile.id).uppercased())
            Text("\(profile.current.isEmpty ? "-none-" : profile.current)")
              .foregroundColor(profile.current.isEmpty ? .red : nil)
            Text(profile.list.joined(separator: ", "))
          }
//          .foregroundColor(.secondary)
        }
        
      } else {
        GridRow {
          Text("Profiles")
            .frame(width: 70, alignment: .leading)

          Text("----- NONE -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeaderView: View {

  var body: some View {
    
    GridRow {
      Text("Profiles")
        .frame(width: 70, alignment: .leading)

      Text("ID")
        .frame(width: 50, alignment: .leading)

      Text("Current")
      Text("List")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ProfileSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
