import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("计数器", systemImage: "plusminus") }
            CalculatorView()
                .tabItem { Label("计算器", systemImage: "calculator") }
            TodoView()
                .tabItem { Label("待办", systemImage: "checklist") }
            NotesView()
                .tabItem { Label("备忘", systemImage: "note.text") }
        }
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            Color.black
            RadialGradient(colors: [.blue.opacity(0.75), .clear], center: .topLeading, startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
            RadialGradient(colors: [.purple.opacity(0.6), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 620)
                .ignoresSafeArea()
            RadialGradient(colors: [.cyan.opacity(0.45), .clear], center: .center, startRadius: 0, endRadius: 420)
                .ignoresSafeArea()
            RadialGradient(colors: [.white.opacity(0.18), .clear], center: .top, startRadius: 0, endRadius: 300)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct LiquidGlass: ViewModifier {
    var corner: CGFloat = 28
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .white.opacity(0.08), .white.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 22, x: 0, y: 10)
    }
}

extension View {
    func glassCard(_ corner: CGFloat = 28) -> some View { modifier(LiquidGlass(corner: corner)) }
}

struct GlassButtonStyle: ButtonStyle {
    var tint: Color
    var corner: CGFloat = 20
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        LinearGradient(colors: [tint.opacity(0.8), .white.opacity(0.15)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
            .foregroundStyle(tint)
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        ZStack {
            GlassBackground()
            VStack(spacing: 30) {
                Text("计数器")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("\(count)")
                    .font(.system(size: 96, weight: .heavy))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                HStack(spacing: 30) {
                    Button(action: { count -= 1 }) {
                        Image(systemName: "minus.circle.fill").font(.system(size: 56))
                    }
                    .buttonStyle(GlassButtonStyle(tint: .red))
                    Button(action: { count += 1 }) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 56))
                    }
                    .buttonStyle(GlassButtonStyle(tint: .green))
                }
                Button("重置") { count = 0 }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .buttonStyle(GlassButtonStyle(tint: .white, corner: 30))
            }
            .padding(30)
            .glassCard(36)
        }
    }
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var current: Double = 0
    @State private var op = ""
    @State private var resetNext = false

    let rows: [[String]] = [
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "−"],
        ["0", ".", "C", "+"],
        ["="]
    ]

    var body: some View {
        ZStack {
            GlassBackground()
            VStack(spacing: 14) {
                Text("计算器")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(display)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 10)
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            Button(action: { press(key) }) {
                                Text(key).font(.system(size: 30, weight: .medium)).frame(maxWidth: .infinity, minHeight: 62)
                            }
                            .buttonStyle(GlassButtonStyle(tint: key == "=" ? .yellow : .white, corner: 18))
                        }
                    }
                }
            }
            .padding(20)
            .glassCard(30)
        }
    }

    func press(_ key: String) {
        if key == "C" {
            display = "0"; current = 0; op = ""; resetNext = false
        } else if key == "=" {
            let v = calc()
            display = fmt(v); resetNext = true
        } else if ["+", "−", "×", "÷"].contains(key) {
            if !op.isEmpty { current = calc() } else { current = Double(display) ?? 0 }
            op = key; resetNext = true
        } else {
            if resetNext { display = key == "." ? "0." : key; resetNext = false }
            else if key == "." { if !display.contains(".") { display += "." } }
            else { display = display == "0" ? key : display + key }
        }
    }

    func calc() -> Double {
        let b = Double(display) ?? 0
        switch op {
        case "+": return current + b
        case "−": return current - b
        case "×": return current * b
        case "÷": return b == 0 ? 0 : current / b
        default: return b
        }
    }

    func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(v)
    }
}

struct TodoView: View {
    @State private var items: [String] = UserDefaults.standard.stringArray(forKey: "todos") ?? []
    @State private var text = ""

    var body: some View {
        ZStack {
            GlassBackground()
            VStack(spacing: 16) {
                Text("待办清单")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                HStack {
                    TextField("添加事项…", text: $text)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    Button("添加") {
                        if !text.isEmpty { items.append(text); save(); text = "" }
                    }
                    .buttonStyle(.borderedProminent)
                }
                List {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Text(item).font(.title3)
                            Spacer()
                            Button {
                                items.removeAll { $0 == item }
                                save()
                            } label: {
                                Image(systemName: "trash.fill").foregroundStyle(.red)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .foregroundStyle(.white)
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
            }
            .glassCard()
        }
    }

    func save() {
        UserDefaults.standard.set(items, forKey: "todos")
    }
}

struct NotesView: View {
    @AppStorage("note") private var note = ""

    var body: some View {
        ZStack {
            GlassBackground()
            VStack(spacing: 16) {
                Text("备忘录")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                TextEditor(text: $note)
                    .font(.title3)
                    .padding()
                    .frame(minHeight: 280)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .foregroundStyle(.white)
            }
            .glassCard()
        }
    }
}

#Preview {
    ContentView()
}
