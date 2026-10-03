import SwiftUI

struct ContentView: View {
    @State private var count: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Text("计数器")
                    .font(.largeTitle.bold())

                Text("\(count)")
                    .font(.system(size: 80, weight: .heavy))

                HStack(spacing: 24) {
                    Button {
                        count -= 1
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.red)
                    }

                    Button {
                        count += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.green)
                    }
                }

                Button("重置") {
                    count = 0
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding()
            .navigationTitle("MyApp")
        }
    }
}

#Preview {
    ContentView()
}
