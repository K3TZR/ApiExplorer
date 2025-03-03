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
    if let index = viewModel.apiModel.radios.firstIndex(where: {$0.id == radioSelection}) {
      return viewModel.apiModel.radios[index].discoveryData
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
          ForEach(viewModel.apiModel.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
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
      if viewModel.settingModel.discoveryDisplayType != .hex {
        Divider()
        FooterView()
      }
    }
    .monospaced()
    .padding()
    .frame(height: 600)
    
    // Save Dialog
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
  
  @State var isSaving = false
  @State var document: BroadcastDocument?

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  struct BroadcastDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var text: String
    
    init(text: String = "") {
        self.text = text
    }

      // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            text = string
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
  }

  var body: some View {
    VStack {
      ScrollView {
        Text(viewModel.hexDump(data))
      }

      Divider()

      HStack {
        Button("Save") {
          document = BroadcastDocument(text: viewModel.hexDump(data))
          isSaving = true
        }
        Spacer()
        Button("Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
      }
    }
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiViewer.bcast") { result in
        switch result {
        case .success(let url):
          log.info("ApiViewer: Broadcast Exported to \(url)")
        case .failure(let error):
          log.warning("ApiViewer: Broadcast Export failed, \(error)")
        }
      }
  }
}

private struct FooterView: View {
//  let data: Data?
//  let isSaving: Binding<Bool>
//  let document: Binding<BroadcastDocument?>

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    HStack {
//      Button("Save") {
//        document.wrappedValue = BroadcastDocument(text: viewModel.hexDump(data!))
//        isSaving.wrappedValue = true
//      }
//      .disabled(data == nil)
      
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

// ----------------------------------------------------------------------------
// MARK: - Save support

import UniformTypeIdentifiers

struct BroadcastDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.plainText] }
  
  var text: String
  
  init(text: String = "") {
      self.text = text
  }

    // this initializer loads data that has been saved previously
  init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents,
         let string = String(data: data, encoding: .utf8) {
          text = string
      } else {
          throw CocoaError(.fileReadCorruptFile)
      }
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      let data = text.data(using: .utf8) ?? Data()
      return FileWrapper(regularFileWithContents: data)
  }
}
