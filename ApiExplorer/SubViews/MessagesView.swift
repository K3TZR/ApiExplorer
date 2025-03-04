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
    if !viewModel.settings.messageFilterText.isEmpty {
      if let range = attString.range(of: viewModel.settings.messageFilterText) {
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
      }
      else {
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
//    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

private struct FilterView: View {
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    @Bindable var viewModelBinding = viewModel
    
    HStack {
      Picker("Show Tcp Messages of type", selection: $viewModelBinding.settings.messageFilter) {
        ForEach(MessagesModel.Filter.allCases, id: \.self) {
          Text($0.rawValue).tag($0)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      
      .onChange(of: viewModel.settings.messageFilter) { _ , newValue in
        viewModel.messages.reFilter(newValue, viewModel.settings.messageFilterText)
      }
      
      Image(systemName: "x.circle").font(.title2)
        .onTapGesture {
          viewModel.settings.messageFilterText = ""
//          viewModel.messagesModel.filtersChanged(viewModel.settings.messageFilter, viewModel.settings.messageFilterText)
        }
      
      TextField("filter text", text: $viewModelBinding.settings.messageFilterText)
        
        .onChange(of: viewModel.settings.messageFilterText) { _, newValue in
          viewModel.messages.reFilter(viewModel.settings.messageFilter, newValue)
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
