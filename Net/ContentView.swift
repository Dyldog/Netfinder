//
//  ContentView.swift
//  Net
//
//  Created by Dylan Elliott on 19/1/2023.
//

import SwiftUI

class ContentViewModel: NSObject, ObservableObject {
    
    @Published var speed: String = ""
    @Published var date: String = "Not tested"
    @Published var errorMessage: String?
    var color: Color {
        colors[abs(date.hashValue) % colors.count]
    }
    
    private let speedTester: SpeedTester = .init()
    
    private let speedFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hhmmssSSS"
        return formatter
    }()
    
    private var colors: [Color] = [
        .blue,
        .green,
        .red,
        .purple,
        .pink,
        .yellow,
        .orange
    ]
    
    override init() {
        super.init()
        
        if UIApplication.isUITest {
            setDummyData()
        } else {
            testSpeed()
        }
    }
    
    private func setDummyData() {
        speed = "69.9"
        self.date = self.dateFormatter.string(from: .now)
    }
    
    private func testSpeed() {
        speedTester.testDownloadSpeed(timeout: 10) { megabytesPerSecond, error in
            DispatchQueue.main.async {
                self.date = self.dateFormatter.string(from: .now)
                
                if let megabytesPerSecond = megabytesPerSecond,
                   let speedText = self.speedFormatter.string(from: megabytesPerSecond as NSNumber) {
                    self.speed = "\(speedText)"
                } else {
                    self.speed = ""
                }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
                
                self.testSpeed()
            }
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel = .init()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(viewModel.speed)
                .font(.system(size: 140, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding()
        .background(viewModel.color)
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
