//
//  NotImplementedView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 3/1/25.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct NotImplementedView: View {
  
  public var body: some View {
    
    VStack(spacing: 20) {
      Text("Not Implemented (yet)").font(.title)
    }
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  NotImplementedView()
}
