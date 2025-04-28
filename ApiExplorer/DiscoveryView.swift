//
//  DiscoveryView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 2/16/25.
//


import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct DiscoveryView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var radioSelection: String?
  
  var data: Data? {
    if let index = viewModel.api.radios.firstIndex(where: {$0.id == radioSelection}) {
      return viewModel.api.radios[index].discoveryData
    }
    return nil
  }
  
  public var body: some View {
    @Bindable var viewModel = viewModel
    @Bindable var settings = viewModel.settings
    
    VStack(alignment: .center) {
      Text("Discovery Broadcasts").font(.title)
      
      HStack {
        Picker("Display", selection: $settings.discoveryDisplayType) {
          ForEach(DiscoveryDisplayType.allCases, id: \.self) {
            Text($0.rawValue).tag($0)
          }
        }
        .labelsHidden()
        //        .frame(width: 250)
        
        if settings.discoveryDisplayType != .timing {
          Picker("Choose a Radio", selection: $radioSelection) {
            Text("--- Select a Radio ---").tag(nil as String?)
            ForEach(viewModel.api.radios.sorted(by: {$0.packet.nickname < $1.packet.nickname}), id: \.id) { radio in
              if radio.packet.source == .local {
                Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname).tag(radio.id)
              }
            }
          }
          .labelsHidden()
          //          .frame(width: 250)
        }
      }
      
      switch settings.discoveryDisplayType  {
      case .vitaHeader, .vitaPayload, .vitaByteMap:
        if let data {
          if settings.discoveryDisplayType == .vitaHeader { VitaHeaderView(data: data)}
          if settings.discoveryDisplayType == .vitaPayload { VitaPayloadView(data: data)}
          if settings.discoveryDisplayType == .vitaByteMap { VitaHexView(data: data)}
        } else {
          Spacer()
          EmptyView()
          Spacer()
          
          Divider()
            .frame(height: 2)
            .background(Color.gray)
          
          HStack {
            Spacer()
            ButtonX(title: "Close") { dismiss() }
              .keyboardShortcut(.defaultAction)
          }
        }
      case .timing: TimingView(start: Date())
      }
    }
    .monospaced()
    .padding()
    //    .frame(height: 600)
  }
}

private struct VitaHeaderView: View {
  let data: Data
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  var vita: Vita {
    Vita.decode(from: data)!
  }
  
