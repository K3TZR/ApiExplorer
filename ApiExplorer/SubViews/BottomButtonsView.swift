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
        Label( "", systemImage: "arrow.up.arrow.down.square").font(.title)
          .onTapGesture {
            settings.gotoBottom.toggle()
          }

//        ToggleX(title: "Reverse", isOn: $settings.gotoBottom)
        
        Spacer()
        
//        HStack(spacing: 5) {
//          Text("Font: ")
//          Text(settings.fontSize, format: .number)
//            .frame(width: 20, alignment: .trailing)
//          Button("+") {
//            viewModel.fontFieldTapped()
//          }
//          .hidden()
//          .keyboardShortcut("+", modifiers: [.command])
//        }
//        .help("CMD-+ to cnage font size")
//        
//        Spacer()
        
        HStack(spacing: 5) {
          ToggleX(title: "Spacing", isOn: $settings.newLineBetweenMessages)
          ToggleX(title: "Times", isOn: $settings.showTimes)
          ToggleX(title: "Pings", isOn: $settings.showPings)
          ToggleX(title: "Replies", isOn: $settings.showReplies)
          ToggleX(title: "Alerts", isOn: $settings.alertOnError)
            .help("Display a sheet when an Error / Warning occurs")
        }
        
        Spacer()
        
        ButtonX(title: "Save") {
          document = SaveDocument(text: viewModel.messages.messagesText())
          isSaving = true
        }
        
        Spacer()
        
        ButtonX(title: "Clear") { viewModel.messages.clearButtonTapped() }
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
        log?.warningExt("ApiExplorer: Log Export failed, \(error)")
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

// ----------------------------------------------------------------------------
// MARK: - Alternate controls (iOS vs macOS)

public struct ButtonX: View {
  let title: String
  let action: () -> Void
//  let width: CGFloat?
  
  public var body: some View {

#if os(macOS)
    Button(title, action: action)
//      .frame(width: width ?? 100)
#else
    Button(title, action: action)
//      .frame(width: width ?? 100)
      .buttonStyle(.bordered)
#endif
  }
}

public struct ToggleX: View {
  let title: String
  let isOn: Binding<Bool>
//  let width: CGFloat?
  
  public var body: some View {

#if os(macOS)
    Toggle(title, isOn: isOn)
      .toggleStyle(ButtonToggleStyle())
//      .frame(width: width ?? 100)
#else
    Toggle(title, isOn: isOn)
//      .frame(width: width ?? 100)
      .toggleStyle(ButtonToggleStyle())
      .border(Color.gray, width: 0.5)
      .background(isOn.wrappedValue ? Color.blue.opacity(0.5) : Color.clear)
      .foregroundColor(isOn.wrappedValue ? Color.white : Color.blue)
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
