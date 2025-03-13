import SwiftUI
import CoreHaptics
import CoreLocation

struct QiblaCompassView: View {
    @StateObject private var viewModel = QiblaCompassViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @State private var engine: CHHapticEngine?
    @State private var pulse: Bool = false
    @State private var lastHapticAngle: Int = -1
    
    private let alignmentThreshold: Double = 2
    private let glowRadius: CGFloat = 30
    
    private var rotationAngle: Double {
        guard let heading = locationManager.heading?.magneticHeading else { return 0 }
        return (viewModel.qiblaDirection - heading).normalizedAngle()
    }
    
    private var alignmentProgress: Double {
        min(1.0, 1.0 - (abs(rotationAngle) / 180))
    }
    @State private var isViewActive = false
    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [.cyan, .purple, .cyan]), center: .center)
                .blur(radius: 80)
               // .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("QIBLA DIRECTION")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 40)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [.cyan.opacity(0.3), .clear]),
                                           center: .center, startRadius: 0, endRadius: 200))
                        .frame(width: 350, height: 350)
                        .blur(radius: glowRadius)
                        .opacity(pulse ? 0.8 : 0.4)
                        .animation(.easeInOut(duration: 1.5).repeatForever(), value: pulse)
                    
                    ZStack {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.8), .black.opacity(0.6)]),
                                               startPoint: .top, endPoint: .bottom))
                            .frame(width: 300, height: 300)
                            .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                        
                        CompassDisc(rotation: rotationAngle)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: rotationAngle)
                        
                        Kaaba3DView()
                            .offset(y: -130)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: rotationAngle)
                    }
                    .perspectiveRotation(angle: rotationAngle)
                    
                    PointerView()
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                        .offset(y: -8)
                    
                   // ProgressRing(progress: alignmentProgress)
                     //   .frame(width: 340, height: 340)
                }
                
                Text(directionText)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .gradientForeground(colors: [.cyan, .purple])
                    .padding(.top, 40)
                    .opacity(abs(rotationAngle) < alignmentThreshold ? 0 : 1)
                
                Spacer()
                
                //VStack(spacing: 8) {
                  //  Text("Current Qibla Angle")
                   //     .font(.caption)
                     //   .foregroundColor(.white.opacity(0.7))
                    //Text("\(viewModel.qiblaDirection, specifier: "%.2f")°")
                   //     .font(.system(.title3, design: .monospaced))
                     //   .foregroundColor(.white)
               // }
                .padding(.bottom, 30)
            }
        }
        
        .preferredColorScheme(.dark)
                .onAppear {
                    setupCompass()
                    isViewActive = true
                }
                .onDisappear {
                    isViewActive = false
                }
                .onChange(of: rotationAngle, perform: handleRotation)
    }
    
    // MARK: - Haptic Feedback
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    private func triggerHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine?.makePlayer(with: pattern).start(atTime: 0)
        } catch {
            print("Haptic pattern error: \(error)")
        }
    }
    
    // MARK: - Rotation Handling
    private var directionText: String {
        abs(rotationAngle) < alignmentThreshold ? "YOU ARE FACING KAABA" : rotationAngle > 2 ? "RIGHT" : "LEFT"
    }
    
    private func setupCompass() {
        prepareHaptics()
        pulse.toggle()
        if let location = locationManager.location {
            viewModel.fetchQiblaDirection(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude)
        }
    }
    
    // MARK: - Haptic Feedback
        private func handleRotation(_ angle: Double) {
            guard isViewActive else { return }  // Only handle haptics when view is active
            
            let currentAngle = Int(angle.rounded())
          //  let currentAngle = Int(angle.rounded())
               
               if abs(angle) < alignmentThreshold {
                   // Display message without triggering haptic feedback
                   lastHapticAngle = currentAngle
               } else if currentAngle != lastHapticAngle {
                   triggerHaptic()
                   lastHapticAngle = currentAngle
               }
        }
        
}

// MARK: - Subviews
extension QiblaCompassView {
    struct CompassDisc: View {
        let rotation: Double
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), Color(white: 0.15)]),
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 280, height: 280)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                                                  startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                    )
                
                ForEach(0..<360) { degree in
                    if degree % 5 == 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(degree % 90 == 0 ? Color.cyan : Color.white.opacity(0.3))
                            .frame(width: degree % 15 == 0 ? 3 : 2, height: degree % 90 == 0 ? 20 : 10)
                            .offset(y: 120)
                            .rotationEffect(.degrees(Double(degree)))
                    }
                }
            }
        }
    }
    
    struct Kaaba3DView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(white: 0.2), .black]),
                                       startPoint: .top, endPoint: .bottom))
                    .frame(width: 40, height: 60)
                    .rotation3DEffect(.degrees(45), axis: (x: 1, y: 0, z: 0))
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                
                Text("🕋")
                    .font(.system(size: 30))
                    .offset(y: -8)
            }
        }
    }
    
    struct PointerView: View {
        var body: some View {
            ZStack {
                Capsule()
                    .fill(RadialGradient(gradient: Gradient(colors: [.cyan.opacity(0.3), .clear]),
                                       center: .center, startRadius: 0, endRadius: 20))
                    .frame(width: 15, height: 80)
                    .blur(radius: 8)
                
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [.cyan, .purple]),
                                       startPoint: .top, endPoint: .bottom))
                    .frame(width: 6, height: 60)
                    .overlay(
                        Capsule()
                            .stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.5), .clear]),
                                                  startPoint: .top, endPoint: .bottom), lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(gradient: Gradient(colors: colors),
                          startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .mask(self)
    }
    
    func perspectiveRotation(angle: Double) -> some View {
        let xRotation = sin(angle.toRadians()) * 15
        let yRotation = cos(angle.toRadians()) * 15
        
        return self
            .rotation3DEffect(.degrees(xRotation), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(yRotation), axis: (x: 0, y: 1, z: 0))
    }
}

// MARK: - Helper Extensions
extension Double {
    func normalizedAngle() -> Double {
        let angle = truncatingRemainder(dividingBy: 360)
        return angle < 0 ? angle + 360 : angle
    }
    
    func toRadians() -> Double {
        return self * .pi / 180
    }
}
