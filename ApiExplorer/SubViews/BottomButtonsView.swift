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
  let viewMode: ViewMode

  @Environment(ViewModel.self) private var viewModel

  @State private var isSaving: Bool = false
  @State private var document: SaveDocument?

  public var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = viewModel.settings

    VStack(alignment: .leading) {
      HStack( spacing: 10) {

        Spacer()
        
        if viewMode == .messages || viewMode == .all {
          
          HStack(spacing: 5) {
            ToggleX(title: "Spacing", isOn: $settings.newLineBetweenMessages)
            ToggleX(title: "Times", isOn: $settings.showTimes)
            ToggleX(title: "Reverse", isOn: $settings.gotoBottom)
            ToggleX(title: "Pings", isOn: $settings.showPings)
              .onChange(of: settings.showPings) {
                if $1 == false { viewModel.messages.removePings() }
              }
          }
          
          Spacer()
          
          Button("Save") {
            document = SaveDocument(text: viewModel.messages.messagesText())
            isSaving = true
          }
          
          Spacer()
          
          Button("Clear") { viewModel.messages.clearButtonTapped() }
        }
      }
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    
    // Save Dialog
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiExplorer.log") { result in
      switch result {
      case .success(let url):
        Task { await ApiLog.info("ApiExplorer: Log Exported to \(url)") }
      case .failure(let error):
        Task { await ApiLog.warning("ApiExplorer: Log Export failed, \(error)") }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BottomButtonsView(viewMode: .all)
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}

// ----------------------------------------------------------------------------
// MARK: - Alternate controls (iOS vs macOS)

public struct ToggleX: View {
  let title: String
  let isOn: Binding<Bool>
  
  public var body: some View {

#if os(macOS)
    Toggle(title, isOn: isOn)
      .toggleStyle(ButtonToggleStyle())
#else
    Toggle(title, isOn: isOn)
      .toggleStyle(ButtonToggleStyle())
//      .border(Color.gray, width: 0.5)
//      .background(isOn.wrappedValue ? Color.blue.opacity(0.5) : Color.clear)
//      .foregroundColor(isOn.wrappedValue ? Color.white : Color.blue)
#endif
  }
}

//public struct ToggleY: View {
//  let title: String
//  let isOn: Binding<Bool>
//  
//  public var body: some View {
//
//#if os(macOS)
//    Toggle(title, isOn: Binding(
//      get: { !isOn.wrappedValue },
//      set: { isOn.wrappedValue = !$0 }
//  ))
//      .toggleStyle(ButtonToggleStyle())
//#else
//    Toggle(title, isOn: isOn)
//      .toggleStyle(ButtonToggleStyle())
//      .border(Color.gray, width: 0.5)
//      .background(isOn.wrappedValue ? Color.blue.opacity(0.5) : Color.clear)
//      .foregroundColor(isOn.wrappedValue ? Color.white : Color.blue)
//#endif
//  }
//}


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
