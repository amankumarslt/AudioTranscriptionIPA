//
//  GlassWaveformView.swift
//  test
//
//  Apple Glass-inspired animated waveform visualizer
//

import SwiftUI

struct GlassWaveformView: View {
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var phase: CGFloat = 0
    @State private var animationTimer: Timer?
    
    private let waveCount = 3
    private let waveColors: [Color] = [
        Color(red: 0.4, green: 0.7, blue: 1.0),   // Light blue
        Color(red: 0.6, green: 0.5, blue: 1.0),   // Purple
        Color(red: 1.0, green: 0.5, blue: 0.6)    // Pink
    ]
    
    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            // Waveform layers
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<waveCount, id: \.self) { index in
                        WaveShape(
                            phase: phase + CGFloat(index) * .pi / 3,
                            amplitude: isRecording ? (20 + audioLevel * 30) : 5,
                            frequency: 1.5 + CGFloat(index) * 0.3
                        )
                        .stroke(
                            LinearGradient(
                                colors: [
                                    waveColors[index].opacity(0.8),
                                    waveColors[index].opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(
                                lineWidth: 3 - CGFloat(index) * 0.5,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .blur(radius: CGFloat(index) * 0.5)
                    }
                    
                    // Center glow effect when recording
                    if isRecording {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.3 * audioLevel),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: geometry.size.width / 3
                                )
                            )
                            .frame(width: geometry.size.width / 2, height: geometry.size.height)
                            .blur(radius: 20)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .frame(height: 120)
        .shadow(
            color: isRecording ? Color.blue.opacity(0.3) : Color.clear,
            radius: 20,
            x: 0,
            y: 10
        )
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: isRecording) { newValue in
            if newValue {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            withAnimation(.linear(duration: 1/60)) {
                phase += isRecording ? 0.08 : 0.02
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(phase, AnimatablePair(amplitude, frequency))
        }
        set {
            phase = newValue.first
            amplitude = newValue.second.first
            frequency = newValue.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midY = rect.midY
        let width = rect.width
        let steps = Int(width)
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in 0...steps {
            let relativeX = CGFloat(x) / width
            let normalizedX = relativeX * 2 * .pi * frequency
            
            // Create a more organic wave with multiple sine components
            let sine1 = sin(normalizedX + phase)
            let sine2 = sin(normalizedX * 2 + phase * 1.5) * 0.3
            let sine3 = sin(normalizedX * 0.5 + phase * 0.7) * 0.5
            
            // Envelope to fade at edges
            let envelope = sin(relativeX * .pi)
            
            let y = midY + (sine1 + sine2 + sine3) * amplitude * envelope
            
            path.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }
        
        return path
    }
}

// Compact waveform for the recording button
struct MiniWaveformView: View {
    let isRecording: Bool
    
    @State private var bars: [CGFloat] = Array(repeating: 0.3, count: 5)
    @State private var animationTimer: Timer?
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: 20 * bars[index])
            }
        }
        .frame(height: 20)
        .onAppear {
            if isRecording {
                startAnimation()
            }
        }
        .onChange(of: isRecording) { newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                for i in 0..<5 {
                    bars[i] = CGFloat.random(in: 0.3...1.0)
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        withAnimation(.easeOut(duration: 0.3)) {
            bars = Array(repeating: 0.3, count: 5)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack(spacing: 40) {
            GlassWaveformView(isRecording: true, audioLevel: 0.7)
                .padding(.horizontal)
            
            GlassWaveformView(isRecording: false, audioLevel: 0)
                .padding(.horizontal)
        }
    }
}
