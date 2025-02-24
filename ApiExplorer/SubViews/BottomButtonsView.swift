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

    HStack {
      Toggle(isOn: $viewModel.settingModel.gotoBottom) {
        Image(systemName: "arrow.down.square").font(.title)
      }
      
      Spacer()
      
      HStack(spacing: 5) {
        Stepper("Font Size", value: $viewModel.settingModel.fontSize, in: 8...14)
        Text(viewModel.settingModel.fontSize, format: .number).frame(alignment: .leading)
      }
      Toggle("Line Spacing", isOn: $viewModel.settingModel.newLineBetweenMessages)

      Spacer()
      HStack {
        Toggle("Show Times", isOn: $viewModel.settingModel.showTimes)
        Toggle("Show Pings", isOn: $viewModel.settingModel.showPings)
        Toggle("Show Replies", isOn: $viewModel.settingModel.showReplies)
        Toggle("Show Alerts", isOn: $viewModel.settingModel.alertOnError)
          .help("Display a sheet when an Error / Warning occurs")
      }
      
      .onChange(of: viewModel.settingModel.showPings) { _, newValue in
        viewModel.messageModel.showPings = newValue
      }
      .onChange(of: viewModel.settingModel.showReplies) { _, newValue in
        viewModel.messageModel.showReplies = newValue
      }
      
      Spacer()
      Button("Save") {
        document = MessagesDocument(text: viewModel.messageModel.messagesText())
        isSaving = true
      }
      
      Spacer()
      HStack {
        Toggle("Clear on Start", isOn: $viewModel.settingModel.clearOnStart)
        Toggle("Clear on Stop", isOn: $viewModel.settingModel.clearOnStop)
      }
      
      Button("Clear") { viewModel.messageModel.clearButtonTapped() }
    }
    .toggleStyle(.button)
    
    // Save Dialog
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiViewer.log") { result in
        switch result {
        case .success(let url):
          log.info("ApiViewer: Log Exported to \(url)")
        case .failure(let error):
          log.warning("ApiViewer: Log Export failed, \(error)")
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
