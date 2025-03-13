import SwiftUI

struct NewQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var author: String = ""
    @State private var content: String = ""
    @State private var isLoading = false
    private let geminiService = GeminiService()

    var onPost: (CommunityPost) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Your Name")) {
                    TextField("Your name", text: $author)
                        .autocapitalization(.words)
                }
                Section(header: Text("Ask a Question")) {
                    TextField("What's your question?", text: $content)
                        .autocapitalization(.sentences)
                }
                Section {
                    if isLoading {
                        ProgressView("Generating response…")
                    } else {
                        Button("Submit Question") {
                            if content.contains("@arkan") {
                                isLoading = true
                                let userQuestion = content.replacingOccurrences(of: "@arkan", with: "").trimmingCharacters(in: .whitespaces)

                                geminiService.askGemini(question: userQuestion) { response in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        let aiResponse = response ?? "Sorry, I couldn't generate a response."
                                        let newPost = CommunityPost(author: author, content: content, timestamp: Date(), replies: [aiResponse])
                                        onPost(newPost)

                                        // Print in console
                                        print("Arkan AI Response: \(aiResponse)")
                                    }
                                }
                            } else {
                                let newPost = CommunityPost(author: author, content: content, timestamp: Date())
                                onPost(newPost)
                            }
                        }
                        .disabled(author.isEmpty || content.isEmpty)
                    }
                }
            }
            .navigationTitle("Ask a Question")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
