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
        VStack {
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
            
            // Установка кнопки добавления посередине, если привычек ещё нет
            ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    // MARK: Add Habiit Button
                    Button {
                        
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
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
