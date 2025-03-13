import SwiftUI

struct QiblaCardView: View {
    @Binding var showQiblaView: Bool
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            showQiblaView = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Qibla Direction")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Find the direction to Mecca")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "location.north.line")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(red: 220/255, green: 78/255, blue: 65/255))
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isAnimating = true
        }
    }
}
