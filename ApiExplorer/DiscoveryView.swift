//
//  DiscoveryView.swift
//  ApiViewer
//
//  Created by Douglas Adams on 2/16/25.
//


import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct DiscoveryView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var radioSelection: String?
  
  public var body: some View {
    @Bindable var viewModel = viewModel
    
    VStack(alignment: .center) {
      Text("Discovery").font(.title)
      
      HStack {
        Picker("Choose a Radio", selection: $radioSelection) {
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
      
      switch viewModel.settingModel.discoveryDisplayType  {
      case .fields:     FieldsView(id: radioSelection)
      case .keyValues:  KeyValuesView(id: radioSelection)
      case .hex:        RawView(id: radioSelection)
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

private struct FieldsView: View {
  let id: String?
  
  @Environment(ViewModel.self) private var viewModel
  
  
  var vita: Vita? {
    guard let index = viewModel.objectModel.radios.firstIndex(where: {$0.id == id}) else { return nil }
    guard let data = viewModel.objectModel.radios[index].discoveryData else { return nil }
    return Vita.decode(from: data)
  }
  
  var body: some View {
    if let vita {
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
    } else {
      VStack {
        Spacer()
        Text("No Vita Data")
        Text("Did you choose a Radio?")
        Spacer()
      }
    }
  }
}

private struct KeyValuesView: View {
  let id: String?
  
  @Environment(ViewModel.self) private var viewModel
  
  var properties: KeyValuesArray? {
    guard let index = viewModel.objectModel.radios.firstIndex(where: {$0.id == id}) else { return nil }
    guard let data = viewModel.objectModel.radios[index].discoveryData else { return nil }
    return viewModel.propertiesDump(data)
  }

  var body: some View {
    if let properties {
      ScrollView {
        Grid (alignment: .leading, verticalSpacing: 10) {
          ForEach(properties, id: \.key) { property in
            GridRow {
              Text(property.key)
              Text(property.value).gridColumnAlignment(.trailing)
            }
          }
        }
      }
    } else {
      VStack {
        Spacer()
        Text("No Vita Data")
        Text("Did you choose a Radio?")
        Spacer()
      }
    }
  }
}
  
private struct RawView: View {
  let id: String?
  
  @Environment(ViewModel.self) private var viewModel
  
  var raw: String? {
    guard let index = viewModel.objectModel.radios.firstIndex(where: {$0.id == id}) else { return nil }
    guard let data = viewModel.objectModel.radios[index].discoveryData else { return nil }
    return viewModel.hexDump(data)
  }
  
  var body: some View {
    if let raw {
      ScrollView {
        Text(raw)
      }
    } else {
      VStack {
        Spacer()
        Text("No Vita Data")
        Text("Did you choose a Radio?")
        Spacer()
      }
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
