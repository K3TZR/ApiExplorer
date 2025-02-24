//
//  DiscoveryView.swift
//  ApiViewer
//
//  Created by Douglas Adams on 2/16/25.
//


import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct DiscoveryView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var radioSelection: String?
  
  var data: Data? {
    if let index = viewModel.objectModel.radios.firstIndex(where: {$0.id == radioSelection}) {
      return viewModel.objectModel.radios[index].discoveryData
    }
    return nil
  }
  
  public var body: some View {
    @Bindable var viewModel = viewModel
    
    VStack(alignment: .center) {
      Text("Discovery").font(.title)
      
      HStack {
        Picker("Choose a Radio", selection: $radioSelection) {
          Text("Select a Radio").tag(nil as String?)
          ForEach(viewModel.objectModel.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
            Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname).tag(radio.id)
          }
        }.frame(width: 250)
        Picker("Display", selection: $viewModel.settingModel.discoveryDisplayType) {
          ForEach(DiscoveryDisplayType.allCases, id: \.self) {
            Text($0.rawValue).tag($0)
          }
        }.frame(width: 250)
      }
      
      Divider().frame(height: 2).overlay(.blue)
      
      if let data {
        switch viewModel.settingModel.discoveryDisplayType  {
        case .fields:     VitaFieldsView(data: data)
        case .keyValues:  PayloadFieldsView(data: data)
        case .hex:        RawView(data: data)
        }
        
      } else {
        VStack {
          Spacer()
          Text("Did you choose a Radio?")
          Spacer()
        }
      }
      Spacer()
      Divider()
      FooterView()
    }
    .monospaced()
    .padding()
    .frame(height: 600)
    
  }
}

private struct VitaFieldsView: View {
  let data: Data
  
  @Environment(ViewModel.self) private var viewModel
  
  var vita: Vita {
    Vita.decode(from: data)!
  }
  
  var body: some View {
    ScrollView {
      Grid (alignment: .leading, verticalSpacing: 10) {
        GridRow {
          Text("Packet Type")
          Text(vita.packetType.description()).gridColumnAlignment(.trailing)
        }
        GridRow {
          Text("Class Code")
          Text(vita.classCode.description())
        }
        GridRow {
          Text("Packet Size")
          Text("\(vita.packetSize)")
        }
        GridRow {
          Text("Header Size")
          Text("\(vita.headerSize)")
        }
        GridRow {
          Text("Payload Size")
          Text("\(vita.payloadSize)")
        }
        GridRow {
          Text("Stream ID")
          Text("\(vita.streamId)")
        }
        GridRow {
          Text("Tsi Type")
          Text("\(vita.tsiType)")
        }
        GridRow {
          Text("Tsf Type")
          Text("\(vita.tsfType)")
        }
        GridRow {
          Text("Sequence")
          Text("\(vita.sequence)")
        }
        GridRow {
          Text("Integer Time Stamp")
          Text("\(vita.integerTimestamp)")
        }
        GridRow {
          Text("Frac Time Stamp Lsb")
          Text("\(vita.fracTimeStampLsb)")
        }
        GridRow {
          Text("Frac Time Stamp Msb")
          Text("\(vita.fracTimeStampMsb)")
        }
        GridRow {
          Text("OUI")
          Text("\(vita.oui)")
        }
        GridRow {
          Text("Information Class Code")
          Text("\(vita.informationClassCode)")
        }
        GridRow {
          Text("Trailer")
          Text("\(vita.trailer)")
        }
        GridRow {
          Text("Trailer Present")
          Text("\(vita.trailerPresent)")
        }
      }
    }
  }
}

private struct PayloadFieldsView: View {
  let data: Data
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    ScrollView {
      Grid (alignment: .leading, verticalSpacing: 10) {
        ForEach(viewModel.payloadProperties(data) , id: \.key) { property in
          GridRow {
            Text(property.key)
            Text(property.value).gridColumnAlignment(.trailing)
          }
        }
      }
    }
  }
}

private struct RawView: View {
  let data: Data

  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    ScrollView {
      Text(viewModel.hexDump(data))
    }
  }
}

private struct FooterView: View {
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    HStack {
      Spacer()
      Button("Close") { dismiss() }
        .keyboardShortcut(.defaultAction)
    }
    .padding(.horizontal)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("DiscoveryView") {
  DiscoveryView()
    .environment(ViewModel())
}
