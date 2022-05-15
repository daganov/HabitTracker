//
//  Home.swift
//  HabitTracker (iOS)
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI

struct Home: View {
    
    @FetchRequest(entity: Habit.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)],
                  predicate: nil, animation: .easeInOut) var habits: FetchedResults<Habit>
    
    @StateObject var habitModel = HabitViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Привычки")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button {
                        habitModel.addNewHabit.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 10)
            
            // Установка кнопки добавления посередине, если привычек ещё нет
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    ForEach(habits) { habit in
                        HabitCardView(habit: habit)
                    }
                    
                    // MARK: Add Habit Button
                    Button {
                        habitModel.addNewHabit.toggle()
                    } label: {
                        Label {
                            Text("Новая привычка")
                        } icon: {
                            Image(systemName: "plus.circle")
                        }
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    }
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .padding(.vertical)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: $habitModel.addNewHabit) {
            // MARK: Erasing All Existing Content
            habitModel.resetData()
        } content: {
            AddNewHabit()
                .environmentObject(habitModel)
        }
    }
    
    // MARK: Habit Card View
    @ViewBuilder
    func HabitCardView(habit: Habit) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(habit.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Image(systemName: "bell.badge.fill")
                    .font(.callout)
                    .foregroundColor(Color(habit.color ?? "Card-1"))
                    .scaleEffect(0.9)
                    .opacity(habit.isRemainderOn ? 1 : 0)
                
                Spacer ()
                
                let count = (habit.weekDays?.count ?? 0)
                Text(count == 7 ? "Ежедневно" : "\(count) в неделю")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            
            // MARK: Displaying Current Week and Marking Active Dates of Habit
            let calendar: Calendar = {
                var cal = Calendar.current
                cal.locale = Locale(identifier: "ru")
                return cal
            }()
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.shortWeekdaySymbols
            let startDate = currentWeek?.start ?? Date()
            let activeWeekDays = habit.weekDays ?? []
            let activePlot = symbols.indices.compactMap { index -> (String, Date) in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                return (symbols[index], currentDate!)
            }
            
            HStack(spacing: 0) {
                ForEach(activePlot.indices, id: \.self) { index in
                    let item = activePlot[index]
                    
                    VStack(spacing: 6) {
                        Text(item.0)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        let status = activeWeekDays.contains { $0 == item.0 }
                        
                        Text(getDate(date: item.1))
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(Color(habit.color ?? "Card-1"))
                                    .opacity(status ? 1 : 0)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 15)
        }
        .padding(.vertical)
        .padding(.horizontal, 6)
        .fieldBackground()
        .onTapGesture {
            // MARK: Editing Habit
            habitModel.editHabit = habit
            habitModel.restoreEditData()
            habitModel.addNewHabit.toggle()
        }
    }
    
    // MARK: Formatting Date
    func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        return formatter.string(from: date)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
