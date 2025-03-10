//
//  BottomButtonsView.swift
//  Api/ViewerSubviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI
import UniformTypeIdentifiers

import ApiPackage

struct MessagesDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.plainText] }
  
  var text: String
  
  init(text: String = "") {
      self.text = text
  }

    // this initializer loads data that has been saved previously
  init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents,
         let string = String(data: data, encoding: .utf8) {
          text = string
      } else {
          throw CocoaError(.fileReadCorruptFile)
      }
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      let data = text.data(using: .utf8) ?? Data()
      return FileWrapper(regularFileWithContents: data)
  }
}

// ----------------------------------------------------------------------------
// MARK: - View

public struct BottomButtonsView: View {
  @Environment(ViewModel.self) private var viewModel
  
  @State private var isSaving: Bool = false
  @State private var document: MessagesDocument?

  public var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = SettingsModel.shared

    HStack {
      Toggle(isOn: $settings.gotoBottom) {
        Image(systemName: "arrow.down.square").font(.title)
      }
      
      Spacer()
      
      HStack(spacing: 5) {
        Stepper("Font", value: $settings.fontSize, in: 8...14)
        Text(SettingsModel.shared.fontSize, format: .number).frame(alignment: .leading)
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
      
//      .onChange(of: viewModel.settings.showPings) { _, newValue in
//        viewModel.messages.showPings = newValue
//      }
//      .onChange(of: viewModel.settings.showReplies) { _, newValue in
//        viewModel.messages.showReplies = newValue
//      }
      
      Spacer()
      Button("Save") {
        document = MessagesDocument(text: viewModel.messages.messagesText())
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

  .frame(minWidth: 1250, maxWidth: .infinity)
}
