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

  @MainActor func textLine( _ text: String) -> AttributedString {
    var attString = AttributedString(text)
    // color it appropriately
    if text.prefix(1) == "C" { attString.foregroundColor = .systemGreen }                        // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { attString.foregroundColor = .systemGray } // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { attString.foregroundColor = .systemRed } // Replies w/error
    if text.prefix(2) == "S0" { attString.foregroundColor = .systemOrange }                      // S0
    
    // highlight any filterText value
    if !viewModel.settingModel.messageFilterText.isEmpty {
      if let range = attString.range(of: viewModel.settingModel.messageFilterText) {
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
      
      if viewModel.messageModel.filteredMessages.count == 0 {
        VStack(alignment: .leading) {
          Spacer()
          HStack {
            Spacer()
            Text("TCP Messages will be displayed here")
            Spacer()
          }
          Spacer()
        }
      }
      else {
        ScrollView([.vertical]) {
          LazyVStack(alignment: .leading) {
            ForEach(viewModel.messageModel.filteredMessages.reversed(), id: \.id) { tcpMessage in
              HStack(alignment: .top) {
                if viewModel.settingModel.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
                Text(textLine(tcpMessage.text + "\(viewModel.settingModel.newLineBetweenMessages ? "\n" : "")"))
              }
              .textSelection(.enabled)
              .font(.system(size: CGFloat(viewModel.settingModel.fontSize), weight: .regular, design: .monospaced))
            }
          }
        }
        .scrollPosition(id: $id)
        
        //          .onChange(of: settings.gotoBottom) {
        //            if $1 {
        //              self.id = viewModel.messages.filteredMessages.first?.id
        //            } else {
        //              self.id = viewModel.messages.filteredMessages.last?.id
        //            }
        //          }
      }
      
      ////        .onAppear{
      ////          store.send(.onAppear)
      ////        }
    }
    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

private struct FilterView: View {
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    @Bindable var viewModelBinding = viewModel
    
    HStack {
      Picker("Show Tcp Messages of type", selection: $viewModelBinding.settingModel.messageFilter) {
        ForEach(MessageModel.Filter.allCases, id: \.self) {
          Text($0.rawValue).tag($0)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      
      .onChange(of: viewModel.settingModel.messageFilter) { _ , newValue in
        viewModel.messageModel.reFilter(newValue, viewModel.settingModel.messageFilterText)
      }
      
      Image(systemName: "x.circle").font(.title2)
        .onTapGesture {
          viewModel.settingModel.messageFilterText = ""
//          viewModel.messagesModel.filtersChanged(viewModel.settingModel.messageFilter, viewModel.settingModel.messageFilterText)
        }
      
      TextField("filter text", text: $viewModelBinding.settingModel.messageFilterText)
        
        .onChange(of: viewModel.settingModel.messageFilterText) { _, newValue in
          viewModel.messageModel.reFilter(viewModel.settingModel.messageFilter, newValue)
        }
    }
    
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView()
    .environment(ViewModel())
  
    .frame(minWidth: 1250, maxWidth: .infinity)
}
