import Foundation
import SwiftUI
import UserNotifications

/// ✅ ViewModel: 앱의 모든 비즈니스 로직 + 상태 관리
@MainActor
final class ScheduleViewModel: ObservableObject {
    
    // MARK: - Published 상태들 (View와 바인딩)
    @Published var items: [ScheduleItem] = [] {
        didSet { saveItems() }
    }
    
    @Published var allowNotifications: Bool = false        // 알림 허용 여부
    @Published var isDarkMode: Bool = false {              // 다크모드 상태
        didSet { applyDarkMode() }
    }
    @Published var autoDeleteCompleted: Bool = false {     // 완료 항목 자동 삭제
        didSet {
            if autoDeleteCompleted {
                removeCompletedItems()
            }
        }
    }
    
    // MARK: - UserDefaults 키
    private let saveKey = "schedule_items"
    
    // MARK: - 초기화
    init() {
        loadItems()
        requestNotificationPermission()
        refreshNotificationStatus()
        applyDarkMode() // 앱 실행 시 현재 모드 적용
    }
    
    // MARK: - 일정 추가
    func addItem(title: String, alarmDate: Date?) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let newItem = ScheduleItem(title: trimmed, alarmDate: alarmDate)
        items.insert(newItem, at: 0)
        
        // 알람 예약
        if let alarmDate = alarmDate {
            scheduleNotification(for: newItem, at: alarmDate)
        }
    }
    
    // MARK: - 일정 완료 토글
    func toggleCompletion(item: ScheduleItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            if autoDeleteCompleted {
                removeCompletedItems()
            }
        }
    }
    
    // MARK: - 일정 삭제
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            cancelNotification(for: items[index])
        }
        items.remove(atOffsets: offsets)
    }
    
    // MARK: - 완료 항목 자동 삭제
    func removeCompletedItems() {
        items.removeAll { $0.isCompleted }
    }
    
    // MARK: - 알림 권한 요청
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                self.allowNotifications = success
            }
            if let error = error {
                print("🔴 알림 권한 오류:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - 알림 권한 상태 확인
    func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.allowNotifications = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - 알림 권한 토글 (설정 뷰에서 사용)
    func toggleNotificationPermission() {
        if allowNotifications {
            requestNotificationPermission()
        } else {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    // MARK: - 알림 예약
    private func scheduleNotification(for item: ScheduleItem, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "일정 알림"
        content.body = item.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 알림 취소
    private func cancelNotification(for item: ScheduleItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [item.id.uuidString]
        )
    }
    
    // MARK: - 다크모드 적용 (전체 View에 반영)
    private func applyDarkMode() {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows.first?
                .overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
        }
    }
    
    // MARK: - UserDefaults 저장 / 불러오기
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([ScheduleItem].self, from: data)
        else { return }
        self.items = decoded
    }
}
