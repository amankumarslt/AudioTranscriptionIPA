//
//  ContentView.swift
//  test
//
//  Created by Snigdha Banerjee on 08/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriptionViewModel()
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.04, green: 0.04, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Ambient glow effects
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(viewModel.isRecording ? 0.3 : 0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                    .blur(radius: 60)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(viewModel.isRecording ? 0.25 : 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
                    .blur(radius: 60)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Voice Recorder")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 20)
                    
                    // Glass Waveform
                    GlassWaveformView(
                        isRecording: viewModel.isRecording,
                        audioLevel: viewModel.audioLevel
                    )
                    .padding(.horizontal)
                    
                    // Recording Button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }
                    }) {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: viewModel.isRecording
                                            ? [Color.red.opacity(0.6), Color.orange.opacity(0.3)]
                                            : [Color.blue.opacity(0.6), Color.purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 2)
                            
                            // Main button
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: viewModel.isRecording
                                            ? [Color.red, Color.red.opacity(0.7)]
                                            : [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .shadow(color: viewModel.isRecording ? .red.opacity(0.5) : .blue.opacity(0.5), radius: 20)
                            
                            // Icon or mini waveform
                            if viewModel.isRecording {
                                MiniWaveformView(isRecording: true)
                            } else {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .scaleEffect(viewModel.isRecording ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isRecording)
                    
                    // Status text
                    Text(viewModel.isRecording ? "Recording & Transcribing..." : "Tap to Start")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(viewModel.isRecording ? .red : .white.opacity(0.7))
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Live Transcription Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.blue)
                            Text("Live Transcription")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        ScrollView {
                            Text(viewModel.currentTranscription.isEmpty 
                                 ? "Start recording to see transcription..." 
                                 : viewModel.currentTranscription)
                                .font(.body)
                                .foregroundColor(viewModel.currentTranscription.isEmpty ? .gray : .white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 120)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    // Saved Recordings Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.purple)
                            Text("Saved Recordings")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        if viewModel.savedRecordings.isEmpty {
                            Text("No recordings yet")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 30)
                        } else {
                            ForEach(viewModel.savedRecordings.prefix(5)) { recording in
                                RecordingRow(recording: recording)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct RecordingRow: View {
    let recording: RecordingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recording.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.gray)

            Text(recording.transcription.prefix(80) + (recording.transcription.count > 80 ? "..." : ""))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ContentView()
}
