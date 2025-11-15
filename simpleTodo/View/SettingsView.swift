import SwiftUI

struct SettingsView: View {
    var openMenu: () -> Void
    @EnvironmentObject var viewModel: ScheduleViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("설정")) {
                    // 알림 허용
                    Toggle("알림 허용", isOn: $viewModel.allowNotifications)
                        .onChange(of: viewModel.allowNotifications) {
                            viewModel.toggleNotificationPermission()
                        }
                    
                    // 다크 모드
                    Toggle("다크 모드", isOn: $viewModel.isDarkMode)
                    
                    // 완료된 항목 자동 삭제
                    Toggle("완료된 항목 자동 삭제", isOn: $viewModel.autoDeleteCompleted)
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
            .onAppear {
                viewModel.refreshNotificationStatus()
            }
        }
    }
}

#Preview {
    SettingsView(openMenu: {})
        .environmentObject(ScheduleViewModel())
}
