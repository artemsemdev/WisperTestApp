// swift-tools-version: 6.0
import PackageDescription

// Module dependency graph (spec section 3). Core depends on nothing but Foundation;
// every other module depends on Core; Files may use Audio/Speech/Models later.
let package = Package(
    name: "VoxFlowKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "VoxFlowCore", targets: ["VoxFlowCore"]),
        .library(name: "VoxFlowAudio", targets: ["VoxFlowAudio"]),
        .library(name: "VoxFlowSpeech", targets: ["VoxFlowSpeech"]),
        .library(name: "VoxFlowModels", targets: ["VoxFlowModels"]),
        .library(name: "VoxFlowFiles", targets: ["VoxFlowFiles"]),
        .library(name: "VoxFlowDictation", targets: ["VoxFlowDictation"]),
        .library(name: "VoxFlowStorage", targets: ["VoxFlowStorage"]),
        .library(name: "VoxFlowStyling", targets: ["VoxFlowStyling"]),
        .library(name: "VoxFlowMCP", targets: ["VoxFlowMCP"]),
    ],
    targets: [
        .target(name: "VoxFlowCore"),
        .target(name: "VoxFlowAudio", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowSpeech", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowModels", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowFiles", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowDictation", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowStorage", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowStyling", dependencies: ["VoxFlowCore"]),
        .target(name: "VoxFlowMCP", dependencies: ["VoxFlowCore"]),

        .testTarget(name: "VoxFlowCoreTests", dependencies: ["VoxFlowCore"]),
        .testTarget(name: "VoxFlowAudioTests", dependencies: ["VoxFlowAudio"]),
        .testTarget(name: "VoxFlowSpeechTests", dependencies: ["VoxFlowSpeech"]),
        .testTarget(name: "VoxFlowModelsTests", dependencies: ["VoxFlowModels"]),
        .testTarget(name: "VoxFlowFilesTests", dependencies: ["VoxFlowFiles"]),
        .testTarget(name: "VoxFlowDictationTests", dependencies: ["VoxFlowDictation"]),
        .testTarget(name: "VoxFlowStorageTests", dependencies: ["VoxFlowStorage"]),
        .testTarget(name: "VoxFlowStylingTests", dependencies: ["VoxFlowStyling"]),
        .testTarget(name: "VoxFlowMCPTests", dependencies: ["VoxFlowMCP"]),
    ],
    swiftLanguageModes: [.v6]
)
