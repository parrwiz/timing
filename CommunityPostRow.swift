import SwiftUI

struct CommunityPostRow: View {
    var post: CommunityPost

    var body: some View {
        VStack(alignment: .leading) {
            Text(post.author)
                .font(.headline)
            Text(post.content)
                .font(.body)
                .padding(.vertical, 2)
            
            if !post.replies.isEmpty {
                Divider()
                ForEach(post.replies, id: \.self) { reply in
                    HStack {
                        Text("🔹 \(reply)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
}
