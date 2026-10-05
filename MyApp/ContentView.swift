import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem { Label("相机", systemImage: "camera.fill") }
            RecorderView()
                .tabItem { Label("录音机", systemImage: "mic.fill") }
            ToolsView()
                .tabItem { Label("工具", systemImage: "wrench.and.screwdriver.fill") }
            CalculatorView()
                .tabItem { Label("计算器", systemImage: "calculator") }
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

struct CameraView: View {
    @State private var showPicker = false
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 24) {
                Label("相机", systemImage: "camera.fill")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 90))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("点下方按钮打开摄像头拍照")
                        .foregroundStyle(.white.opacity(0.6))
                }
                Button {
                    checkPermission { showPicker = true }
                } label: {
                    Label("拍照", systemImage: "camera.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 14)
                }
                .glassEffect(in: Capsule())
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $image)
        }
    }

    func checkPermission(_ done: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            done()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { DispatchQueue.main.async { done() } }
            }
        default:
            break
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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
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
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100.0,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
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
        if isPlaying {
            player?.stop()
            isPlaying = false
            return
        }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.play()
        isPlaying = true
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {}

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

struct RecorderView: View {
    @StateObject private var recorder = Recorder()

    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 28) {
                Label("录音机", systemImage: "mic.fill")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Image(systemName: recorder.isRecording ? "waveform" : "mic.circle")
                    .font(.system(size: 90))
                    .foregroundStyle(recorder.isRecording ? .red : .white)
                HStack(spacing: 24) {
                    Button {
                        if recorder.isRecording { recorder.stop() } else { recorder.start() }
                    } label: {
                        Label(recorder.isRecording ? "停止" : "录音",
                              systemImage: recorder.isRecording ? "stop.fill" : "record.circle")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                    }
                    .glassEffect(in: Capsule())
                    Button { recorder.play() } label: {
                        Label(recorder.isPlaying ? "停止播放" : "播放", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                    }
                    .glassEffect(in: Capsule())
                    .disabled(!recorder.hasRecording)
                }
            }
            .padding(30)
            .glassEffect(in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        }
    }
}

struct ToolsView: View {
    @State private var torchOn = false
    @State private var seconds = 0
    @State private var timerRunning = false
    @State private var dice = 1

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LiquidBackground()
            ScrollView {
                VStack(spacing: 20) {
                    Label("工具", systemImage: "wrench.and.screwdriver.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Button {
                        torchOn.toggle()
                        toggleTorch(torchOn)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        Label(torchOn ? "手电筒：开" : "手电筒：关",
                              systemImage: torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title3)
                            .foregroundStyle(torchOn ? .yellow : .white)
                            .frame(maxWidth: .infinity)
                            .padding(18)
                    }
                    .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    HStack {
                        Button { timerRunning.toggle() } label: {
                            Label(timerRunning ? "暂停" : "开始",
                                  systemImage: timerRunning ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(18)
                        }
                        .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        Text(timeString(seconds))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 120)
                        Button { seconds = 0 } label: {
                            Label("归零", systemImage: "arrow.counterclockwise")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(18)
                        }
                        .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    Button {
                        dice = Int.random(in: 1...6)
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    } label: {
                        HStack {
                            Text("🎲")
                                .font(.system(size: 50))
                            Text("掷骰子：\(dice)")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                    }
                    .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .padding(24)
            }
        }
        .onReceive(timer) { _ in
            if timerRunning { seconds += 1 }
        }
    }

    func toggleTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
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

#Preview {
    ContentView()
}
