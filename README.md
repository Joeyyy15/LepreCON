# LepreCON

LepreCON is an iOS application in development for **Buck Naked Games**.  
The project aims to bring one of the company’s upcoming board games to mobile in a clean, interactive, and accessible format.

## About the Project

This app is being built as a digital adaptation of an upcoming Buck Naked Games board game.  
The goal is to preserve the fun, strategy, and identity of the original tabletop experience while making it easier to play in a mobile format.

LepreCON is currently being developed in **Swift** for iOS using **SwiftUI** and **SwiftData**.

## Goals

- Convert a physical board game experience into a mobile app
- Create an intuitive and visually engaging iOS interface
- Build a scalable codebase that supports future features and gameplay updates
- Keep the design and gameplay aligned with the Buck Naked Games brand

## Tech Stack

- **Language:** Swift
- **Framework:** SwiftUI
- **Persistence:** SwiftData
- **IDE:** Xcode
- **Platform:** iOS

## How to Run the App

1. Clone the repository:

```bash
git clone https://github.com/Joeyyy15/LepreCON.git
```

2. Move into the project folder:

```bash
cd LepreCON
```

3. Open the project in Xcode:

```bash
open LepreCON.xcodeproj
```

4. Select an iPhone simulator in Xcode.

5. Press **Command + R** to build and run the app.

## Current Project Structure

```text
LepreCON/
├── LepreCON.xcodeproj
├── LepreCON/
│   ├── App/
│   │   └── App entry point and app-level setup
│   │
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── Core game objects such as GameSession, Cup, Gem, and Player
│   │   ├── Rules/
│   │   │   └── Game setup, turn rules, placement rules, and gameplay logic
│   │   └── Services/
│   │       └── Game session creation and domain-level helpers
│   │
│   ├── Presentation/
│   │   ├── Common/
│   │   ├── Components/
│   │   ├── Game/
│   │   │   └── Gameplay screen, board view, hand view, and display state mapping
│   │   ├── Home/
│   │   ├── HowToPlay/
│   │   └── Results/
│   │
│   ├── Data/
│   │   └── Persistence and future saved-game/data handling
│   │
│   ├── Theme/
│   │   └── Shared colors, styling, and visual design tokens
│   │
│   └── Assets.xcassets/
│       └── App images, gem images, colors, and visual assets
│
├── LepreCONTests/
│   └── Unit tests for game setup, turn flow, placement, and domain rules
├── .gitignore
└── README.md
```
