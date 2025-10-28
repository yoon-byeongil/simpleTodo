import SwiftUI

struct ScheduleView: View {
    var openMenu: () -> Void
    @EnvironmentObject var viewModel: ScheduleViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items) { item in
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
}

#Preview {
    ScheduleView(openMenu: {})
        .environmentObject(ScheduleViewModel())
}
