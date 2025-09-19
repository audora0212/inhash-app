import SwiftUI

struct LmsLoadingView: View {
    @Binding var progress: Int
    @Binding var isLoading: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 24) {
                // 카드 스타일의 로딩 패널
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .overlay(Image(systemName: "bolt.horizontal.circle.fill").foregroundColor(.secondary))
                            .frame(width: 28, height: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LMS 연결 중")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("계정 정보를 확인하고 데이터를 수집하고 있어요")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    ProgressView(value: Double(progress), total: 100)
                        .tint(.accentColor)
                    HStack {
                        Text("진행률 \(progress)%")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Button(action: { dismiss() }) {
                        SecondaryButtonLabel(title: "취소", loading: false)
                            .frame(height: 44)
                    }
                    .buttonStyle(LightenOnPressStyle(cornerRadius: 12, overlayOpacity: 0.12))
                    .opacity(isLoading ? 0.7 : 1)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
                )
                .frame(maxWidth: 360)
            }
        }
        .ignoresSafeArea()
    }
}


