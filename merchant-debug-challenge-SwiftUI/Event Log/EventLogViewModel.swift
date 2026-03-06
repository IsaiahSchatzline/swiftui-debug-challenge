//
//  EventLogViewModel.swift
//  MockCardSwitcher
//
//  Created by Isaiah Schatzline on 3/5/26.
//

import SwiftUI
import Combine

final class EventLogViewModel: ObservableObject {
    @Published private(set) var entries: [LogEntry] = []

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    func onAppear() {
        reloadEntries()
    }

    func reloadEntries() {
        entries = LogStore.shared.allEntries().reversed()
    }

    func clearTapped() {
        LogStore.shared.clear()
    }

    func timeString(_ date: Date) -> String {
        formatter.string(from: date)
    }
}
