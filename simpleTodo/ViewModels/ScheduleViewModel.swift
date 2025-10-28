import Foundation
import SwiftUI

/// ✅ ViewModel : 일정 데이터의 상태와 로직을 담당
/// ObservableObject → SwiftUI에서 상태 변화 감지 가능
@MainActor
final class ScheduleViewModel: ObservableObject {
    
    // 현재 일정 목록
    @Published var items: [ScheduleItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    // UserDefaults 저장 키
    private let saveKey = "schedule_items"
    
    // 초기화 시 저장된 일정 불러오기
    init() {
        loadItems()
    }
    
    // MARK: - 일정 추가
    func addItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let newItem = ScheduleItem(title: trimmed)
        items.insert(newItem, at: 0)
    }
    
    // MARK: - 완료 상태 토글
    func toggleCompletion(item: ScheduleItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    // MARK: - 일정 삭제
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    // MARK: - UserDefaults 저장
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // MARK: - UserDefaults 불러오기
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([ScheduleItem].self, from: data)
        else { return }
        
        self.items = decoded
    }
}

