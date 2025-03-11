//
//  BottomButtonsView.swift
//  Api/ViewerSubviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI
import UniformTypeIdentifiers

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

public struct BottomButtonsView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  @State private var isSaving: Bool = false
  @State private var document: SaveDocument?

  public var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = settings

    HStack {
      Toggle(isOn: $settings.gotoBottom) {
        Image(systemName: "arrow.down.square").font(.title)
      }
      
      Spacer()
      
      HStack(spacing: 5) {
        Stepper("Font", value: $settings.fontSize, in: 8...14)
        Text(settings.fontSize, format: .number).frame(alignment: .leading)
      }
      Toggle("Spacing", isOn: $settings.newLineBetweenMessages)

      Spacer()
      HStack {
        Toggle("Times", isOn: $settings.showTimes)
        Toggle("Pings", isOn: $settings.showPings)
        Toggle("Replies", isOn: $settings.showReplies)
        Toggle("Alerts", isOn: $settings.alertOnError)
          .help("Display a sheet when an Error / Warning occurs")
      }
      
      Spacer()

      Button("Save") {
        document = SaveDocument(text: viewModel.messages.messagesText())
        isSaving = true
      }
      
      Spacer()
      
      Button("Clear") { viewModel.messages.clearButtonTapped() }
    }
    .toggleStyle(.button)
    
    // Save Dialog
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiExplorer.log") { result in
        switch result {
        case .success(let url):
          log.info("ApiExplorer: Log Exported to \(url)")
        case .failure(let error):
          log.warning("ApiExplorer: Log Export failed, \(error)")
        }
      }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BottomButtonsView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
}