  var body: some View {
    VStack (alignment: .leading, spacing: 5) {
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      HStack {
        Text("Packet Type")
        Spacer()
        Text(vita.packetType.description()).frame(alignment: .trailing)
      }
      
      HStack {
        Text("Class Code")
        Spacer()
        Text(vita.classCode.description()).frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Packet Size")
        Spacer()
        Text("\(vita.packetSize)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Header Size")
        Spacer()
        Text("\(vita.headerSize)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Payload Size")
        Spacer()
        Text("\(vita.payloadSize)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Stream ID")
        Spacer()
        Text("\(vita.streamId)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Tsi Type")
        Spacer()
        Text("\(vita.tsiType)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Tsf Type")
        Spacer()
        Text("\(vita.tsfType)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Sequence")
        Spacer()
        Text("\(vita.sequence)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Integer Time Stamp")
        Spacer()
        Text("\(vita.integerTimestamp)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Frac Time Stamp Lsb")
        Spacer()
        Text("\(vita.fracTimeStampLsb)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Frac Time Stamp Msb")
        Spacer()
        Text("\(vita.fracTimeStampMsb)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("OUI")
        Spacer()
        Text("\(vita.oui)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Information Class Code")
        Spacer()
        Text("\(vita.informationClassCode)").frame(alignment: .trailing)
      }
      
      HStack {
        Text("Trailer")
        Spacer()
        Text("\(vita.trailer)").frame(alignment: .trailing)
      }.background(Color.gray.opacity(0.2))
      
      HStack {
        Text("Trailer Present")
        Spacer()
        Text("\(vita.trailerPresent)").frame(alignment: .trailing)
      }
      Spacer()
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      HStack {
        Spacer()
        ButtonX(title: "Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct VitaPayloadView: View {
  let data: Data
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var even = false
  
  var body: some View {
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    ScrollView {
      VStack(spacing: 5) {
        ForEach(viewModel.payloadProperties(data) , id: \.key) { property in
          HStack {
            Text(property.key)
              .frame(alignment: .leading)
            Spacer()
            Text(property.value)
              .frame(alignment: .trailing)
          }
          .background(property.index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack {
      Spacer()
      ButtonX(title: "Close") { dismiss() }
        .keyboardShortcut(.defaultAction)
    }
  }
}

private struct VitaHexView: View {
  let data: Data
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var isSaving = false
  @State var document: SaveDocument?
  @State var utf8 = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        Text("Bytes: \(data.count.toHex())")
        Spacer()
      }
      
      // Header row for hex dump
      Text("      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F")
        .font(.system(.body, design: .monospaced))
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      Text("--- Header ---")
      
      ForEach(Array(viewModel.vitaHeader(data).enumerated()), id: \.offset) { index, string in
        HStack {
          Text(String(format: "%04X:", index * 16))
          Text(string)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
      }
      
      HStack {
        Text("--- Payload ---")
        Spacer()
        Toggle("UTF8", isOn: $utf8)
      }

      ScrollView {
        
        VStack(spacing: 5) {
          ForEach(Array(viewModel.vitaPayload(data, utf8).enumerated()), id: \.offset) { index, string in
            HStack {
              Text(String(format: "%04X:", (index * 16) + 16))
              Text(string)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
          }
        }
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      HStack {
        ButtonX(title: "Save") {
          document = SaveDocument(text: viewModel.vitaString(data, utf8))
          isSaving = true
        }
        Spacer()
        ButtonX(title: "Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
      }
    }
    .font(.system(.body, design: .monospaced))
    .padding()
    
    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiExplorer.bcast") { result in
      switch result {
      case .success(let url):
        Task { await AppLog.info("ApiExplorer: Broadcast Exported to \(String(describing: url))") }
      case .failure(let error):
        Task { await AppLog.warning("ApiExplorer: Broadcast Export failed, \(error)") }
      }
    }
  }
}

private struct TimingView: View {
  let start: Date

  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var ticks = 0
  
  func formatMinutesAndSeconds(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "mm:ss"
    return formatter.string(from: date)
  }
  
  func average(_ intervals: [Double]) -> String {
    guard !intervals.isEmpty else { return "---" }
    
    let nonZero = intervals.filter {$0 != 0}
    let count = nonZero.count
    if count == 0 {
      return "---"
    } else {
      let avg = nonZero.reduce(0, +) / Double(count)
      return String(format: "%.3f", avg)
    }
  }
  
  func peak(_ intervals: [Double]) -> String {
    guard !intervals.isEmpty else { return "---" }
    let max = intervals.max() ?? 0
    if max == 0 {
      return "---"
    } else {
      return String(format: "%.3f", max)
    }
  }
  
  
  var body: some View {
    @Bindable var settings = viewModel.settings

    VStack {
      HStack {
        Text("Radio Name")
          .frame(width: 150, alignment: .leading)
        
        Spacer()
        
        Text("Average")
          .frame(width: 150, alignment: .trailing)
        
        Spacer()
        
        Text("Peak")
          .frame(width: 150, alignment: .trailing)
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      TimelineView(.periodic(from: Date(), by: 10)) { context in
        
        ScrollView {
          VStack(spacing: 5) {
            ForEach(Array(viewModel.api.radios.sorted(by: { $0.packet.nickname < $1.packet.nickname }).enumerated()), id: \.element.id) { index, radio in
              if radio.packet.source == .local {
                HStack{
                  Text(radio.packet.nickname)
                    .frame(width: 150, alignment: .leading)
                  
                  Spacer()
                  
                  Text(average(radio.intervals))
                    .frame( width: 150, alignment: .trailing)
                  
                  Spacer()
                  
                  Text(peak(radio.intervals))
                    .frame( width: 150, alignment: .trailing)
                    .foregroundColor( Int(radio.intervals.max() ?? 0) > 10 ? .red : nil)
                }
                .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
              }
            }
          }
        }
        
        Spacer()
        VStack {
          HStack {
            Text(Int(context.date.timeIntervalSince(start)), format: .number).bold()
            Text("Seconds")
            Spacer()
            Text("Peak > 10").bold()
            Text("seconds shown in")
            Text("RED").foregroundColor(.red).bold()
          }
//          HStack {
//            Spacer()
//          }
        }
        
        Divider()
          .frame(height: 2)
          .background(Color.gray)
        
        HStack {
          Text("Port")
          Text(viewModel.settings.discoveryPort, format: .number)
            .frame(width: 120)
          
          Spacer()
          ButtonX(title: "Close") { dismiss() }
            .keyboardShortcut(.defaultAction)
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("DiscoveryView") {
  DiscoveryView()
    .environment(ViewModel(SettingsModel()))
}
