//
//  AudioRecorder.swift
//  test
//
//  Created by Snigdha Banerjee on 08/12/25.
//

import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession?
    private var meteringTimer: Timer?

    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var audioLevel: CGFloat = 0

    private let recordingsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("Recordings")
    }()

    override init() {
        super.init()
        setupAudioSession()
        createRecordingsDirectory()
    }

    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func createRecordingsDirectory() {
        do {
            try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        } catch {
            print("Failed to create recordings directory: \(error)")
        }
    }

    func startRecording() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "recording_\(timestamp).m4a"
        let fileURL = recordingsDirectory.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            recordingURL = fileURL
            isRecording = true
            startMetering()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        stopMetering()
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        audioLevel = 0
    }
    
    private func startMetering() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            
            // Get the average power for channel 0
            let power = recorder.averagePower(forChannel: 0)
            
            // Convert dB to linear scale (0 to 1)
            // dB ranges from -160 (silence) to 0 (max)
            let minDb: Float = -60
            let normalizedPower = max(0, (power - minDb) / (-minDb))
            
            DispatchQueue.main.async {
                self.audioLevel = CGFloat(normalizedPower)
            }
        }
    }
    
    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
}
