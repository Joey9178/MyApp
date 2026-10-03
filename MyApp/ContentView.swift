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

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 28) {
            Text("计数器")
                .font(.largeTitle.bold())
            Text("\(count)")
                .font(.system(size: 96, weight: .heavy))
                .contentTransition(.numericText())
            HStack(spacing: 28) {
                Button { count -= 1 } label: {
                    Image(systemName: "minus.circle.fill").font(.system(size: 56))
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                Button { count += 1 } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 56))
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            Button("重置") { count = 0 }
                .font(.headline)
                .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(36)
        .glassEffect(in: RoundedRectangle(cornerRadius: 40, style: .continuous))
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
        VStack(spacing: 14) {
            Text("计算器")
                .font(.largeTitle.bold())
            Text(display)
                .font(.system(size: 52, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { press(key) }) {
                            Text(key)
                                .font(.system(size: 30, weight: .medium))
                                .frame(maxWidth: .infinity, minHeight: 60)
                        }
                        .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
        .padding(20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
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
        VStack(spacing: 16) {
            Text("待办清单")
                .font(.largeTitle.bold())
            HStack {
                TextField("添加事项…", text: $text)
                    .textFieldStyle(.plain)
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
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding(20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    func save() {
        UserDefaults.standard.set(items, forKey: "todos")
    }
}

struct NotesView: View {
    @AppStorage("note") private var note = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("备忘录")
                .font(.largeTitle.bold())
            TextEditor(text: $note)
                .font(.title3)
                .frame(minHeight: 280)
                .scrollContentBackground(.hidden)
        }
        .padding(20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

#Preview {
    ContentView()
}
