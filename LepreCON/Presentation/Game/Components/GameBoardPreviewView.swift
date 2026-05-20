//
//  GameBoardPreviewView.swift
//  LepreCON
//
//  Temporary gameplay board preview.
//  This lays out the main visual pieces based on the target gameplay mockup.
//

import SwiftUI

struct GameBoardPreviewView: View {
    var body: some View {
        ZStack {
            boardBackground

            VStack(spacing: 18) {
                rainbowLanes

                bottomContainers
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 24)
        }
    }

    private var boardBackground: some View {
        LinearGradient(
            colors: [
                .purple.opacity(0.35),
                .pink.opacity(0.25),
                .yellow.opacity(0.20),
                .cyan.opacity(0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var rainbowLanes: some View {
        HStack(alignment: .bottom, spacing: 8) {
            RainbowLaneView(
                laneColor: .red,
                gemImageNames: ["gem_red", "gem_red", "gem_red", "gem_red"],
                width: 42,
                height: 260
            )

            RainbowLaneView(
                laneColor: .orange,
                gemImageNames: ["gem_orange", "gem_orange", "gem_orange"],
                width: 42,
                height: 260
            )

            RainbowLaneView(
                laneColor: .yellow,
                gemImageNames: ["gem_yellow", "gem_yellow", "gem_yellow", "gem_yellow"],
                width: 42,
                height: 260
            )

            RainbowLaneView(
                laneColor: .green,
                gemImageNames: ["gem_green", "gem_green", "gem_green"],
                width: 42,
                height: 260
            )

            RainbowLaneView(
                laneColor: .blue,
                gemImageNames: ["gem_blue", "gem_blue", "gem_blue"],
                width: 42,
                height: 260
            )

            RainbowLaneView(
                laneColor: .purple,
                gemImageNames: ["gem_purple", "gem_purple", "gem_purple", "gem_purple"],
                width: 42,
                height: 260
            )
        }
    }

    private var bottomContainers: some View {
        HStack(alignment: .center, spacing: 6) {
            CloudSlotView(
                cloudNumber: 1,
                gemImageNames: ["gem_red", "gem_red", "gem_red"],
                width: 74,
                height: 58
            )

            CloudSlotView(
                cloudNumber: 2,
                gemImageNames: ["gem_orange", "gem_orange"],
                width: 74,
                height: 58
            )

            PotSlotView(
                gemImageNames: ["gem_yellow", "gem_white"],
                width: 92,
                height: 78
            )

            CloudSlotView(
                cloudNumber: 3,
                gemImageNames: ["gem_green", "gem_blue"],
                width: 74,
                height: 58
            )

            CloudSlotView(
                cloudNumber: 4,
                gemImageNames: ["gem_purple", "gem_black"],
                width: 74,
                height: 58
            )
        }
    }
}

#Preview("Game Board Preview") {
    GameBoardPreviewView()
}
