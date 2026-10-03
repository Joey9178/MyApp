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
        LinearGradient(
            colors: [.blue.opacity(0.5), .purple.opacity(0.4), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassCard()) }
}

func glassIcon(_ system: String, _ color: Color, _ action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: system)
            .font(.system(size: 56))
            .foregroundStyle(color)
            .padding(14)
            .background(.ultraThinMaterial, in: Circle())
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
                Text("\(count)")
                    .font(.system(size: 96, weight: .heavy))
                    .contentTransition(.numericText())
                HStack(spacing: 30) {
                    glassIcon("minus.circle.fill", .red) { count -= 1 }
                    glassIcon("plus.circle.fill", .green) { count += 1 }
                }
                Button("重置") { count = 0 }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .glassCard()
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
                Text(display)
                    .font(.system(size: 52, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 8)
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            keyButton(key)
                        }
                    }
                }
            }
            .glassCard()
        }
    }

    func keyButton(_ key: String) -> some View {
        Button { press(key) } label: {
            Text(key)
                .font(.system(size: 30, weight: .medium))
                .frame(maxWidth: .infinity, minHeight: 62)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
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
                            Text(item)
                                .font(.title3)
                            Spacer()
                            Button {
                                items.removeAll { $0 == item }
                                save()
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .listRowBackground(Color.clear)
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
                TextEditor(text: $note)
                    .font(.title3)
                    .padding()
                    .frame(minHeight: 280)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .glassCard()
        }
    }
}

#Preview {
    ContentView()
}
