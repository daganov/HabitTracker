//
//  HabitViewModel.swift
//  HabitTracker (iOS)
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI
import CoreData

class HabitViewModel: ObservableObject {

    // MARK: New Habbit Properties
    @Published var addNewHabit: Bool    = false
    
    @Published var title: String        = ""
    @Published var habitColor: String   = "Card-1"
    @Published var weekDays: [String]   = []
    @Published var isReminderOn: Bool   = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date   = Date()
}