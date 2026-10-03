import SwiftUI

struct ContentView: View {
    @State private var count: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("计数器")
                    .font(.largeTitle.bold())
                
                Text("\(count)")
                    .font(.system(size: 72, weight: .heavy))
                
                HStack(spacing: 20) {
                    Button(action: {
                        count -= 1
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        count += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
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
            .navigationTitle("MyAppApp")
        }
    }
}

#Preview {
    ContentView()
}
