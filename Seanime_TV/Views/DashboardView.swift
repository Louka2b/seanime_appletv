import SwiftUI

struct DashboardView: View {
    @State private var selectedMenu = "Library"
    @Environment(\.serverReset) var serverReset: () -> Void
    @FocusState private var focusedSection: FocusArea?
    
    enum FocusArea: Hashable {
        case sidebar, content
    }

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // SIDEBAR
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.circle.fill").font(.system(size: 45)).foregroundColor(.blue)
                        Text("Seanime").font(.system(size: 35, weight: .black))
                    }.padding(.bottom, 50)
                    
                    MenuButton(title: "Library", icon: "play.square.stack.fill", isSelected: selectedMenu == "Library", action: {
                        selectedMenu = "Library"
                        focusedSection = .content
                    })
                    .focused($focusedSection, equals: .sidebar)
                    
                    MenuButton(title: "Settings", icon: "gearshape.fill", isSelected: selectedMenu == "Settings", action: {
                        selectedMenu = "Settings"
                        focusedSection = .content
                    })
                    .focused($focusedSection, equals: .sidebar)
                    
                    Spacer()
                    
                    Button(action: {
                        Constants.baseURL = ""
                        serverReset()
                    }) {
                        HStack { Image(systemName: "power"); Text("Logout") }
                        .foregroundColor(.red.opacity(0.7)).padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focused($focusedSection, equals: .sidebar)
                }
                .frame(width: 350).padding(40).background(Color(white: 0.05))
                
                // MAIN CONTENT
                ZStack {
                    Color(white: 0.02).edgesIgnoringSafeArea(.all)
                    if selectedMenu == "Library" {
                        LibraryGridView()
                            .focused($focusedSection, equals: .content)
                    } else {
                        SettingsInternalView()
                            .focused($focusedSection, equals: .content)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(.stack)
        .onAppear { focusedSection = .sidebar }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.isFocused) var isFocused
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon).frame(width: 40)
                Text(title)
            }
            .font(.system(size: 28, weight: .medium))
            .foregroundColor(isSelected || isFocused ? .white : .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.3) : (isFocused ? Color.white.opacity(0.1) : Color.clear))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInternalView: View {
    @State private var transcodeEnabled = false
    @State private var hwAccel = "none"
    @State private var settings: SeanimeSettings?
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SETTINGS").font(.system(size: 50, weight: .black)).padding(60)
            
            List {
                Section(header: Text("TRANSCODING (PC)")) {
                    Toggle("Force Transcoding for MKV", isOn: $transcodeEnabled)
                        .focused($focusedField, equals: 1)
                        .onChange(of: transcodeEnabled) { _, newValue in save(enabled: newValue, accel: hwAccel) }
                    
                    Button(action: {
                        hwAccel = (hwAccel == "none") ? "videotoolbox" : (hwAccel == "videotoolbox" ? "nvenc" : "none")
                        save(enabled: transcodeEnabled, accel: hwAccel)
                    }) {
                        HStack {
                            Text("Hardware Acceleration")
                            Spacer()
                            Text(hwAccel.uppercased()).foregroundColor(.blue)
                        }
                    }
                    .focused($focusedField, equals: 2)
                }
            }
            .padding(.horizontal, 60)
        }
        .onAppear { 
            focusedField = 1
            fetch() 
        }
    }
    
    func fetch() {
        Task {
            do {
                let response: SeanimeResponse<MediastreamSettings> = try await APIClient.shared.fetch(endpoint: "/api/v1/mediastream/settings")
                if let data = response.data {
                    self.settings = SeanimeSettings(mediastream: data)
                    self.transcodeEnabled = data.transcodeEnabled ?? false
                    self.hwAccel = data.transcodeHwAccel ?? "none"
                }
            } catch { print(error) }
        }
    }
    
    func save(enabled: Bool, accel: String) {
        Task {
            let s = MediastreamSettings(transcodeEnabled: enabled, transcodeHwAccel: accel)
            let _: SeanimeResponse<MediastreamSettings> = try await APIClient.shared.patch(endpoint: "/api/v1/mediastream/settings", body: ["settings": s])
        }
    }
}
