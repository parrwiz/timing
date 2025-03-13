import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    private let db = Firestore.firestore()
    
    func savePost(post: CommunityPost) {
        let postRef = db.collection("communityPosts").document(post.id)
        let postData: [String: Any] = [
            "author": post.author,
            "content": post.content,
            "timestamp": post.timestamp.timeIntervalSince1970
        ]
        postRef.setData(postData) { error in
            if let error = error {
                print("Error saving post: \(error)")
            } else {
                print("Post saved successfully")
            }
        }
    }

    func saveReply(to postId: String, reply: CommunityPost) {
        let replyRef = db.collection("communityPosts").document(postId).collection("replies").document()
        let replyData: [String: Any] = [
            "author": reply.author,
            "content": reply.content,
            "timestamp": reply.timestamp.timeIntervalSince1970
        ]
        replyRef.setData(replyData) { error in
            if let error = error {
                print("Error saving reply: \(error)")
            } else {
                print("Reply saved successfully")
            }
        }
    }

    func fetchPosts(completion: @escaping ([CommunityPost]) -> Void) {
        db.collection("communityPosts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching posts: \(String(describing: error))")
                completion([])
                return
            }

            let posts = documents.compactMap { doc -> CommunityPost? in
                let data = doc.data()
                guard let author = data["author"] as? String,
                      let content = data["content"] as? String,
                      let timestamp = data["timestamp"] as? Double else { return nil }
                return CommunityPost(id: doc.documentID, author: author, content: content, timestamp: Date(timeIntervalSince1970: timestamp))
            }
            completion(posts)
        }
    }
}
