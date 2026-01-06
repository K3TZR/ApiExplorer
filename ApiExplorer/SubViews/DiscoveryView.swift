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
  let radioList: [Radio]
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  @State var discoveryDisplayType: DiscoveryDisplayType = .vitaHeaderView
  @State var radioSelection: String?
  @State var data: Data?
  
  public var body: some View {
    let radios = radioList
    
    VStack(alignment: .center) {
      Text("Discovery Broadcasts").font(.title)
      
      HStack {
        Picker("Display", selection: $discoveryDisplayType) {
          ForEach(DiscoveryDisplayType.allCases, id: \.self) {
            Text($0.rawValue).tag($0)
          }
        }
        .labelsHidden()
        //        .frame(width: 250)
        
        if discoveryDisplayType != .discoveryTimingView {
          Picker("Choose a Radio", selection: $radioSelection) {
            Text("--- Select a Radio ---").tag(nil as String?)
            ForEach(radios, id: \.id) { radio in
              if radio.packet.source == .local {
                Text(radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname).tag(radio.id)
              }
            }
          }
          .labelsHidden()
          //          .frame(width: 250)
        }
      }
      if let index = radios.firstIndex(where: { $0.id == radioSelection }) {
        VStack (alignment: .leading, spacing: 5) {
          switch discoveryDisplayType  {
          case .vitaHeaderView:
            if let data = radios[index].discoveryData, let vita = Vita.decode(from: data) {
              VitaHeaderView(vita: vita)
            } else {
              Text("No discovery data")
            }
          case .vitaPayloadView:    VitaPayloadView(data: radioList[index].discoveryData!)
          case .vitaHexView:        VitaHexView(data: radioList[index].discoveryData!)
          default:
            EmptyView()
          }
        }
      } else {
        EmptyView()
      }
      
      //      switch settings.discoveryDisplayType  {
      //      case .vitaHeader, .vitaPayload, .vitaByteMap:
      //        if let data {
      //          if settings.discoveryDisplayType == .vitaHeader { VitaHeaderView(data: data)}
      //          if settings.discoveryDisplayType == .vitaPayload { VitaPayloadView(data: data)}
      //          if settings.discoveryDisplayType == .vitaByteMap { VitaHexView(data: data)}
      //        } else {
      //          Spacer()
      //          EmptyView()
      //          Spacer()
      //
      //          Divider()
      //            .frame(height: 2)
      //            .background(Color.gray)
      //
      //          HStack {
      //            Spacer()
      //            Button("Close") { dismiss() }
      //              .keyboardShortcut(.defaultAction)
      //          }
      //        }
      //      case .timing: TimingView(start: Date())
      //      }
      Spacer()
    }
    .monospaced()
    .padding()
    .frame(width: 600, height: 800)
  }
}

