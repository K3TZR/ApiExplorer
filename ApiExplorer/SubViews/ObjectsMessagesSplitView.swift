//
//  ObjectsMessagesSplitView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 5/14/25.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - Custom Split View

public struct ObjectsMessagesSplitView: View {
  let viewMode: ViewMode
  
 public  var body: some View {
    
    VStack(spacing: 10) {
      
      switch viewMode {
      case .all:
        ObjectsView(viewMode: viewMode)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        MessagesView()
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        MessagesButtonsView()
 
      case .messages:
        ObjectsView(viewMode: viewMode)
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        MessagesView()
          .frame(maxWidth: .infinity)
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        MessagesButtonsView()
        
      case .objects:
        ObjectsView(viewMode: viewMode)
          .frame(maxWidth: .infinity)
      }
    }
    .frame(maxHeight: .infinity)
  }
}
