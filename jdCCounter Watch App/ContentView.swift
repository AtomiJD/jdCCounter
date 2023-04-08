//
//  ContentView.swift
//  jdCCounter Watch App
//
//  Created by Achim Christ on 08.04.23.
//

import SwiftUI
import Combine

struct LogEntry: Identifiable, Codable {
    var id = UUID()
    let timestamp: Date
}

class CounterViewModel: ObservableObject {
    @Published var log: [LogEntry] = [] {
        didSet {
            saveLog()
        }
    }
    @Published var sum: Int = 0

    private let logKey = "logKey"

    init() {
        loadLog()
    }

    func addLogEntry() {
        let entry = LogEntry(timestamp: Date())
        log.append(entry)
        sum += 1
    }
    
    func reset() {
        sum = 0
    }

    private func saveLog() {
        if let encodedLog = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(encodedLog, forKey: logKey)
        }
    }

    private func loadLog() {
        if let savedLogData = UserDefaults.standard.data(forKey: logKey),
           let decodedLog = try? JSONDecoder().decode([LogEntry].self, from: savedLogData) {
            log = decodedLog
            sum = log.count
        }
    }
}

struct ContentView: View {
    @StateObject var counterViewModel = CounterViewModel()

    var body: some View {
        VStack {
            HStack {
                 Button(action: {
                     counterViewModel.addLogEntry()
                 }) {
                     Image("Carrot")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 60, height: 60)
                         .background(Color.white)
                         .clipShape(RoundedRectangle(cornerRadius: 15))
                         .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.black, lineWidth: 1))
                 }
                 .buttonStyle(PlainButtonStyle())

                 Button(action: {
                     counterViewModel.reset()
                 }) {
                     Text("Reset")
                         .fontWeight(.bold)
                         .foregroundColor(Color.white)
                         .padding(.horizontal, 12)
                         .padding(.vertical, 8)
                         .background(Color.red)
                         .cornerRadius(8)
                 }
             }
            
            Text("Möhren: \(counterViewModel.sum)")
                .font(.headline)
            
            List {
                ForEach(counterViewModel.log) { entry in
                    HStack {
                        Text("Möhre:")
                            .font(.footnote)
                        Spacer()
                        Text("\(entry.timestamp, formatter: DateFormatter.timestampFormatter)")
                            .font(.footnote)
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