private struct VitaHeaderView: View {
  let vita: Vita
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack {
      Text("Packet Type")
      Spacer()
      Text(verbatim: vita.packetType.description()).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Class Code")
      Spacer()
      Text(verbatim: vita.classCode.description()).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Packet Size")
      Spacer()
      Text(verbatim: String(vita.packetSize)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Header Size")
      Spacer()
      Text(verbatim: String(vita.headerSize)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Payload Size")
      Spacer()
      Text(verbatim: String(vita.payloadSize)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Stream ID")
      Spacer()
      Text(verbatim: String(vita.streamId)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Tsi Type")
      Spacer()
      Text(verbatim: String(describing: vita.tsiType)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Tsf Type")
      Spacer()
      Text(verbatim: String(describing: vita.tsfType)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Sequence")
      Spacer()
      Text(verbatim: String(vita.sequence)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Integer Time Stamp")
      Spacer()
      Text(verbatim: String(vita.integerTimestamp)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Frac Time Stamp Lsb")
      Spacer()
      Text(verbatim: String(vita.fracTimeStampLsb)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Frac Time Stamp Msb")
      Spacer()
      Text(verbatim: String(vita.fracTimeStampMsb)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("OUI")
      Spacer()
      Text(verbatim: String(vita.oui)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Information Class Code")
      Spacer()
      Text(verbatim: String(vita.informationClassCode)).frame(alignment: .trailing)
    }
    
    HStack {
      Text("Trailer")
      Spacer()
      Text(verbatim: String(vita.trailer)).frame(alignment: .trailing)
    }.background(Color.gray.opacity(0.2))
    
    HStack {
      Text("Trailer Present")
      Spacer()
      Text(verbatim: String(vita.trailerPresent)).frame(alignment: .trailing)
    }
    Spacer()
    
    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack {
      Spacer()
      Button("Close") { dismiss() }
        .keyboardShortcut(.defaultAction)
    }
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
      Button("Close") { dismiss() }
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
  let fontSize: CGFloat = 14

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        Text("Byte Count: \(data.count.toHex()) (\(data.count))")
        Spacer()
      }

      // Header row for hex dump
      Text("      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F")
        .font(.system(size: fontSize, weight: .medium, design: .monospaced))

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      Text("--- Header ---")

      ForEach(Array(viewModel.vitaHeader(data).enumerated()), id: \.offset) { index, string in
        HStack {
          Text(String(format: "%04X:", index * 16))
          Text(string)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
            .font(.system(size: fontSize, weight: .medium, design: .monospaced))
          }
        }
      }

      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Button("Save") {
          document = SaveDocument(text: viewModel.vitaString(data, utf8))
          isSaving = true
        }
        Spacer()
        Button("Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
      }
    }
    .font(.system(.body, design: .monospaced))
    .padding()

    .fileExporter(isPresented: $isSaving, document: document, contentType: .plainText, defaultFilename: "ApiExplorer.bcast") { result in
      switch result {
      case .success(let url):
        appLog(.info, "DiscoveryView: Broadcast Exported to \(String(describing: url))")
      case .failure(let error):
        appLog(.warning, "DiscoveryView: Broadcast Export failed, \(error)")
      }
    }
  }
}

//private struct TimingView: View {
//  let start: Date
//
//  @Environment(ViewModel.self) private var viewModel
//  @Environment(\.dismiss) var dismiss
//
//  let timeLimit: TimeInterval = 3
//
//  var body: some View {
//    @Bindable var settings = viewModel.settings
//
//    TimelineView(.periodic(from: start, by: 1)) { _ in
//
//      VStack(spacing: 0) {
//        // Fixed Header
//        Grid(alignment: .leading) {
//          GridRow {
//            Text("Radio Name")
//              .frame(width: 125, alignment: .leading)
//            Text("IP Address")
//              .frame(width: 200, alignment: .leading)
//            Text("Peak Interval").frame(maxWidth: .infinity, alignment: .trailing)
//          }
//          Divider()
//            .frame(height: 2)
//            .background(Color.gray)
//        }
//        .padding(.horizontal)
//
//        // Scrollable rows
//        ScrollView {
//          Grid(alignment: .leading, verticalSpacing: 10) {
//            ForEach(Array(viewModel.api.radios
//              .sorted(by: { $0.packet.nickname < $1.packet.nickname })
//              .enumerated()), id: \.element.id) { index, radio in
//
//                if radio.packet.source == .local {
//                  GridRow {
//                    let displayName = radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname
//
//                    Text(displayName)
//                      .frame(width: 125, alignment: .leading)
//                      .lineLimit(1)
//                      .truncationMode(.tail)
//                      .help(displayName)
//
//                    HStack(spacing: 5) {
//                      Text(radio.packet.publicIp)
//                      Button(action: {
//                        viewModel.pingResult = ""
//                        viewModel.ping(radio.packet.publicIp)
//                      }) {
//                        Image(systemName: "parkingsign.circle")
//                          .font(.title3)
//                          .help("Ping this Radio")
//                      }
//                      .buttonStyle(.plain)
//                    }
//                    .frame(width: 200, alignment: .leading)
//
//                    Text(String(format: "%0.3f", radio.intervalPeak))
//                      .frame(maxWidth: .infinity, alignment: .trailing)
//                      .foregroundColor(radio.intervalPeak > timeLimit ? .red : nil)
//                      .monospacedDigit()
//                  }
//                }
//              }
//          }
//          .padding(.horizontal)
//          .padding(.bottom, 16)
//        }
//
//        // Ping result + summary
//        VStack(alignment: .leading, spacing: 8) {
//          Text(viewModel.pingResult)
//            .frame(alignment: .leading)
//
//          HStack {
//            Spacer()
//            Text("Peak > \(String(format: "%0.3f", timeLimit))").bold()
//            Text("seconds shown in")
//            Text("RED").foregroundColor(.red).bold()
//          }
//        }
//        .padding()
//
//        Divider()
//          .frame(height: 2)
//          .background(Color.gray)
//
//        // Footer
//        HStack(spacing: 5) {
//          Text("UDP Port:")
//          Text(viewModel.settings.discoveryPort, format: .number)
//
//          Spacer()
//
//          Button("Close") { dismiss() }
//            .keyboardShortcut(.defaultAction)
//        }
//      }
//    }
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("DiscoveryView") {
  DiscoveryView(radioList: [])
}
