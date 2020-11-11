//
//  ContentView.swift
//  Muitiple-NetworkRewuests-Combine
//
//  Created by Eugene Berezin on 11/11/20.
//
import Combine
import SwiftUI

struct Message: Decodable, Identifiable {
    let id: Int
    let from: String
    let message: String
}

struct ContentView: View {
    @State private var requests = Set<AnyCancellable>()
    @State private var messages = [Message]()
    @State private var favorites = Set<Int>()
    
    var body: some View {
        NavigationView {
            List(messages) { message in
                HStack {
                    VStack(alignment: .leading) {
                        Text(message.from)
                            .font(.headline)
                        Text(message.message)
                            .foregroundColor(.secondary)
                    }
                    
                    if favorites.contains(message.id) {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        
                    }
                }
                
            }
            .navigationTitle("Messages")
        }
        .onAppear {
            let messagesURL = URL(string: "https://www.hackingwithswift.com/samples/user-messages.json")!
            let favoritesURL = URL(string: "https://www.hackingwithswift.com/samples/user-favorites.json")!
            let messageTask = fetch(messagesURL, defaultValue: [Message]())
            let favoritesTask = fetch(favoritesURL, defaultValue: Set<Int>())
            
            let combined = Publishers.Zip(messageTask, favoritesTask)
            
            combined.sink { loadedMessages, loadedFavorites in
                messages = loadedMessages
                favorites = loadedFavorites
            }
            .store(in: &requests)
            
            
            
        }
    }
    
    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
        let decoder = JSONDecoder()
        URLSession.shared.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }
    
    func fetch<T: Decodable>(_ url: URL, defaultValue: T) -> AnyPublisher<T, Never> {
        let decoder = JSONDecoder()
        return URLSession.shared.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
