import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.largeTitle)
            Text("云端编译练手项目")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
