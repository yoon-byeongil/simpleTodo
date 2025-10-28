import SwiftUI

struct SettingsView: View {
    var openMenu: () -> Void
    @State private var allowNotifications = false
    @State private var isDarkMode = false
    @State private var autoDelete = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("설정")) {
                    Toggle("알림", isOn: $allowNotifications)
                    Toggle("다크 모드", isOn: $isDarkMode)
                    Toggle("완료된 항목 자동 삭제", isOn: $autoDelete)
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("버전 1.0.0")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(openMenu: {})
}
