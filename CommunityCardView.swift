import SwiftUI

struct CommunityCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community")
                .font(.headline)
                .foregroundColor(.black)
            
            NavigationLink(destination: CommunityView()) {
                HStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 30)
                        .foregroundColor(Color(red: 220/255, green: 78/255, blue: 65/255))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Join the Discussion")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Connect with other Muslims")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding()
                .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
