//
//  TranscriptionViewModel.swift
//  test
//
//  Created by Snigdha Banerjee on 08/12/25.
//

import Foundation
import Combine

class TranscriptionViewModel: ObservableObject {
    private let audioRecorder = AudioRecorder()
    private let speechRecognizer = SpeechRecognizer()

    @Published var isRecording = false
    @Published var currentTranscription = ""
    @Published var errorMessage = ""
    @Published var savedRecordings: [RecordingItem] = []
    @Published var audioLevel: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()
    private var finalTranscription = ""

    init() {
        setupBindings()
        loadSavedRecordings()
    }

    private func setupBindings() {
        audioRecorder.$isRecording
            .assign(to: &$isRecording)

        audioRecorder.$audioLevel
            .assign(to: &$audioLevel)

        speechRecognizer.$transcription
            .assign(to: &$currentTranscription)

        speechRecognizer.$error
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }

    func startRecording() {
        errorMessage = ""
        finalTranscription = ""
        speechRecognizer.resetTranscription()

        // Start both recording and transcription
        audioRecorder.startRecording()
        speechRecognizer.startTranscribing()
    }

    func stopRecording() {
        audioRecorder.stopRecording()
        speechRecognizer.stopTranscribing()

        // Save the final transcription
        finalTranscription = currentTranscription
        saveTranscription()
        loadSavedRecordings() // Refresh the list
    }

    private func saveTranscription() {
        guard let recordingURL = audioRecorder.recordingURL else { return }

        let timestamp = Int(Date().timeIntervalSince1970)
        let transcriptionFilename = "transcription_\(timestamp).txt"
        let transcriptionURL = getDocumentsDirectory().appendingPathComponent(transcriptionFilename)

        do {
            try finalTranscription.write(to: transcriptionURL, atomically: true, encoding: .utf8)

            let recordingItem = RecordingItem(
                id: UUID(),
                audioURL: recordingURL,
                transcriptionURL: transcriptionURL,
                timestamp: Date(),
                transcription: finalTranscription
            )

            // Save metadata
            saveRecordingMetadata(recordingItem)

        } catch {
            errorMessage = "Failed to save transcription: \(error.localizedDescription)"
        }
    }

    private func saveRecordingMetadata(_ recording: RecordingItem) {
        let metadataURL = getDocumentsDirectory().appendingPathComponent("recordings_metadata.json")

        var recordings = loadRecordingMetadata()
        recordings.append(recording)

        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: metadataURL)
        } catch {
            print("Failed to save metadata: \(error)")
        }
    }

    private func loadRecordingMetadata() -> [RecordingItem] {
        let metadataURL = getDocumentsDirectory().appendingPathComponent("recordings_metadata.json")

        do {
            let data = try Data(contentsOf: metadataURL)
            return try JSONDecoder().decode([RecordingItem].self, from: data)
        } catch {
            return []
        }
    }

    private func loadSavedRecordings() {
        savedRecordings = loadRecordingMetadata().sorted { $0.timestamp > $1.timestamp }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct RecordingItem: Identifiable, Codable {
    let id: UUID
    let audioURL: URL
    let transcriptionURL: URL
    let timestamp: Date
    let transcription: String
}
