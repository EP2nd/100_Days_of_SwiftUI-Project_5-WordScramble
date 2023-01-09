//
//  ContentView.swift
//  WordScramble
//
//  Created by Edwin Przeźwiecki Jr. on 30/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    /// Challenge 3:
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.inline)
            /// Challenge 2 and 3:
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restart", action: startGame)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Score: \(score)")
                        .foregroundColor(.red)
                        .bold()
                }
            }
            /// Other great option for showing score in SwiftUI:
            /* .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .font(.title)
            } */
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func startGame() {
        /// 1. Find the URL for start.txt in our app bundle:
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            /// 2. Load start.txt into a string:
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                /// 3. Split the string up into an array of strings, splitting on line breaks:
                let allWords = startWords.components(separatedBy: "\n")
                
                /// 4. Pick one random word, or use "silkworm" as a sensible default:
                rootWord = allWords.randomElement() ?? "silkworm"
                
                /// Challenge 2:
                usedWords.removeAll()
                newWord = ""
                /// Challenge 3:
                score = 0
                
                /// If we are here, everything has worked, so we can exit:
                return
            }
        }
        /// If we are *here*, then there was a problem - trigger a crash and report the error:
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addNewWord() {
        /// Lowercase and trim the word, to make sure we don't add duplicate words with case differences:
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        /// Exist if the remaining string is empty:
        /// Challenge 1:
        guard answer.count >= 3 else {
            wordError(title: "I see what you did here!", message: "Your word is too short or is the same as our root word. Try harder!")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Nice try!", message: "Your word is the same as our root word. Easy points are not allowed!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already!", message: "Be more original.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible!", message: "You can't spell that word from '\(rootWord)'.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized!", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            /// Challenge 3:
            scoreFor(newWord.count)
        }
        newWord = ""
    }
    
    /// Challenge 3:
    func scoreFor(_ newWord: Int) {
        switch newWord {
        case rootWord.count:
            score += 20
        case rootWord.count - 1:
            score += 10
        case 4 ..< rootWord.count:
            score += 5
        default:
            score += 3
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
