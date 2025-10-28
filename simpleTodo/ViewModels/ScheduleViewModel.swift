import Foundation
import SwiftUI
import UserNotifications

/// ✅ ViewModel: 일정 로직 + 알람 관리
@MainActor
final class ScheduleViewModel: ObservableObject {
    
    @Published var items: [ScheduleItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let saveKey = "schedule_items"
    
    init() {
        loadItems()
        requestNotificationPermission()
    }
    
    // MARK: - 일정 추가
    func addItem(title: String, alarmDate: Date?) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let newItem = ScheduleItem(title: trimmed, alarmDate: alarmDate)
        items.insert(newItem, at: 0)
        
        // 알람 설정
        if let alarmDate = alarmDate {
            scheduleNotification(for: newItem, at: alarmDate)
        }
    }
    
    // MARK: - 완료 토글
    func toggleCompletion(item: ScheduleItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    // MARK: - 일정 삭제
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            cancelNotification(for: items[index])
        }
        items.remove(atOffsets: offsets)
    }
    
    // MARK: - 알림 권한 요청
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("🔴 알림 권한 오류:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - 알림 예약
    private func scheduleNotification(for item: ScheduleItem, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "일정 알림"
        content.body = item.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 알림 취소
    private func cancelNotification(for item: ScheduleItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
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
