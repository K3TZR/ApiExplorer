//
//  MessagesView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 1/28/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesView: View {

  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  @MainActor func textLine( _ text: String) -> AttributedString {
    var attString = AttributedString(text)
    // color it appropriately
    if text.prefix(1) == "C" { attString.foregroundColor = .systemGreen }                        // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { attString.foregroundColor = .systemGray } // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { attString.foregroundColor = .systemRed } // Replies w/error
    if text.prefix(2) == "S0" { attString.foregroundColor = .systemOrange }                      // S0
    
    // highlight any filterText value
    if !settings.messageFilterText.isEmpty {
      if let range = attString.range(of: settings.messageFilterText, options: [.caseInsensitive]) {
        attString[range].underlineStyle = .single
        attString[range].foregroundColor = .yellow
        //        attString[range].font = NSFont(name: "System", size: 16)
      }
    }
    return attString
  }
  
  @State var id: UUID?
  
  var body: some View {
    
    VStack(alignment: .leading) {
      FilterView()
      
      if viewModel.messages.filteredMessages.count == 0 {
        VStack(alignment: .leading) {
          Spacer()
          HStack {
            Spacer()
            Text("TCP Messages will be displayed here")
            Spacer()
          }
          Spacer()
        }
        
      } else {
        ScrollView([.vertical]) {
          LazyVStack(alignment: .leading) {
            ForEach(viewModel.messages.filteredMessages.reversed(), id: \.id) { tcpMessage in
              HStack(alignment: .top) {
                if settings.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
                Text(textLine(tcpMessage.text + "\(settings.newLineBetweenMessages ? "\n" : "")"))
              }
              .textSelection(.enabled)
              .font(.system(size: CGFloat(settings.fontSize), weight: .regular, design: .monospaced))
            }
          }
        }
        .scrollPosition(id: $id)
        
        .onChange(of: settings.gotoBottom) {
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
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    @Bindable var viewModelBinding = viewModel
    @Bindable var settings = settings
    
    HStack {
      Picker("Tcp Messages", selection: $settings.messageFilter) {
        ForEach(MessagesModel.Filter.allCases, id: \.self) {
          Text($0.rawValue).tag($0)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      .onChange(of: settings.messageFilter) {
        viewModel.messages.reFilter()
      }
      
      Image(systemName: "x.circle").font(.title2)
        .onTapGesture {
          settings.messageFilterText = ""
        }
      
      TextField("filter text", text: $settings.messageFilterText)
        .onChange(of: settings.messageFilterText) {
          viewModel.messages.reFilter()
        }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
}
