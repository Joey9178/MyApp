import SwiftUI

struct ContentView: View {
    @State private var count: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.45), .purple.opacity(0.35), .pink.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("计数器")
                    .font(.largeTitle.bold())

                Text("\(count)")
                    .font(.system(size: 88, weight: .heavy))
                    .contentTransition(.numericText())

                HStack(spacing: 26) {
                    glassButton(system: "minus.circle.fill", color: .red) { count -= 1 }
                    glassButton(system: "plus.circle.fill", color: .green) { count += 1 }
                }

                Button("重置") { count = 0 }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(30)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }

    func glassButton(system: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 54))
                .foregroundStyle(color)
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

#Preview {
    ContentView()
}
