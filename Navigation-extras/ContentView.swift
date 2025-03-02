//
//  ContentView.swift
//  Navigation-extras
//
//  Created by Rishal Bazim on 01/03/25.
//

import SwiftUI

@Observable
class PathStore {
    var path: NavigationPath {
        didSet {
            save()
        }
    }
    let savedPath = URL.documentsDirectory.appending(path: "SavedPath")
    init() {
        if let data = try? Data(contentsOf: savedPath) {
            if let decoded = try? JSONDecoder().decode(
                NavigationPath.CodableRepresentation.self,
                from: data
            ) {
                path = NavigationPath(decoded)
                return
            }
        }
        path = NavigationPath()
    }

    func save() {
        guard let representation = path.codable else { return }
        do {
            let data = try JSONEncoder().encode(representation)
            try data.write(to: savedPath)
        } catch {
            print("Failed to save navigation data.")
        }
    }
}

struct DetailView: View {
    var number: Int
    @Binding var path: NavigationPath
    var body: some View {
        NavigationLink("Go to Random Number", value: Int.random(in: 1...1000))
            .navigationTitle("Number: \(number)").toolbar {
                Button {
                    path = NavigationPath()
                } label: {
                    Text("Home")
                }

            }
    }
}

struct ContentView: View {
    @State private var path = PathStore()
    var body: some View {
        NavigationStack(path: $path.path) {
            DetailView(number: 0, path: $path.path)
                .navigationDestination(for: Int.self) { i in
                    DetailView(number: i, path: $path.path)
                }
        }
    }
}

#Preview {
    ContentView()
}
