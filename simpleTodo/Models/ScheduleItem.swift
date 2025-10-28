import Foundation

/// ✅ 일정 데이터를 나타내는 모델 구조체
/// Identifiable → List에서 식별 가능
/// Codable → UserDefaults 저장 가능
struct ScheduleItem: Identifiable, Codable {
    let id: UUID           // 각 일정의 고유 ID
    var title: String      // 일정 제목
    var isCompleted: Bool  // 완료 여부
    var createdAt: Date    // 생성 시각
    var alarmDate: Date?   // 알람 시간 (없으면 nil)
    
    init(title: String, alarmDate: Date? = nil, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.alarmDate = alarmDate
    }
}
