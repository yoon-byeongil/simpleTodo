//
//  ContentView.swift
//  simpleTodo
//
//  Created by 윤병일 on 2025/10/28.
//

import SwiftUI

// MARK: - 1. 메인 컨텐츠 뷰 (전체 앱 구조)

struct ContentView: View {
    // 현재 선택된 탭을 관리하는 상태 변수
    @State private var selectedTab: Tab = .home
    // 메뉴가 열려있는지 관리하는 상태 변수
    @State private var isMenuOpen = false

    var body: some View {
        GeometryReader { geometry in
            // 메뉴 너비를 화면 너비의 70%로 설정
            let menuWidth = geometry.size.width * 0.5
            
            ZStack(alignment: .leading) {
                
                // 1. 메인 컨텐츠 (홈, 일정, 설정)
                // selectedTab 값에 따라 표시할 뷰를 전환합니다.
                mainContentView(openMenu: {
                    // "메뉴 열기" 버튼이 눌렸을 때 애니메이션과 함께 isMenuOpen을 true로 변경
                    withAnimation(.spring()) {
                        isMenuOpen = true
                    }
                })
                .frame(width: geometry.size.width, height: geometry.size.height)
                // 메뉴가 열려있으면 메인 컨텐츠를 오른쪽으로 민다
                .offset(x: isMenuOpen ? menuWidth : 0)
                // 메뉴가 열려있으면 메인 컨텐츠의 조작을 막는다
                .disabled(isMenuOpen)

                // 2. 메뉴가 열렸을 때 컨텐츠를 덮는 어두운 오버레이
                if isMenuOpen {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        // 오버레이를 탭하면 메뉴가 닫힘
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isMenuOpen = false
                            }
                        }
                        // 메인 컨텐츠와 동일하게 이동
                        .offset(x: isMenuOpen ? menuWidth : 0)
                }
                
                // 3. 사이드 메뉴 뷰
                MenuView(
                    selectedTab: $selectedTab,
                    closeMenu: {
                        // "닫기" 버튼이나 메뉴 아이템이 눌렸을 때 메뉴를 닫음
                        withAnimation(.spring()) {
                            isMenuOpen = false
                        }
                    }
                )
                .frame(width: menuWidth)
                // 메뉴가 닫혀있으면 화면 왼쪽 밖으로 민다
                .offset(x: isMenuOpen ? 0 : -menuWidth)
                // 이 뷰가 다른 뷰들보다 항상 위에 있도록 zIndex 설정
                .zIndex(1)
            }
        }
        // 하단 safe area는 무시 (홈 화면 등에서 전체 화면을 사용하기 위함)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /// `selectedTab` 상태에 따라 올바른 뷰를 반환하는 헬퍼 함수
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

// MARK: - 2. 각 화면별 뷰 정의

/// "홈" 화면 (home.png)
struct HomeView: View {
    var openMenu: () -> Void
    @State private var newScheduleItem = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer() // 컨텐츠를 중앙으로 밀기 위한 Spacer
                
                HStack {
                    // "새로운 일정 추가" 텍스트 필드
                    TextField("새로운 일정 추가", text: $newScheduleItem)
                        .padding(12)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        
                    // "+" 버튼
                    Button(action: {
                        // TODO: 일정 추가 로직
                        print("일정 추가: \(newScheduleItem)")
                        newScheduleItem = "" // 입력창 초기화
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .padding(15)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer() // 컨텐츠를 중앙으로 밀기 위한 Spacer
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 네비게이션 바 왼쪽의 햄버거 메뉴 버튼
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

/// "일정" 화면 (schedule.png)
struct ScheduleView: View {
    var openMenu: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                // "내 일정" 부제목
                Text("내 일정")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .top])
                
                Spacer()
                
                // "아직 일정이 없습니다" 텍스트
                Text("아직 일정이 없습니다")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("일정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

/// "설정" 화면 (settings.png)
struct SettingsView: View {
    var openMenu: () -> Void
    
    // 각 토글의 상태를 관리
    @State private var allowNotifications = false
    @State private var isDarkMode = false
    @State private var autoDelete = false

    var body: some View {
        NavigationStack {
            // 설정 화면은 Form을 사용하는 것이 가장 적합
            Form {
                Section(header: Text("설정")) {
                    Toggle("알림", isOn: $allowNotifications)
                    Toggle("다크 모드", isOn: $isDarkMode)
                    Toggle("완료된 항목 자동 삭제", isOn: $autoDelete)
                }
                
                Section {
                    // "버전 1.0.0" 텍스트
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
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - 3. 사이드 메뉴 뷰 정의 (menu.png)

/// 사이드 메뉴 뷰
struct MenuView: View {
    // ContentView의 selectedTab을 변경하기 위해 @Binding 사용
    @Binding var selectedTab: Tab
    var closeMenu: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "X" 닫기 버튼
            HStack {
                Spacer()
                Button(action: closeMenu) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 50) // 상단 상태바 영역 확보

            // 메뉴 아이템들
            MenuItem(
                icon: "house.fill",
                title: "홈",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home // 탭 변경
                closeMenu() // 메뉴 닫기
            }
            
            MenuItem(
                icon: "calendar",
                title: "일정",
                isSelected: selectedTab == .schedule
            ) {
                selectedTab = .schedule
                closeMenu()
            }
            
            MenuItem(
                icon: "gearshape.fill",
                title: "설정",
                isSelected: selectedTab == .settings
            ) {
                selectedTab = .settings
                closeMenu()
            }
            
            Spacer()
        }
        // 메뉴 배경색 (다크모드 대응을 위해 systemBackground 사용)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

/// 메뉴 아이템을 위한 재사용 가능한 뷰
struct MenuItem: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            // 선택된 항목은 파란색 배경과 텍스트 색상 적용
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(10)
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - 4. 탭 관리를 위한 Enum

/// 탭을 명확하게 관리하기 위한 열거형(Enum)
enum Tab {
    case home
    case schedule
    case settings
}

// MARK: - 5. 미리보기 (Xcode 캔버스용)

#Preview {
    ContentView()
}
