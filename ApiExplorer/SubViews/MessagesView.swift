//
//  MessagesView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 1/28/24.
//

import SwiftUI
import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var id: UUID?
  
  var body: some View {
    
    VStack(alignment: .leading, spacing: 10) {
      FilterView()
      
      if viewModel.messages.filteredMessages.count == 0 {
        Spacer()
        
      } else {
        ScrollView([.vertical]) {
          LazyVStack(alignment: .leading) {
            ForEach(viewModel.messages.filteredMessages.reversed(), id: \.id) { tcpMessage in
              HStack(alignment: .top) {
                if viewModel.settings.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
                Text(textLine(tcpMessage.text + "\(viewModel.settings.newLineBetweenMessages ? "\n" : "")"))
              }
              .textSelection(.enabled)
              .font(.system(size: CGFloat(viewModel.settings.fontSize), weight: .regular, design: .monospaced))
            }
          }
        }
        .scrollPosition(id: $id)
        
        .onChange(of: viewModel.settings.gotoBottom) {
          if $1 {
            self.id = viewModel.messages.filteredMessages.first?.id
          } else {
            self.id = viewModel.messages.filteredMessages.last?.id
          }
        }
      }
    }
  }
}

private struct FilterView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State private var showMessageFilterSettings: Bool = false
  @State private var showIssues: Bool = false

  var body: some View {
    @Bindable var viewModelBinding = viewModel
    @Bindable var settings = viewModel.settings
    
    HStack {
      HStack {
        Button("MESSAGE Type") {showMessageFilterSettings.toggle()}
          .popover(isPresented: $showMessageFilterSettings, arrowEdge: .trailing) {
            MessagesFilterPopover()
              .padding(10)
          }

        Text(settings.messageFilter.rawValue)
          .frame(width: 100, alignment: .leading)
      }
      .onChange(of: settings.messageFilter) {
        viewModel.messages.reFilter()
      }
      
      ClearableTextField(placeholder: "filter text", text: $settings.messageFilterText)
        .frame(width: 400)
        .onChange(of: settings.messageFilterText) {
          viewModel.messages.reFilter()
        }
      Spacer()
      Button("Issues") {showIssues.toggle()}
        .popover(isPresented: $showIssues, arrowEdge: .bottom) {
          IssuesPopover()
            .padding(10)
        }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Extension

extension MessagesView {
  
  @MainActor func textLine( _ text: String) -> AttributedString {
    var attString = AttributedString(text)
    // color it appropriately
    if text.prefix(1) == "C" { attString.foregroundColor = .systemGreen }                        // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { attString.foregroundColor = .systemGray } // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { attString.foregroundColor = .systemRed } // Replies w/error
    if text.prefix(2) == "S0" { attString.foregroundColor = .systemOrange }                      // S0
    
    // highlight any filterText value
    if !viewModel.settings.messageFilterText.isEmpty {
      if let range = attString.range(of: viewModel.settings.messageFilterText, options: [.caseInsensitive]) {
        attString[range].underlineStyle = .single
        attString[range].foregroundColor = .yellow
        //        attString[range].font = NSFont(name: "System", size: 16)
      }
    }
    return attString
  }
  
}

public struct MessagesFilterPopover: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    VStack {
      Text("Choose ONE")
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      ForEach(MessagesModel.Filter.allCases, id: \.self) { item in
        HStack {
          Text(item.rawValue)
          
          Spacer()
          if settings.messageFilter == item {
            Image(systemName: "checkmark")
              .foregroundColor(.accentColor)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          if settings.messageFilter == item {
            settings.messageFilter = MessagesModel.Filter.all
          } else {
            settings.messageFilter = item
          }
        }
      }      
    }
  }
}

public struct IssuesPopover: View {
  @State private var issues: [String: String] = [:]
  
  public var body: some View {
    VStack(alignment: .leading) {
      if issues.isEmpty {
        Text("Loading...")
      } else {
        ForEach(issues.sorted(by: { $0.key < $1.key }), id: \.key) { pair in
          Text(pair.value)
            .fixedSize(horizontal: true, vertical: false)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding()

    .task {
      issues = await ApiLog.shared.fetchIssues()
    }
  }
}


// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView()
    .environment(ViewModel(SettingsModel()))
}
