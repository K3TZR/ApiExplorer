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

    VStack(alignment: .leading) {
      HStack( spacing: 10) {
        ToggleX(title: "Reverse", isOn: $settings.gotoBottom, width: 130)
        
        Spacer()
        
        HStack(spacing: 5) {
          Text("Font: ")
          Text(settings.fontSize, format: .number)
            .frame(width: 20, alignment: .trailing)
          Button("+") {
            viewModel.fontFieldTapped()
          }
          .hidden()
          .keyboardShortcut("+", modifiers: [.command])
        }
        .help("CMD-+ to cnage font size")
        
        Spacer()
        
        HStack(spacing: 5) {
          ToggleX(title: "Spacing", isOn: $settings.newLineBetweenMessages, width: 70)
          ToggleX(title: "Times", isOn: $settings.showTimes, width: 70)
          ToggleX(title: "Pings", isOn: $settings.showPings, width: 70)
          ToggleX(title: "Replies", isOn: $settings.showReplies, width: 70)
          ToggleX(title: "Alerts", isOn: $settings.alertOnError, width: 70)
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
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    
    // Save Dialog
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiExplorer.log") { result in
      switch result {
      case .success(let url):
        log?.info("ApiExplorer: Log Exported to \(url)")
      case .failure(let error):
        log?.warning("ApiExplorer: Log Export failed, \(error)")
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
  
    .frame(width: 1000)
}

public struct ToggleX: View {
  let title: String
  let isOn: Binding<Bool>
  let width: CGFloat?
  
  public var body: some View {

#if os(macOS)
    Toggle(title, isOn: isOn)
      .toggleStyle(ButtonToggleStyle())
#else
    VStack(spacing: 0) {
      Text(title)
        .frame(maxWidth: .infinity, alignment: .center)
      Toggle(title, isOn: isOn)
        .labelsHidden()
    }
    .frame(width: width)
#endif
  }
}


public struct StepperX: View {
  let title: String
  let value: Binding<Int>
  let range: ClosedRange<Int>
  let width: CGFloat?
  
  public var body: some View {

#if os(macOS)
    HStack(spacing: 5) {
      Stepper("Font", value: value, in: 8...14)
      Text(value.wrappedValue, format: .number).frame(alignment: .leading)
    }
//      .frame(width: width)
#else
    VStack(spacing: 0) {
      Text(title)
        .frame(maxWidth: .infinity, alignment: .center)
      HStack(spacing: 5) {
        Stepper("", value: value, in: range)
          .labelsHidden()
        Text(value.wrappedValue, format: .number).frame(alignment: .leading)
      }
    }
    .frame(width: width)
#endif
  }
}

//public struct PickerX: View {
//  let title: String
//  let selection: Binding<DaxChoice>
//  let width: CGFloat?
//  let content: () -> some View
//  
//  public var body: some View {
//
//#if os(macOS)
//    Picker(title, selection: selection, content: content)
//#else
//    VStack(spacing: 0) {
//      Text(title)
//        .frame(maxWidth: .infinity, alignment: .center)
//      Toggle(title, isOn: isOn)
//        .labelsHidden()
//    }
//    .frame(width: width)
//#endif
//  }
//}
