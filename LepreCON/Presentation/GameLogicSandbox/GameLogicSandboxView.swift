import SwiftUI

struct GameLogicSandboxView: View {
    @State private var output: String = "Press 'Deal Sample Turn' to see the hand and board before choosing a gem."
    @State private var currentChoiceIndex: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        currentChoiceIndex = 0
                        output = GameLogicSandbox.previewTurnStart()
                    } label: {
                        Text("Deal Sample Turn")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.9))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    HStack(spacing: 12) {
                        Button {
                            currentChoiceIndex = 0
                            output = GameLogicSandbox.runSingleTurnExample(chosenGemIndex: 0)
                        } label: {
                            Text("Pick 1st Gem")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.9))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button {
                            currentChoiceIndex = 1
                            output = GameLogicSandbox.runSingleTurnExample(chosenGemIndex: 1)
                        } label: {
                            Text("Pick 2nd Gem")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.9))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    Button {
                        currentChoiceIndex = 2
                        output = GameLogicSandbox.runSingleTurnExample(chosenGemIndex: 2)
                    } label: {
                        Text("Pick 3rd Gem")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.9))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    ScrollView {
                        Text(output)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            }
            .navigationTitle("Logic Sandbox")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Game Logic Sandbox") {
    GameLogicSandboxView()
}
