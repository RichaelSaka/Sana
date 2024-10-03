//
//  SurveyView.swift
//  Sana
//
//  Created by Alina Yu on 10/1/24.
//

// Main view for a checklist survey to calculate cancer risk

import Foundation
import SwiftUI
import Swift

struct SurveyView: View {
    @StateObject private var viewModel = SurveyViewModel()
    
    var body: some View {
        VStack(spacing: 5) { // Adjust the spacing between the title and text
            Text("Cancer Risk Survey")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 0) // Reduce padding below the title
            
            Text("Fill out this survey to calculate your environmental cancer risk")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.top, 0) // Remove any top padding
                .foregroundColor(.secondary)
        }
        .padding() // Outer padding for the whole view
        
        ScrollView {
            VStack(spacing: 20) {
                // Survey Questions
                SurveyQuestionView(question: "Do you drink?", isChecked: $viewModel.question1Answered)
                SurveyQuestionView(question: "Do you smoke?", isChecked: $viewModel.question2Answered)
                SurveyQuestionView(question: "Do you have a family history of breast cancer?", isChecked: $viewModel.question3Answered)
                
                // Calculate Button
                Button(action: {
                    viewModel.calculateRisk()
                }) {
                    Text("Calculate Cancer Risk")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.5, blue: 0.5))
                        .cornerRadius(10)
                }
                
                // Display risk result
                if viewModel.riskCalculated {
                    Text("Your cancer risk is \(viewModel.cancerRisk)%")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .background(Color(red: 1.0, green: 0.78, blue: 0.80))
    }
}

struct SurveyQuestionView: View {
    var question: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Text(question)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Toggle("", isOn: $isChecked)
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

class SurveyViewModel: ObservableObject {
    @Published var question1Answered = false
    @Published var question2Answered = false
    @Published var question3Answered = false
    @Published var riskCalculated = false
    @Published var cancerRisk: Int = 0
    
    func calculateRisk() {
        // Simple risk calculation logic based on how many questions are checked
        let answeredQuestions = [question1Answered, question2Answered, question3Answered]
        let score = answeredQuestions.filter { $0 }.count
        cancerRisk = score * 33 // Each question contributes roughly 33% to risk
        riskCalculated = true
    }
}

#Preview {
    SurveyView()
}
