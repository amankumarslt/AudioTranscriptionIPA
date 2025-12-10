//
//  SpeechRecognizer.swift
//  test
//
//  Created by Snigdha Banerjee on 08/12/25.
//

import Speech
import AVFoundation
import Combine

class SpeechRecognizer: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcription = ""
    @Published var isTranscribing = false
    @Published var error: Error?

    override init() {
        super.init()
        requestAuthorization()
    }

    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    self.error = NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition permission denied"])
                case .restricted:
                    self.error = NSError(domain: "SpeechRecognizer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Speech recognition restricted"])
                case .notDetermined:
                    self.error = NSError(domain: "SpeechRecognizer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not determined"])
                @unknown default:
                    break
                }
            }
        }
    }

    func startTranscribing() {
        guard !audioEngine.isRunning else { return }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            guard let recognitionRequest = recognitionRequest else {
                error = NSError(domain: "SpeechRecognizer", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
                return
            }

            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }

                if let result = result {
                    DispatchQueue.main.async {
                        self.transcription = result.bestTranscription.formattedString
                    }
                }

                if error != nil || result?.isFinal == true {
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    DispatchQueue.main.async {
                        self.isTranscribing = false
                    }
                }
            }

            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            DispatchQueue.main.async {
                self.isTranscribing = true
            }

        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isTranscribing = false
            }
        }
    }

    func stopTranscribing() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        DispatchQueue.main.async {
            self.isTranscribing = false
        }
    }

    func resetTranscription() {
        transcription = ""
        error = nil
    }
}
