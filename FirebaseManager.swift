//
//  FirebaseManager.swift
//  Arkan
//
//  Created by mac on 2/3/25.
//

import FirebaseDatabase

class FirebaseManager {
    private var ref: DatabaseReference

    init() {
        self.ref = Database.database().reference()
    }

    // Post a new question to Firebase
    func postQuestion(author: String, content: String, completion: @escaping (Bool) -> Void) {
        let newPostRef = ref.child("communityPosts").childByAutoId()
        newPostRef.setValue([
            "author": author,
            "content": content,
            "timestamp": ServerValue.timestamp()
        ]) { error, _ in
            if let error = error {
                print("Error posting question: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Question posted successfully")
                completion(true)
            }
        }
    }

    // Observe new community posts
    func observeCommunityPosts(completion: @escaping ([CommunityPost]) -> Void) {
        ref.child("communityPosts").observe(.value) { snapshot in
            var posts: [CommunityPost] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let postData = snapshot.value as? [String: Any],
                   let author = postData["author"] as? String,
                   let content = postData["content"] as? String,
                   let timestamp = postData["timestamp"] as? Double {
                    let post = CommunityPost(author: author, content: content, timestamp: Date())
                    posts.append(post)
                }
            }
            completion(posts)
        }
    }

    // Post the answer from Gemini
    func postAnswer(postId: String, answer: String) {
        let postRef = ref.child("communityPosts").child(postId)
        postRef.updateChildValues(["answer": answer])
    }
}
