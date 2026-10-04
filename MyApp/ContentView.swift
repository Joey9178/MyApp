import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("计数器", systemImage: "plusminus.circle.fill") }
            CalculatorView()
                .tabItem { Label("计算器", systemImage: "calculator") }
            TodoView()
                .tabItem { Label("待办", systemImage: "checklist") }
            NotesView()
                .tabItem { Label("备忘", systemImage: "note.text") }
        }
    }
}

struct LiquidBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.12, blue: 0.30), Color(red: 0.22, green: 0.10, blue: 0.38)],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(colors: [.blue.opacity(0.5), .clear], center: .topLeading, startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
            RadialGradient(colors: [.purple.opacity(0.55), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 620)
                .ignoresSafeArea()
            RadialGradient(colors: [.orange.opacity(0.3), .clear], center: .bottomLeading, startRadius: 0, endRadius: 420)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        ZStack {
            LiquidBackground()
            GlassEffectContainer {
                VStack(spacing: 26) {
                    Label("计数器", systemImage: "plusminus.circle.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("\(count)")
                        .font(.system(size: 110, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    HStack(spacing: 28) {
                        Button { count -= 1 } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 84, height: 84)
                        }
                        .glassEffect(in: Circle())
                        Button { count += 1 } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 84, height: 84)
                        }
                        .glassEffect(in: Circle())
                    }
                    Button("重置") { count = 0 }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .glassEffect(in: Capsule())
                }
                .padding(30)
            }
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
            LiquidBackground()
            GlassEffectContainer {
                VStack(spacing: 14) {
                    Label("计算器", systemImage: "calculator")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(display)
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 6)
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { key in
                                Button { press(key) } label: {
                                    Text(key)
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity, minHeight: 62)
                                }
                                .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                    }
                }
                .padding(20)
            }
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
            LiquidBackground()
            GlassEffectContainer {
                VStack(spacing: 16) {
                    Label("待办清单", systemImage: "checklist")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    HStack {
                        TextField("添加事项…", text: $text)
                            .foregroundStyle(.white)
                            .padding()
                            .glassEffect(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        Button {
                            if !text.isEmpty { items.append(text); save(); text = "" }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                        }
                        .glassEffect(in: Circle())
                    }
                    List {
                        ForEach(items, id: \.self) { item in
                            HStack {
                                Text(item)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                Spacer()
                                Button {
                                    items.removeAll { $0 == item }
                                    save()
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .padding(20)
            }
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
            LiquidBackground()
            GlassEffectContainer {
                VStack(spacing: 16) {
                    Label("备忘录", systemImage: "note.text")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    TextEditor(text: $note)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(minHeight: 300)
                        .scrollContentBackground(.hidden)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(20)
            }
        }
    }
}

#Preview {
    ContentView()
}
