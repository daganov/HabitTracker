//
//  HabitViewModel.swift
//  HabitTracker (iOS)
//
//  Created by Denis Aganov on 15.05.2022.
//

import SwiftUI
import CoreData
import UserNotifications

class HabitViewModel: ObservableObject {

    // MARK: New Habbit Properties
    @Published var addNewHabit: Bool        = false
    
    @Published var title: String            = ""
    @Published var habitColor: String       = "Card-1"
    @Published var weekDays: [String]       = []
    @Published var isRemainderOn: Bool      = false
    @Published var remainderText: String    = ""
    @Published var remainderDate: Date      = Date()
    
    // MARK: Remainder Time Picker
    @Published var showTimePicker: Bool     = false
    
    // MARK: Adding Habit to Database
    func addHabit(context: NSManagedObjectContext) async -> Bool {
        let habit = Habit(context: context)
        habit.title = title
        habit.color = habitColor
        habit.weekDays = weekDays
        habit.isRemainderOn = isRemainderOn
        habit.remainderText = remainderText
        habit.notificationDate = remainderDate
        habit.notificationIDs = []
        
        if isRemainderOn {
            // MARK: Scheduling Notifications
            if let ids = try? await scheduleNotification() {
                habit.notificationIDs = ids
                if let _ = try? context.save() {
                    return true
                }
            }
        } else {
            // MARK: Adding Data
            if let _ = try? context.save() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Adding Notifications
    func scheduleNotification() async throws -> [String] {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о привычке"
        content.sound = UNNotificationSound.default
        
        // Scheduled IDs
        var notificationIDs: [String] = []
        var calendar = Calendar.current //Calendar(identifier: .gregorian)
        calendar.locale = .init(identifier: "ru")
        let weekdaySymbols: [String] = calendar.shortWeekdaySymbols
        // MARK: Scheduling Notification
        for weekDay in weekDays {
            // Unique ID for each notification
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: remainderDate)
            let min = calendar.component(.minute, from: remainderDate)
            let day = weekdaySymbols.firstIndex { $0 == weekDay } ?? -1
            
            // MARK: Since Week Day Starts from 1-7
            // Thus Adding +1 to Index
            if day != -1 {
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                // MARK: Thus will Trigger Notification on Each Selected Day
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // MARK: Notification Request
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                try await UNUserNotificationCenter.current().add(request)
                
                // Adding ID
                notificationIDs.append(id)
            }
            
        }
        
        return notificationIDs
    }
    
    // MARK: Erasing Data
    func resetData() {
        title           = ""
        habitColor      = "Card-1"
        weekDays        = []
        isRemainderOn   = false
        remainderText   = ""
        remainderDate   = Date()

    }
    
    // MARK: Done Button Status
    func doneStatus() -> Bool {
        let remainderStatus = isRemainderOn ? remainderText == "" : false
        
        return !(title == "" || weekDays.isEmpty || remainderStatus)
    }
}
