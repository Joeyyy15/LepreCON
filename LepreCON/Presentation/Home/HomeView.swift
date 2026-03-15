//
// HomeView.swift
// LepreCON
//
// Home screen layout only. Structure and UI live here; state and actions
// are delegated to HomeViewModel. Uses reusable components from Presentation/Components.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    let onStartGame: () -> Void

    init(
        viewModel: HomeViewModel = HomeViewModel(),
        onStartGame: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onStartGame = onStartGame
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: Profile (left), title space (center), Settings (right)
                topBar

                // Centered app title
                titleSection

                // Scrollable menu stack
                menuSection

                Spacer(minLength: 16)

                // Bottom row: Promo (left), Play button (right)
                bottomSection
            }
            .padding(.horizontal, AppTheme.screenPaddingHorizontal)
            .padding(.vertical, AppTheme.screenPaddingVertical)
        }
        .sheet(item: Binding(
            get: { viewModel.destination },
            set: { viewModel.destination = $0 }
        )) { destination in
            if destination == .howToPlay {
                HowToPlayView(onDismiss: { viewModel.dismissDestination() })
            } else {
                PlaceholderDestinationView(destination: destination, onDismiss: { viewModel.dismissDestination() })
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            TopIconButton(systemName: "person.circle", action: { viewModel.profileTapped() })
            Spacer()
            TopIconButton(systemName: "gearshape", action: { viewModel.settingsTapped() })
        }
        .padding(.bottom, 8)
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("LepreCON")
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.top, 12)
            .padding(.bottom, 28)
    }

    // MARK: - Menu Stack

    private var menuSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                MenuButton(title: "The Stable", action: { viewModel.theStableTapped() })
                MenuButton(title: "How To Play", action: { viewModel.howToPlayTapped() })
                MenuButton(title: "Record Book", action: { viewModel.recordBookTapped() })
                MenuButton(title: "Difficulty", action: { viewModel.difficultyTapped() })
                MenuButton(title: "Customization", action: { viewModel.customizationTapped() })

                // Online / Local segmented control
                playModePicker
            }
            .frame(maxWidth: AppTheme.maxContentWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
    }

    private var playModePicker: some View {
        Picker("Play mode", selection: Binding(
            get: { viewModel.playMode },
            set: { viewModel.setPlayMode($0) }
        )) {
            ForEach(PlayMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, 4)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        HStack(alignment: .bottom, spacing: 16) {
            PromoArea()
                .frame(maxWidth: 140)

            Spacer(minLength: 16)

            Button {
                viewModel.playTapped()
                onStartGame()
            } label: {
                Text("Play")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.9))
                    .frame(minWidth: 120)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 32)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, 8)
    }
}

// MARK: - Previews

#Preview("Home") {
    HomeView(onStartGame: {})
}

#Preview("Home (compact)") {
    HomeView(onStartGame: {})
        .environment(\.horizontalSizeClass, .compact)
}

