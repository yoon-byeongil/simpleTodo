import SwiftUI

struct HomeView: View {
    var openMenu: () -> Void
    @EnvironmentObject var viewModel: ScheduleViewModel
    @State private var newScheduleItem = ""

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
                        viewModel.addItem(title: newScheduleItem)
                        newScheduleItem = ""
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
                
                // 최근 1개의 일정만 미리보기로 표시
                if viewModel.items.isEmpty {
                    Text("아직 일정이 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    List {
                        Text("최근 추가 일정")
                        ForEach(viewModel.items.prefix(1)) { item in
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .onTapGesture {
                                        viewModel.toggleCompletion(item: item)
                                    }
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                    .foregroundColor(item.isCompleted ? .gray : .primary)
                            }
                        }
                    }
                    .frame(height: 180)
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openMenu) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(openMenu: {})
        .environmentObject(ScheduleViewModel())
}
