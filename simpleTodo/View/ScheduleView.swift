import SwiftUI

struct ScheduleView: View {
    var openMenu: () -> Void
    @EnvironmentObject var viewModel: ScheduleViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .onTapGesture {
                                    viewModel.toggleCompletion(item: item)
                                }
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .foregroundColor(item.isCompleted ? .gray : .primary)
                        }
                        // 알람 시간 표시
                        if let alarm = item.alarmDate {
                            Text("🔔 " + formattedDate(alarm))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 30)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteItem)
            }
            .navigationTitle("일정")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    /// 날짜 포맷 함수
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduleView(openMenu: {})
        .environmentObject(ScheduleViewModel())
}
