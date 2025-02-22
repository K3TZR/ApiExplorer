//
//  SmartlinkLoginView.swift
//  
//
//  Created by Douglas Adams on 12/28/21.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct SmartlinkLoginView: View {

  @Environment(ViewModel.self) var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var password = ""

  public var body: some View {
    @Bindable var viewModel = viewModel

    VStack(spacing: 10) {
      Text( "Smartlink Login" ).font( .title2 )
      Divider()
      HStack {
        Text( "User" )
        TextField( "", text: $viewModel.settingModel.smartlinkUser)
      }
      HStack {
        Text( "Password")
        SecureField( "", text: $password)
      }
      
      HStack( spacing: 60 ) {
        Button( "Cancel" ) {
          viewModel.smartlinkCancelButtonTapped()
          dismiss()
        }
          .keyboardShortcut( .cancelAction )
        
        Button( "Log in" ) { 
          viewModel.smartlinkLoginButtonTapped(viewModel.settingModel.smartlinkUser, password)
          dismiss() }
          .keyboardShortcut( .defaultAction )
          .disabled( viewModel.settingModel.smartlinkUser.isEmpty || password.isEmpty )
      }
    }
//    .frame( minWidth: store.overallWidth )
    .padding(10)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  SmartlinkLoginView()
    .environment(ViewModel())
}
