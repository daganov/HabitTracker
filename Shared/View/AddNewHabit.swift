//
//  AddNewHabit.swift
//  HabitTracker (iOS)
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI

struct AddNewHabit: View {
    
    @EnvironmentObject var habitModel: HabitViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                TextField("Заголовок", text: $habitModel.title)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                
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
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Новая привычка")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .tint(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        
                    }
                    .tint(.white)
                }
            }
        }
    }
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit()
            .environmentObject(HabitViewModel())
            .preferredColorScheme(.dark)
    }
}
