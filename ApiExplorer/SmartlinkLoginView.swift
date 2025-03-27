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
  @Environment(SettingsModel.self) private var settings
//  @Environment(\.dismiss) var dismiss
  
  @State var password = ""
  
  public var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = settings

    VStack(spacing: 10) {
      Text( "Smartlink Login" ).font( .title2 )
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      Grid(alignment: .leading) {
        GridRow {
          Text( "User" ).frame(alignment: .leading)
          TextField( "", text: $settings.smartlinkUser)
        }
        GridRow {
          Text( "Password").frame(alignment: .leading)
         TextField( "", text: $password)
        }
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack( spacing: 60 ) {
        ButtonX(title: "Cancel" ) {
          viewModel.smartlinkCancelButtonTapped()
        }
        .keyboardShortcut( .cancelAction )
        
        ButtonX(title: "Log in" ) {
          viewModel.smartlinkLoginButtonTapped(settings.smartlinkUser, password)
        }
        .keyboardShortcut( .defaultAction )
        .disabled( settings.smartlinkUser.isEmpty || password.isEmpty )
      }
    }
    .frame(width: 300)
    .padding(10)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  SmartlinkLoginView()
    .environment(ViewModel())
}
