import SwiftUI
import AVFoundation
import UIKit

struct ToolItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let view: AnyView
}

struct ContentView: View {
    let tools: [ToolItem] = [
        ToolItem(name: "计算器", icon: "plusminus", color: .orange, view: AnyView(CalculatorView())),
        ToolItem(name: "秒表", icon: "stopwatch", color: .yellow, view: AnyView(StopwatchView())),
        ToolItem(name: "倒计时", icon: "timer", color: .red, view: AnyView(CountdownView())),
        ToolItem(name: "骰子", icon: "die.face.5", color: .purple, view: AnyView(DiceView())),
        ToolItem(name: "随机数", icon: "number", color: .blue, view: AnyView(RandomView())),
        ToolItem(name: "相机", icon: "camera", color: .cyan, view: AnyView(CameraView())),
        ToolItem(name: "录音机", icon: "mic", color: .pink, view: AnyView(RecorderView())),
        ToolItem(name: "手电筒", icon: "flashlight.on.fill", color: .yellow, view: AnyView(FlashlightView())),
        ToolItem(name: "长度换算", icon: "ruler", color: .green, view: AnyView(ConverterView()))
    ]
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(tools) { tool in
                            NavigationLink(destination: tool.view) { ToolCard(tool: tool) }.buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("我的工具")
        }
    }
}

