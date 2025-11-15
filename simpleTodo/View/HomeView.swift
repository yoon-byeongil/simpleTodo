import SwiftUI

struct HomeView: View {
    var openMenu: () -> Void
    @EnvironmentObject var viewModel: ScheduleViewModel
    @State private var newScheduleItem = ""
    @State private var showDatePicker = false   // 알람 선택 창 표시 여부
    @State private var selectedDate = Date()    // 사용자가 고른 알람 날짜/시간
    @State private var alarmEnabled = true      // 알람 설정 여부
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // 일정 추가 입력창
                HStack {
                    TextField("새로운 일정 추가", text: $newScheduleItem)
                        .padding(12)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        showDatePicker = true
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
                
                // 일정 리스트 (최근 1개)
                if viewModel.items.isEmpty {
                    Text("아직 일정이 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    List {
                        Text("가장 최근에 추가한 일정")
                        ForEach(viewModel.items.prefix(1)) { item in
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
                                // 알람 시간이 있다면 회색으로 표시
                                if let alarm = item.alarmDate {
                                    Text("🔔 " + formattedDate(alarm))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 30)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle("홈")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            // ✅ 알람 설정 Sheet (처음부터 꽉 차도록)
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    VStack(spacing: 20) {
                        // 일정 제목 입력
                        TextField("일정 제목을 입력하세요", text: $newScheduleItem)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top, 30)
                            .padding(.horizontal)
                        
                        // 알람 여부 토글
                        Toggle("알람 사용", isOn: $alarmEnabled)
                            .padding(.horizontal)
                        
                        // 날짜/시간 선택 (알람이 켜진 경우에만 표시)
                        if alarmEnabled {
                            DatePicker("날짜 및 시간 선택", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .padding()
                        }
                        
                        Spacer()
                        
                        // 확인 버튼
                        Button("확인") {
                            let alarmDate = alarmEnabled ? selectedDate : nil
                            viewModel.addItem(title: newScheduleItem, alarmDate: alarmDate)
                            newScheduleItem = ""
                            showDatePicker = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.bottom, 40)
                    }
                    .navigationTitle("알람 설정")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                showDatePicker = false
                            }
                        }
                    }
                    // ✅ 시트를 처음부터 화면 전체로 표시
                    .presentationDetents([.large])
                }
            }
        }
    }
    
    /// 날짜 포맷
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView(openMenu: {})
        .environmentObject(ScheduleViewModel())
}
