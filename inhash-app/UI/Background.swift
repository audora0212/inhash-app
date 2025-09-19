import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 238/255, green: 242/255, blue: 248/255), location: 0.0),
                    .init(color: Color(red: 210/255, green: 219/255, blue: 230/255), location: 0.5),
                    .init(color: Color(red: 224/255, green: 231/255, blue: 241/255), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 420
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.34), Color.white.opacity(0.0)]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 520
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
            
            // 상단 좌측 근처
            FloatingOrb(colors: [Color.blue.opacity(0.55), Color.purple.opacity(0.30)], size: 140, initialOffset: CGSize(width: -170, height: -260), finalOffset: CGSize(width: -170, height: -260), duration: 7.5, delay: 0)
                .blendMode(.plusLighter)
            // 상단 우측 근처
            FloatingOrb(colors: [Color.purple.opacity(0.42), Color.blue.opacity(0.26)], size: 160, initialOffset: CGSize(width: 170, height: -220), finalOffset: CGSize(width: 170, height: -220), duration: 8.2, delay: 0.4)
                .blendMode(.plusLighter)
            // 카드 좌측 가장자리 뒤
            FloatingOrb(colors: [Color.blue.opacity(0.40), Color.purple.opacity(0.22)], size: 120, initialOffset: CGSize(width: -170, height: 20), finalOffset: CGSize(width: -170, height: 20), duration: 7.8, delay: 0.3)
                .blendMode(.plusLighter)
            // 하단 우측 근처
            FloatingOrb(colors: [Color.purple.opacity(0.34), Color.blue.opacity(0.24)], size: 150, initialOffset: CGSize(width: 190, height: 230), finalOffset: CGSize(width: 190, height: 230), duration: 6.8, delay: 0.2)
                .blendMode(.plusLighter)
            // 하단 좌측 근처
            FloatingOrb(colors: [Color.blue.opacity(0.36), Color.purple.opacity(0.20)], size: 130, initialOffset: CGSize(width: -200, height: 220), finalOffset: CGSize(width: -200, height: 220), duration: 7.2, delay: 0.6)
                .blendMode(.plusLighter)
            // 추가: 화면 왼쪽 하단에 더 작은 오브
            FloatingOrb(colors: [Color.blue.opacity(0.45), Color.purple.opacity(0.18)], size: 90, initialOffset: CGSize(width: -220, height: 300), finalOffset: CGSize(width: -220, height: 300), duration: 6.4, delay: 0.5)
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }
}

struct FloatingOrb: View {
    let colors: [Color]
    let size: CGFloat
    let initialOffset: CGSize
    let finalOffset: CGSize
    let duration: Double
    let delay: Double
    
    
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [colors.first ?? .blue, colors.dropFirst().first ?? .purple, .clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.7
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 20)
            .opacity(0.9)
            .scaleEffect(1.0)
            .offset(x: initialOffset.width, y: initialOffset.height)
    }
}