struct ToolCard: View {
    let tool: ToolItem
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: tool.icon)
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(tool.color)
            Text(tool.name).font(.headline).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.vertical, 8)
        .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct LiquidBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.12, blue: 0.30), Color(red: 0.22, green: 0.10, blue: 0.38)], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [.blue.opacity(0.5), .clear], center: .topLeading, startRadius: 0, endRadius: 520).ignoresSafeArea()
            RadialGradient(colors: [.purple.opacity(0.55), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 620).ignoresSafeArea()
            RadialGradient(colors: [.orange.opacity(0.3), .clear], center: .bottomLeading, startRadius: 0, endRadius: 420).ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var current: Double = 0
    @State private var op = ""
    @State private var resetNext = false
    let rows: [[String]] = [["7","8","9","÷"],["4","5","6","×"],["1","2","3","−"],["0",".","C","+"],["="]]
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 14) {
                Text(display).font(.system(size: 54, weight: .bold, design: .rounded)).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.5).frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal, 8)
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            Button { press(key) } label: {
                                Text(key).font(.system(size: 30, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity, minHeight: 60)
                            }
                            .glassEffect(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
            }
            .padding(22)
            .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
    }
    func press(_ key: String) {
        if key == "C" {
            display = "0"; current = 0; op = ""; resetNext = false
        } else if key == "=" {
            display = fmt(calc()); resetNext = true
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

struct StopwatchView: View {
    @State private var elapsed = 0.0
    @State private var running = false
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 28) {
                Text(timeString(elapsed)).font(.system(size: 62, weight: .bold, design: .rounded)).foregroundStyle(.white).contentTransition(.numericText())
                HStack(spacing: 24) {
                    Button { running.toggle() } label: {
                        Label(running ? "暂停" : "开始", systemImage: running ? "pause.fill" : "play.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 26).padding(.vertical, 14)
                    }.glassEffect(in: Capsule())
                    Button { elapsed = 0 } label: {
                        Label("归零", systemImage: "arrow.counterclockwise").font(.headline).foregroundStyle(.white).padding(.horizontal, 26).padding(.vertical, 14)
                    }.glassEffect(in: Capsule())
                }
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
        .onReceive(timer) { _ in if running { elapsed += 0.01 } }
    }
    func timeString(_ t: Double) -> String {
        let m = Int(t) / 60; let s = Int(t) % 60; let cs = Int((t - Double(Int(t))) * 100)
        return String(format: "%02d:%02d.%02d", m, s, cs)
    }
}

struct CountdownView: View {
    @State private var input = ""
    @State private var remaining = 0
    @State private var running = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 24) {
                Text("倒计时").font(.title2.bold()).foregroundStyle(.white)
                if remaining == 0 && !running {
                    TextField("输入秒数", text: $input).keyboardType(.numberPad).font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(.white).multilineTextAlignment(.center).padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    Button {
                        if let s = Int(input), s > 0 { remaining = s; running = true }
                    } label: {
                        Label("开始", systemImage: "play.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 14)
                    }.glassEffect(in: Capsule())
                } else {
                    Text("\(remaining)").font(.system(size: 92, weight: .heavy, design: .rounded)).foregroundStyle(remaining <= 3 ? .red : .white).contentTransition(.numericText())
                    Button { running = false; remaining = 0 } label: {
                        Label("停止", systemImage: "stop.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 30).padding(.vertical, 14)
                    }.glassEffect(in: Capsule())
                }
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
        .onReceive(timer) { _ in
            if running {
                if remaining > 0 { remaining -= 1 } else { running = false; UINotificationFeedbackGenerator().notificationOccurred(.success) }
            }
        }
    }
}

struct DiceView: View {
    @State private var dice = 1
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 28) {
                Text("掷骰子").font(.title2.bold()).foregroundStyle(.white)
                Image(systemName: diceIcon(dice)).font(.system(size: 110)).foregroundStyle(.purple).symbolRenderingMode(.hierarchical)
                Button {
                    dice = Int.random(in: 1...6)
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                } label: {
                    Label("摇一摇", systemImage: "hand.raised.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 34).padding(.vertical, 16)
                }.glassEffect(in: Capsule())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
    func diceIcon(_ n: Int) -> String {
        switch n {
        case 1: return "die.face.1"
        case 2: return "die.face.2"
        case 3: return "die.face.3"
        case 4: return "die.face.4"
        case 5: return "die.face.5"
        default: return "die.face.6"
        }
    }
}

struct RandomView: View {
    @State private var minText = "1"
    @State private var maxText = "100"
    @State private var result = "?"
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 20) {
                Text("随机数").font(.title2.bold()).foregroundStyle(.white)
                HStack {
                    TextField("最小", text: $minText).keyboardType(.numberPad).foregroundStyle(.white).padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    TextField("最大", text: $maxText).keyboardType(.numberPad).foregroundStyle(.white).padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
                Text(result).font(.system(size: 80, weight: .heavy, design: .rounded)).foregroundStyle(.blue).contentTransition(.numericText())
                Button {
                    if let mn = Int(minText), let mx = Int(maxText), mn <= mx {
                        result = "\(Int.random(in: mn...mx))"; UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                } label: {
                    Label("生成", systemImage: "arrow.clockwise").font(.headline).foregroundStyle(.white).padding(.horizontal, 34).padding(.vertical, 14)
                }.glassEffect(in: Capsule())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
}

struct CameraView: View {
    @State private var showPicker = false
    @State private var image: UIImage?
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 24) {
                Label("相机", systemImage: "camera.fill").font(.title2.bold()).foregroundStyle(.white)
                if let image {
                    Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    Image(systemName: "camera.viewfinder").font(.system(size: 90)).foregroundStyle(.white.opacity(0.5))
                    Text("点下方按钮打开摄像头拍照").foregroundStyle(.white.opacity(0.6))
                }
                Button {
                    checkPermission { showPicker = true }
                } label: {
                    Label("拍照", systemImage: "camera.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 34).padding(.vertical, 14)
                }.glassEffect(in: Capsule())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
        .sheet(isPresented: $showPicker) { ImagePicker(image: $image) }
    }
    func checkPermission(_ done: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: done()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in if granted { DispatchQueue.main.async { done() } } }
        default: break
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
    func start() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            guard granted else { return }
            DispatchQueue.main.async {
                let session = AVAudioSession.sharedInstance()
                try? session.setCategory(.playAndRecord, mode: .default)
                try? session.setActive(true)
                let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                self.recorder = try? AVAudioRecorder(url: self.url, settings: settings)
                self.recorder?.delegate = self
                self.recorder?.record()
                self.isRecording = true
            }
        }
    }
    func stop() {
        recorder?.stop()
        isRecording = false
        hasRecording = true
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    func play() {
        if isPlaying { player?.stop(); isPlaying = false; return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
        isPlaying = true
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {}
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { isPlaying = false }
}

struct RecorderView: View {
    @StateObject private var recorder = Recorder()
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 28) {
                Label("录音机", systemImage: "mic.fill").font(.title2.bold()).foregroundStyle(.white)
                Image(systemName: recorder.isRecording ? "waveform" : "mic.circle").font(.system(size: 90)).foregroundStyle(recorder.isRecording ? .red : .white)
                HStack(spacing: 24) {
                    Button {
                        if recorder.isRecording { recorder.stop() } else { recorder.start() }
                    } label: {
                        Label(recorder.isRecording ? "停止" : "录音", systemImage: recorder.isRecording ? "stop.fill" : "record.circle").font(.headline).foregroundStyle(.white).padding(.horizontal, 28).padding(.vertical, 14)
                    }.glassEffect(in: Capsule())
                    Button { recorder.play() } label: {
                        Label(recorder.isPlaying ? "停止播放" : "播放", systemImage: "play.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 28).padding(.vertical, 14)
                    }.glassEffect(in: Capsule()).disabled(!recorder.hasRecording)
                }
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
}

struct FlashlightView: View {
    @State private var on = false
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 28) {
                Text("手电筒").font(.title2.bold()).foregroundStyle(.white)
                Image(systemName: on ? "flashlight.on.fill" : "flashlight.off.fill").font(.system(size: 110)).foregroundStyle(on ? .yellow : .white.opacity(0.4))
                Button {
                    on.toggle(); toggle(on)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Label(on ? "关闭" : "开启", systemImage: on ? "lightbulb.slash.fill" : "lightbulb.fill").font(.headline).foregroundStyle(.white).padding(.horizontal, 40).padding(.vertical, 16)
                }.glassEffect(in: Capsule())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
    func toggle(_ isOn: Bool) {
        guard let d = AVCaptureDevice.default(for: .video), d.hasTorch else { return }
        try? d.lockForConfiguration()
        d.torchMode = isOn ? .on : .off
        d.unlockForConfiguration()
    }
}

struct ConverterView: View {
    @State private var value = "1"
    @State private var fromUnit = 0
    @State private var toUnit = 1
    let units = ["米", "千米", "英里", "英尺"]
    let factor: [Double] = [1, 1000, 1609.34, 0.3048]
    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 20) {
                Text("长度换算").font(.title2.bold()).foregroundStyle(.white)
                TextField("数值", text: $value).keyboardType(.decimalPad).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(.white).multilineTextAlignment(.center).padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                HStack {
                    Picker("从", selection: $fromUnit) { ForEach(units.indices, id: \.self) { Text(units[$0]).foregroundStyle(.white) } }.pickerStyle(.menu).foregroundStyle(.white)
                    Text("→").foregroundStyle(.white).font(.title2)
                    Picker("到", selection: $toUnit) { ForEach(units.indices, id: \.self) { Text(units[$0]).foregroundStyle(.white) } }.pickerStyle(.menu).foregroundStyle(.white)
                }
                Text(convertResult).font(.system(size: 42, weight: .bold, design: .rounded)).foregroundStyle(.green).contentTransition(.numericText())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
    var convertResult: String {
        guard let v = Double(value) else { return "--" }
        return String(format: "%.4f", v * factor[fromUnit] / factor[toUnit])
    }
}

#Preview {
    ContentView()
}
