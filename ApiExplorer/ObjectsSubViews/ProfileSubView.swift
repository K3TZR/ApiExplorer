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
  
  // Consistent label width for alignment
  private let labelWidth: CGFloat = 80
  
  private func name(_ id: String) -> String {
    id.components(separatedBy: " ").first ?? "???"
  }
  
  var body: some View {
    Grid(alignment: .topLeading, horizontalSpacing: 20, verticalSpacing: 5) {
      if viewModel.api.profiles.count > 0 {
        HeaderView(labelWidth: labelWidth)
        
        ForEach(viewModel.api.profiles.sorted(by: { $0.id < $1.id }), id: \.id) { profile in
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
              .frame(width: labelWidth)

            Text(name(profile.id).uppercased())
              .accessibilityLabel("ID: \(name(profile.id).uppercased())")
            Text(profile.current.isEmpty ? "-none-" : profile.current)
              .foregroundStyle(profile.current.isEmpty ? .red : .secondary)
              .accessibilityLabel("Current: \(profile.current.isEmpty ? "None" : profile.current)")
            Text(profile.list.joined(separator: ", "))
              .foregroundStyle(.secondary)
              .accessibilityLabel("List: \(profile.list.joined(separator: ", "))")
          }
        }
        
      } else {
        GridRow {
          Text("Profiles")
            .frame(width: labelWidth, alignment: .leading)
            .accessibilityLabel("Profiles column")
            .foregroundStyle(.yellow)

          Text("----- NONE -----")
            .foregroundStyle(.red)
            .accessibilityLabel("None present")
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct HeaderView: View {
  let labelWidth: CGFloat

  var body: some View {
    GridRow {
      Text("Profiles")
        .frame(width: labelWidth, alignment: .leading)
        .accessibilityLabel("Profiles column")

      Text("ID")
        .frame(width: 50, alignment: .leading)
        .accessibilityLabel("ID column")

      Text("Current")
        .accessibilityLabel("Current column")
      Text("List")
        .accessibilityLabel("List column")
    }
    .foregroundStyle(.yellow)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ProfileSubView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
