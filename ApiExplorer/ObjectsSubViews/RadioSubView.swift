//
//  RadioSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

// import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioSubView: View {
  @Environment(ViewModel.self) var viewModel
  
  @State var showDetails = true
  
  //  @MainActor private func sourceColor(_ packet: Packet) -> Color {
  //    packet.source == .local ? .blue : .red
  //  }
  
  var body: some View {
    
    if viewModel.objectModel.activeSelection != nil {
      let radio = viewModel.objectModel.activeSelection!.radio
      ScrollView([.vertical, .horizontal]) {
        
        VStack(alignment: .leading) {
          HStack(spacing: 0) {
            Label("Radio", systemImage: showDetails ? "chevron.down" : "chevron.right")
              .frame(width: 125, alignment: .leading)
              .font(.title)
              .foregroundColor(.green)
              .onTapGesture{ showDetails.toggle() }
              .help("          Tap to toggle details")
            
            Line1View(radio: radio)
          }
          
          if showDetails { DetailView() }
        }
      }
    }
  }
}

private struct Line1View: View {
  let radio: Radio
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    HStack(spacing: 20) {
      
      Text(radio.packet.source.rawValue.uppercased()).foregroundColor(.green)

      HStack(spacing: 5) {
        Text("ip")
        Text(radio.packet.publicIp).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("FW")
        Text(radio.packet.version).foregroundColor(.green)
        Text("\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : nil)
      }
      
      HStack(spacing: 5) {
        Text("Model")
        Text(radio.packet.model).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Serial")
        Text(radio.packet.serial).foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("HW")
        Text(viewModel.objectModel.hardwareVersion ?? "").foregroundColor(.green)
      }
      
      HStack(spacing: 5) {
        Text("Uptime")
        Text("\(radio.uptime)").foregroundColor(.green)
        Text("(seconds)")
      }
      
      HStack(spacing: 5) {
        Text("TNF's Enabled")
        Text("\(radio.tnfsEnabled ? "Y" : "N")").foregroundColor(radio.tnfsEnabled ? .green : .red)
      }
      
      HStack(spacing: 5) {
        Text("MF Enabled")
        Text("\(radio.multiflexEnabled ? "Y" : "N")").foregroundColor(radio.multiflexEnabled ? .green : .red)
      }
    }
    .frame(alignment: .leading)
    .padding(.leading, 20)
  }
}

private struct DetailView: View {

  @Environment(ViewModel.self) var viewModel

  var body: some View {
    
    VStack(alignment: .leading) {
      switch viewModel.settingModel.radioObjectFilter {
      case .all:
        AtuSubView()
        BandSettingSubView()
        EqualizerSubView()
        GpsSubView()
        MemorySubView()
        MeterSubView()
        ListsView()
        TnfSubView()
        TransmitSubView()
      case .atu:          AtuSubView()
      case .bandSettings: BandSettingSubView()
      case .equalizers:   EqualizerSubView()
      case .gps:          GpsSubView()
      case .lists:        ListsView()
      case .memories:     MemorySubView()
      case .meters:       MeterSubView()
      case .tnf:          TnfSubView()
      case .transmit:     TransmitSubView()
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView()
    .environment(ViewModel())
  
    .frame(minWidth: 1250)
}
