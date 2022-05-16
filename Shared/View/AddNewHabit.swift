//
//  AddNewHabit.swift
//  HabitTracker (iOS)
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI

struct AddNewHabit: View {
    
    @EnvironmentObject var habitModel: HabitViewModel
    
    let weekDays: [String] = {
        var calendar = Calendar.current //Calendar(identifier: .gregorian)
        calendar.locale = .init(identifier: "ru")
        var weekdays = calendar.shortWeekdaySymbols
        weekdays.append(weekdays.removeFirst())
        return weekdays
    }()

    @Environment(\.self) var env
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                TextField("Заголовок", text: $habitModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .fieldBackground()
                
                // MARK: Habit Color Picker
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { index in
                        let color = "Card-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay {
                                if color == habitModel.habitColor {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    habitModel.habitColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                // MARK: Frequency Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Повторение")
                        .font(.callout.bold())
                                        
                    HStack(spacing: 10) {
                        ForEach(weekDays, id: \.self) { day in
                            let index = habitModel.weekDays.firstIndex { value in
                                value == day
                            } ?? -1
                            // MARK: Limiting to first 2 letters
                            Text(day)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(habitModel.habitColor) : Color("TFBG").opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation {
                                        if index != -1 {
                                            habitModel.weekDays.remove(at: index)
                                        } else {
                                            habitModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, 15)
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                // Hiding If Notification Access is Rejected
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Напоминание")
                            .fontWeight(.semibold)
                        
                        Text("Просто уведомление")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $habitModel.isRemainderOn) {}
                        .labelsHidden()
                }
                .opacity(habitModel.notificationAccess ? 1 : 0)
                
                HStack(spacing: 12) {
                    Label {
                        Text(habitModel.remainderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .fieldBackground()
                    .onTapGesture {
                        withAnimation {
                            habitModel.showTimePicker.toggle()
                        }
                    }

                    TextField("Текст напоминания", text: $habitModel.remainderText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .fieldBackground()
                }
                .frame(height: habitModel.isRemainderOn ? nil : 0)
                .opacity(habitModel.isRemainderOn ? 1 : 0)
                .opacity(habitModel.notificationAccess ? 1 : 0)
            }
            .animation(.easeInOut, value: habitModel.isRemainderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(habitModel.editHabit != nil ? "Редактирование" : "Новая привычка")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                }

                // MARK: Delete Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if habitModel.deleteHabit(context: env.managedObjectContext) {
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .opacity(habitModel.editHabit == nil ? 0 : 1)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        Task {
                            if await habitModel.addHabit(context: env.managedObjectContext) {
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.white)
                    .disabled(!habitModel.doneStatus())
//                    .opacity(habitModel.doneStatus() ? 1 : 1)
                }
            }
        }
        .overlay {
            if habitModel.showTimePicker {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                habitModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker.init("",
                                    selection: $habitModel.remainderDate,
                                    displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("TFBG"))
                    }
                    .padding()
                }
            }
        }
    }
}

struct FieldBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

extension View {
    func fieldBackground() -> some View {
        modifier(FieldBackground())
    }
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
