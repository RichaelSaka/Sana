import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {
                Text("Welcome to Sana")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 0)
                
                Image("EAAMO")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 20)
                
                Text("Learn about your breast cancer risk, monitor your environmental risks, and take charge of your health!")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.top, 0)
                    .foregroundColor(.secondary)
                
            }
            .padding()
            
            VStack(spacing: 20) {
                // Button to navigate to Environment Dashboard
                NavigationLink(destination: EnvironmentDashboard()) {
                    Text("Go to Environment Dashboard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.5, blue: 0.5))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                // Button to navigate to Cancer Risk Survey
                NavigationLink(destination: SurveyView()) {
                    Text("Take Cancer Risk Survey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.5, blue: 0.5))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
