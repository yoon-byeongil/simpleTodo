import SwiftUI

/// 메인 컨테이너 뷰 (사이드 메뉴 + 메인 화면 구성)
struct ContentView: View {
    // 현재 선택된 탭 상태
    @State private var selectedTab: Tab = .home
    // 메뉴 열림 여부
    @State private var isMenuOpen = false
    // ✅ 하나의 ViewModel을 전역에서 공유
    @StateObject private var scheduleViewModel = ScheduleViewModel()

    var body: some View {
        GeometryReader { geometry in
            let menuWidth = geometry.size.width * 0.5
            
            ZStack(alignment: .leading) {
                // 1. 메인 컨텐츠
                mainContentView(openMenu: {
                    withAnimation(.spring()) {
                        isMenuOpen = true
                    }
                })
                .environmentObject(scheduleViewModel)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: isMenuOpen ? menuWidth : 0)
                .disabled(isMenuOpen)
                
                // 2. 오버레이 (어두운 배경)
                if isMenuOpen {
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isMenuOpen = false
                            }
                        }
                        .offset(x: isMenuOpen ? menuWidth : 0)
                }
                
                // 3. 사이드 메뉴
                MenuView(
                    selectedTab: $selectedTab,
                    closeMenu: {
                        withAnimation(.spring()) {
                            isMenuOpen = false
                        }
                    }
                )
                .frame(width: menuWidth)
                .offset(x: isMenuOpen ? 0 : -menuWidth)
                .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /// 현재 선택된 탭에 따라 화면을 전환
    @ViewBuilder
    func mainContentView(openMenu: @escaping () -> Void) -> some View {
        switch selectedTab {
        case .home:
            HomeView(openMenu: openMenu)
        case .schedule:
            ScheduleView(openMenu: openMenu)
        case .settings:
            SettingsView(openMenu: openMenu)
        }
    }
}

/// 탭 구분용 Enum
enum Tab {
    case home
    case schedule
    case settings
}

#Preview {
    ContentView()
        .environmentObject(ScheduleViewModel())
}
