import SwiftUI

struct MenuView: View {
    @Binding var selectedTab: Tab
    var closeMenu: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 닫기 버튼
            HStack {
                Spacer()
                Button(action: closeMenu) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                }
            }
            .padding(.top, 50)
            
            // 메뉴 아이템
            MenuItem(icon: "house.fill", title: "홈", isSelected: selectedTab == .home) {
                selectedTab = .home
                closeMenu()
            }
            
            MenuItem(icon: "calendar", title: "일정", isSelected: selectedTab == .schedule) {
                selectedTab = .schedule
                closeMenu()
            }
            
            MenuItem(icon: "gearshape.fill", title: "설정", isSelected: selectedTab == .settings) {
                selectedTab = .settings
                closeMenu()
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

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
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(10)
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    @State var tab: Tab = .home
    return MenuView(selectedTab: $tab, closeMenu: {})
}
