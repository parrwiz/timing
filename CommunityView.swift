import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    @State private var posts: [CommunityPost] = []
    @State private var showingNewPost = false
    private var firestoreService = FirestoreService()

    var body: some View {
        if Auth.auth().currentUser == nil {
            SignInView() // Show Sign-in screen if user is not logged in
        } else {
            NavigationView {
                List {
                    ForEach(posts) { post in
                        CommunityPostRow(post: post)
                    }
                }
                .navigationTitle("Community")
                .navigationBarItems(
                    leading: Button("Sign Out", action: signOut),
                    trailing: Button(action: { showingNewPost.toggle() }) {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $showingNewPost) {
                    NewQuestionView { newPost in
                        firestoreService.savePost(post: newPost)
                        posts.append(newPost)
                        showingNewPost = false
                    }
                }
                .onAppear {
                    firestoreService.fetchPosts { fetchedPosts in
                        self.posts = fetchedPosts
                    }
                }
            }
        }
    }

    private func signOut() {
        AuthService.shared.signOut { success, error in
            if success {
                print("User signed out")
            } else {
                print("Error signing out: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
