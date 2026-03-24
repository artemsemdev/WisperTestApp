# Phase 1 Design Spec: Shared Core, Desktop Minimum, Packaging, and First Run

Derived from [Phase 1.md](../../product/Phase%201.md) and [ROADMAP.md](../../product/ROADMAP.md).

## Overview

Phase 1 restructures VoxFlow from a CLI-only tool into a multi-host architecture with a shared core, adds a macOS Blazor Hybrid desktop app, and delivers packaging and first-run UX. All current PRD features continue working through the shared core. CLI and MCP hosts are rewired to use the same interfaces.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Shared core architecture | Full DI with interfaces | Three hosts (CLI, Desktop, MCP) need the same services composed differently per host |
| Project organization | Technical layer (`Services/`, `Interfaces/`, `Models/`, `Configuration/`) | Classic .NET convention, familiar to .NET developers |
| Desktop UI style | Focused dark interface, drop zone hero | Matches audio tool aesthetic (Logic Pro, Audacity), minimal cognitive load |
| Desktop navigation | Contextual flow — screen IS the state | Maps directly to Phase 1 state machine, no explicit navigation needed |
| Not-ready UX | Checklist with action buttons + retry | Matches existing `StartupValidationService` output, gives complete picture |
| Complete state UX | Sticky result, drop zone still accessible | Respects user pace, enables chaining without extra clicks |
| Progress reporting | `IProgress<T>` from .NET BCL | Idiomatic .NET, handles `SynchronizationContext` for Blazor UI thread |
| Settings UI | Visual editor for key settings + "open JSON" link for advanced | Covers 90% of use cases without building 45 form controls |

---

## 1. Solution Architecture

### Project Layout

```
VoxFlow.sln
├── src/
│   ├── VoxFlow.Core/                       ← NEW class library (net9.0)
│   │   ├── Interfaces/
│   │   │   ├── ITranscriptionService.cs
│   │   │   ├── IBatchTranscriptionService.cs
│   │   │   ├── IValidationService.cs
│   │   │   ├── IAudioConversionService.cs
│   │   │   ├── IModelService.cs
│   │   │   ├── ILanguageSelectionService.cs
│   │   │   ├── ITranscriptionFilter.cs
│   │   │   ├── IOutputWriter.cs
│   │   │   ├── IFileDiscoveryService.cs
│   │   │   ├── IBatchSummaryWriter.cs
│   │   │   ├── ITranscriptReader.cs
│   │   │   └── IConfigurationService.cs
│   │   ├── Services/
│   │   │   ├── TranscriptionService.cs
│   │   │   ├── BatchTranscriptionService.cs
│   │   │   ├── ValidationService.cs
│   │   │   ├── AudioConversionService.cs
│   │   │   ├── ModelService.cs
│   │   │   ├── LanguageSelectionService.cs
│   │   │   ├── TranscriptionFilter.cs
│   │   │   ├── OutputWriter.cs
│   │   │   ├── FileDiscoveryService.cs
│   │   │   ├── BatchSummaryWriter.cs
│   │   │   ├── TranscriptReader.cs
│   │   │   └── ConfigurationService.cs
│   │   ├── Models/
│   │   │   ├── TranscribeFileRequest.cs
│   │   │   ├── TranscribeFileResult.cs
│   │   │   ├── BatchTranscribeRequest.cs
│   │   │   ├── BatchTranscribeResult.cs
│   │   │   ├── ValidationResult.cs
│   │   │   ├── ValidationCheck.cs
│   │   │   ├── ModelInfo.cs
│   │   │   ├── ProgressUpdate.cs
│   │   │   ├── AppState.cs
│   │   │   ├── SupportedLanguage.cs
│   │   │   ├── FilteredSegment.cs
│   │   │   ├── SkippedSegment.cs
│   │   │   ├── LanguageSelectionResult.cs
│   │   │   ├── FileProcessingResult.cs
│   │   │   └── DiscoveredFile.cs
│   │   ├── Configuration/
│   │   │   └── TranscriptionOptions.cs
│   │   └── DependencyInjection/
│   │       └── ServiceCollectionExtensions.cs
│   │
│   ├── VoxFlow.Cli/                        ← Thin CLI host (net9.0)
│   │   ├── Program.cs
│   │   ├── CliProgressHandler.cs
│   │   ├── ConsoleValidationReporter.cs
│   │   └── VoxFlow.Cli.csproj
│   │
│   ├── VoxFlow.Desktop/                    ← NEW MAUI Blazor Hybrid (net9.0-maccatalyst)
│   │   ├── MauiProgram.cs
│   │   ├── MainPage.xaml / MainPage.xaml.cs
│   │   ├── Components/
│   │   │   ├── App.razor
│   │   │   ├── MainLayout.razor
│   │   │   ├── Pages/
│   │   │   │   ├── NotReadyView.razor
│   │   │   │   ├── ReadyView.razor
│   │   │   │   ├── RunningView.razor
│   │   │   │   ├── FailedView.razor
│   │   │   │   └── CompleteView.razor
│   │   │   └── Shared/
│   │   │       ├── SettingsPanel.razor
│   │   │       ├── StatusBar.razor
│   │   │       └── DropZone.razor
│   │   ├── ViewModels/
│   │   │   ├── AppViewModel.cs
│   │   │   └── SettingsViewModel.cs
│   │   ├── Platform/
│   │   │   └── MacFilePicker.cs
│   │   ├── wwwroot/
│   │   │   └── css/app.css
│   │   └── VoxFlow.Desktop.csproj
│   │
│   └── VoxFlow.McpServer/                  ← Existing MCP, rewired (net9.0)
│       ├── Program.cs
│       ├── Tools/WhisperMcpTools.cs
│       ├── Prompts/WhisperMcpPrompts.cs
│       ├── Resources/WhisperMcpResources.cs
│       ├── Configuration/McpOptions.cs
│       └── VoxFlow.McpServer.csproj
│
├── tests/
│   ├── VoxFlow.Core.Tests/                 ← Core unit tests
│   ├── VoxFlow.Cli.Tests/                  ← CLI integration tests
│   ├── VoxFlow.Desktop.Tests/              ← Desktop smoke tests
│   ├── VoxFlow.McpServer.Tests/            ← MCP tests (migrated)
│   └── TestSupport/                        ← Shared test utilities
│
└── docs/
```

### Dependency Graph

```
VoxFlow.Cli ────────► VoxFlow.Core ◄──────── VoxFlow.McpServer
                          ▲
                          │
                    VoxFlow.Desktop
```

No host references another host. All business logic lives in `VoxFlow.Core`.

### Solution Restructure

The current repo has `VoxFlow.csproj` at the root and `src/WhisperNET.McpServer/`. Phase 1 requires moving to the `src/` layout above. Migration steps:

1. Create `src/VoxFlow.Core/` — new class library, receive all business logic
2. Create `src/VoxFlow.Cli/` — move `Program.cs` and CLI-specific code, add project reference to Core
3. Move `src/WhisperNET.McpServer/` to `src/VoxFlow.McpServer/` — rename for consistency, replace `InternalsVisibleTo` + facades with Core interface injection
4. Create `src/VoxFlow.Desktop/` — new MAUI Blazor Hybrid project
5. Move test projects under `tests/` (already partially there), update project references
6. Update `VoxFlow.sln` with new project paths
7. Remove old root-level `VoxFlow.csproj`, `Program.cs`, `Facades/`, `Contracts/` (now in Core)

### Architectural Rules

| Rule | Enforcement |
|------|-------------|
| No business logic in CLI `Program.cs` | Convention; CLI only composes DI and maps exit codes |
| No business logic in Blazor components or view models | Convention; components bind to Core service results |
| No business logic in MCP tools | Convention; tools validate paths and delegate to Core interfaces |
| All hosts consume Core via interfaces | Compiler-enforced; Core exposes only interfaces publicly |
| `AddVoxFlowCore(IServiceCollection)` is the single DI entry point | Convention; all hosts call this one method |
| No MAUI or Blazor dependency in VoxFlow.Core | Compiler-enforced; Core has no UI framework references |
| `IProgress<ProgressUpdate>` for all progress | Convention; Core never writes to Console directly |
| `CancellationToken` through all async operations | Convention; matches existing ADR-009 |
| `TranscriptionOptions` remains the config shape | Convention; loaded by `IConfigurationService` |

### What Gets Eliminated

- `InternalsVisibleTo` attribute — Core interfaces are public
- `Facades/` directory — Core interfaces replace facades
- `Contracts/ApplicationContracts.cs` as internal types — Models become public in Core
- Static service calls in MCP tools — replaced with injected interfaces
- Console output from business logic — replaced with `IProgress<T>` events

---

## 2. Shared Core (VoxFlow.Core)

### Interface Layering

Interfaces are split into two tiers:

**Host-facing interfaces** — the only interfaces hosts (CLI, Desktop, MCP) inject and call directly:

| Interface | Purpose |
|-----------|---------|
| `ITranscriptionService` | Orchestrates single-file transcription end-to-end |
| `IBatchTranscriptionService` | Orchestrates batch transcription end-to-end |
| `IValidationService` | Runs preflight checks |
| `IConfigurationService` | Loads and provides configuration |
| `ITranscriptReader` | Reads transcript files safely |

**Internal pipeline interfaces** — used only by `TranscriptionService` and `BatchTranscriptionService` internally. Registered in DI for testability but not expected to be called by hosts:

| Interface | Purpose |
|-----------|---------|
| `IAudioConversionService` | ffmpeg conversion |
| `IModelService` | Model loading, factory lifecycle, and inspection (note: `InspectModel` is also used by MCP's `inspect_model` tool — this is the one exception where a host calls an internal interface) |
| `ILanguageSelectionService` | Inference + scoring |
| `ITranscriptionFilter` | Segment filtering |
| `IOutputWriter` | Transcript file writing |
| `IFileDiscoveryService` | Batch file enumeration |
| `IBatchSummaryWriter` | Batch summary reporting |

This separation means hosts never touch `WhisperFactory`, `float[]` audio samples, or other Whisper.net types directly. `WhisperFactory` is an implementation detail internal to the pipeline — `IModelService` and `ILanguageSelectionService` coordinate through the `TranscriptionService` implementation, not through host code.

All interfaces are public (for test project access). Implementations are internal.

```csharp
// === Host-facing interfaces ===

public interface ITranscriptionService
{
    Task<TranscribeFileResult> TranscribeFileAsync(
        TranscribeFileRequest request,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}

public interface IBatchTranscriptionService
{
    Task<BatchTranscribeResult> TranscribeBatchAsync(
        BatchTranscribeRequest request,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}

public interface IValidationService
{
    Task<ValidationResult> ValidateAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);
}

public interface ITranscriptReader
{
    Task<TranscriptReadResult> ReadAsync(
        string path, int? maxCharacters = null,
        CancellationToken cancellationToken = default);
}

public interface IConfigurationService
{
    Task<TranscriptionOptions> LoadAsync(string? configurationPath = null);
    IReadOnlyList<SupportedLanguage> GetSupportedLanguages(string? configurationPath = null);
}

// === Internal pipeline interfaces (not called by hosts) ===

public interface IAudioConversionService
{
    Task ConvertToWavAsync(
        string inputPath, string outputPath,
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);

    Task<bool> ValidateFfmpegAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);
}

public interface IModelService
{
    Task<WhisperFactory> GetOrCreateFactoryAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default);

    ModelInfo InspectModel(TranscriptionOptions options);
}

public interface ILanguageSelectionService
{
    Task<LanguageSelectionResult> SelectBestCandidateAsync(
        WhisperFactory factory, float[] audioSamples,
        TranscriptionOptions options,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default);
}

public interface ITranscriptionFilter
{
    CandidateFilteringResult FilterSegments(
        SupportedLanguage language,
        IReadOnlyList<SegmentData> segments,
        TranscriptionOptions options);
}

public interface IOutputWriter
{
    Task WriteAsync(
        string outputPath,
        IReadOnlyList<FilteredSegment> segments,
        CancellationToken cancellationToken = default);

    string BuildOutputText(IReadOnlyList<FilteredSegment> segments);
}

public interface IFileDiscoveryService
{
    IReadOnlyList<DiscoveredFile> DiscoverInputFiles(BatchOptions batchOptions);
}

public interface IBatchSummaryWriter
{
    Task WriteAsync(
        string summaryPath,
        IReadOnlyList<FileProcessingResult> results,
        CancellationToken cancellationToken = default);
}
```

### WhisperFactory Lifecycle (ADR-010 Update for Long-Lived Hosts)

ADR-010 states "keep the WhisperFactory alive for the process lifetime" and flags long-lived processes as needing a revisit. The desktop app is a long-lived process.

**Decision:** `IModelService` uses `GetOrCreateFactoryAsync()` with singleton caching. The factory is created on first use and cached for the app's lifetime. This is consistent with ADR-010's intent (avoid teardown instability) and works for long-lived processes because:

- The Whisper model is loaded once and stays in memory (same as current CLI behavior)
- If the user changes the model in settings, the cached factory is invalidated and a new one created on next transcription
- The `ModelService` implementation manages this internally — hosts are unaware

```csharp
internal sealed class ModelService : IModelService
{
    private WhisperFactory? _cachedFactory;
    private string? _cachedModelPath;

    public async Task<WhisperFactory> GetOrCreateFactoryAsync(
        TranscriptionOptions options,
        CancellationToken cancellationToken = default)
    {
        if (_cachedFactory != null && _cachedModelPath == options.ModelFilePath)
            return _cachedFactory;

        _cachedFactory = await CreateFactoryInternalAsync(options, cancellationToken);
        _cachedModelPath = options.ModelFilePath;
        return _cachedFactory;
    }
}
```

### DI Registration

```csharp
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddVoxFlowCore(this IServiceCollection services)
    {
        services.AddSingleton<IConfigurationService, ConfigurationService>();
        services.AddSingleton<IValidationService, ValidationService>();
        services.AddSingleton<IAudioConversionService, AudioConversionService>();
        services.AddSingleton<IModelService, ModelService>();
        services.AddSingleton<ILanguageSelectionService, LanguageSelectionService>();
        services.AddSingleton<ITranscriptionFilter, TranscriptionFilter>();
        services.AddSingleton<IOutputWriter, OutputWriter>();
        services.AddSingleton<IFileDiscoveryService, FileDiscoveryService>();
        services.AddSingleton<IBatchSummaryWriter, BatchSummaryWriter>();
        services.AddSingleton<ITranscriptReader, TranscriptReader>();
        services.AddSingleton<ITranscriptionService, TranscriptionService>();
        services.AddSingleton<IBatchTranscriptionService, BatchTranscriptionService>();
        return services;
    }
}
```

### Models (DTOs)

All existing DTOs from `Contracts/ApplicationContracts.cs` become public records in `VoxFlow.Core/Models/`. The key additions:

```csharp
/// App-level state for desktop UI state machine.
public enum AppState
{
    NotReady,
    Ready,
    Running,
    Failed,
    Complete
}

/// Progress events emitted by Core services.
public sealed record ProgressUpdate(
    ProgressStage Stage,
    double PercentComplete,
    TimeSpan Elapsed,
    string? Message = null,
    string? CurrentLanguage = null,
    int? BatchFileIndex = null,
    int? BatchFileTotal = null);

public enum ProgressStage
{
    Validating,
    Converting,
    LoadingModel,
    Transcribing,
    Filtering,
    Writing,
    Complete,
    Failed
}
```

### TranscriptionService Implementation

The high-level `ITranscriptionService` orchestrates the full pipeline (currently in `Program.RunSingleFileAsync`):

```csharp
internal sealed class TranscriptionService : ITranscriptionService
{
    private readonly IValidationService _validation;
    private readonly IAudioConversionService _audioConversion;
    private readonly IModelService _modelService;
    private readonly ILanguageSelectionService _languageSelection;
    private readonly IOutputWriter _outputWriter;

    // Constructor injection of all dependencies

    public async Task<TranscribeFileResult> TranscribeFileAsync(
        TranscribeFileRequest request,
        IProgress<ProgressUpdate>? progress = null,
        CancellationToken cancellationToken = default)
    {
        // 1. Load config
        // 2. Validate environment → report progress
        // 3. Convert audio → report progress
        // 4. Load model → report progress
        // 5. Load WAV samples
        // 6. Select best language candidate → report progress
        // 7. Write output → report progress
        // 8. Return structured result with transcript preview
    }
}
```

This moves orchestration logic out of `Program.cs` while preserving the exact same pipeline sequence documented in `04-runtime-sequences.md`.

---

## 3. Desktop App (VoxFlow.Desktop)

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Host | .NET MAUI Blazor Hybrid |
| Target | `net9.0-maccatalyst` |
| UI | Blazor components (HTML/CSS/C#) |
| Theme | Dark, audio-tool aesthetic |
| Navigation | Contextual flow (state machine) |

### State Machine

The desktop app's single view transforms based on `AppState`:

```
                    ┌──────────────────┐
                    │    NotReady       │ ← Checklist with action buttons
                    │ (validation fail) │
                    └────────┬─────────┘
                             │ all checks pass
                             ▼
                    ┌──────────────────┐
              ┌────►│      Ready       │ ← Drop zone hero + status bar
              │     │  (idle, waiting) │
              │     └────────┬─────────┘
              │              │ file dropped/selected
              │              ▼
              │     ┌──────────────────┐
              │     │     Running      │ ← Progress bar, elapsed time
              │     │ (transcribing)   │
              │     └───┬────────┬─────┘
              │         │        │
              │    success    failure
              │         │        │
              │         ▼        ▼
              │  ┌───────────┐ ┌──────────────┐
              │  │ Complete  │ │   Failed     │
              │  │ (result)  │ │ (error+retry)│
              │  └─────┬─────┘ └──────┬───────┘
              │        │              │
              └────────┴──────────────┘
                   new file / retry
```

### AppViewModel (State Machine Orchestrator)

```csharp
public class AppViewModel : INotifyPropertyChanged
{
    private readonly ITranscriptionService _transcriptionService;
    private readonly IValidationService _validationService;
    private readonly IConfigurationService _configService;

    public AppState CurrentState { get; private set; }
    public ValidationResult? ValidationResult { get; private set; }
    public TranscribeFileResult? TranscriptionResult { get; private set; }
    public ProgressUpdate? CurrentProgress { get; private set; }
    public string? ErrorMessage { get; private set; }

    // On app launch: validate → NotReady or Ready
    public async Task InitializeAsync();

    // On file drop/select: Ready → Running → Complete or Failed
    public async Task TranscribeFileAsync(string filePath);

    // On retry: Failed → Running
    public async Task RetryAsync();

    // Re-validate: NotReady → Ready or NotReady
    public async Task RevalidateAsync();
}
```

The ViewModel is thin — it calls Core services and updates state. No business logic.

### Blazor Components

**MainLayout.razor** — Dark shell with gear icon for settings overlay:

```
┌─────────────────────────────────────────────┐
│                    VoxFlow              ⚙    │
│─────────────────────────────────────────────│
│                                             │
│            [Current State View]             │
│                                             │
│─────────────────────────────────────────────│
│  ● ffmpeg    ● ggml-base    ● English       │
└─────────────────────────────────────────────┘
```

**NotReadyView.razor** — Checklist with action buttons:

```
┌─────────────────────────────────────────────┐
│  Environment Setup Required                  │
│                                              │
│  ✓  Settings file loaded                     │
│  ✗  ffmpeg not found          [Install ↗]    │
│  ✓  Model directory writable                 │
│  ⚠  Model needs download      [Download]     │
│  ✓  Whisper runtime available                │
│                                              │
│              [ Retry Validation ]             │
└──────────────────────────────────────────────┘
```

**ReadyView.razor** — Drop zone hero:

```
┌─────────────────────────────────────────────┐
│            Ready to transcribe               │
│                                              │
│         ┌─────────────────────┐              │
│         │                     │              │
│         │    Drop audio file  │              │
│         │    here or click    │              │
│         │    to browse        │              │
│         │                     │              │
│         └─────────────────────┘              │
│                                              │
│            [ Browse Files ]                  │
└──────────────────────────────────────────────┘
```

**RunningView.razor** — Progress display:

```
┌─────────────────────────────────────────────┐
│           Transcribing...                    │
│                                              │
│  interview.m4a                               │
│                                              │
│  ████████████░░░░░░░░  62%                   │
│                                              │
│  Stage: Transcribing (English)               │
│  Elapsed: 00:01:34                           │
│                                              │
│              [ Cancel ]                      │
└──────────────────────────────────────────────┘
```

**CompleteView.razor** — Result with persistent drop zone:

```
┌─────────────────────────────────────────────┐
│           Transcription Complete              │
│                                              │
│  Language: English                            │
│  Segments: 142 accepted, 8 filtered          │
│  Duration: 00:02:15                          │
│                                              │
│  ┌─────────────────────────────────────┐     │
│  │ 00:00:01→00:00:03: Hello, this is  │     │
│  │ 00:00:03→00:00:07: a test of the   │     │
│  │ 00:00:07→00:00:11: transcription... │     │
│  └─────────────────────────────────────┘     │
│                                              │
│  Output: ~/Documents/result.txt              │
│  [ Open Folder ]  [ Copy Transcript ]        │
│                                              │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐     │
│  │  Drop another file to transcribe   │     │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘     │
└──────────────────────────────────────────────┘
```

**FailedView.razor** — Error with retry:

```
┌─────────────────────────────────────────────┐
│           Transcription Failed                │
│                                              │
│  ✗  ffmpeg conversion failed                 │
│                                              │
│  Error: Input file format not supported.     │
│  File: recording.opus                        │
│                                              │
│  [ Retry ]  [ Choose Different File ]        │
└──────────────────────────────────────────────┘
```

**SettingsPanel.razor** — Slide-over panel from gear icon:

```
┌──────────────────────────────┐
│  Settings                  ✕ │
│                              │
│  Model                       │
│  [▾ Base (ggml-base)      ]  │
│                              │
│  Language                    │
│  [▾ English               ]  │
│                              │
│  Output Directory            │
│  ~/Documents/transcripts     │
│  [ Change... ]               │
│                              │
│  ffmpeg Path                 │
│  /usr/local/bin/ffmpeg       │
│  [ Change... ]               │
│                              │
│  [ Open appsettings.json ↗ ] │
│                              │
│  [ Save ]                    │
└──────────────────────────────┘
```

### Desktop-Specific Integrations (Shell Layer)

These live in `VoxFlow.Desktop/Platform/`, not in Core:

| Integration | Implementation |
|-------------|----------------|
| File picker | `FilePicker.PickAsync()` via MAUI Essentials |
| Drag-and-drop | HTML5 drag-and-drop events in Blazor, with JS interop for macOS drop delegate if needed |
| Open folder | `Launcher.OpenAsync()` via MAUI Essentials |
| Clipboard | `Clipboard.SetTextAsync()` via MAUI Essentials |
| App menu | MAUI `MenuBarItem` (About, Preferences, Quit) |
| Dock icon | MAUI default behavior |

### Dark Theme CSS

The dark theme follows an audio-tool aesthetic. Key design tokens:

```css
:root {
    --bg-primary: #1a1a2e;
    --bg-secondary: #16213e;
    --bg-surface: #0f3460;
    --text-primary: #e0e0f0;
    --text-secondary: #a0a0b8;
    --text-muted: #6c6c8a;
    --accent: #4a4aff;
    --accent-hover: #5c5cff;
    --success: #28c840;
    --warning: #febc2e;
    --error: #ff5f57;
    --border: #2a2a4a;
    --drop-zone-border: #4a4a6a;
    --progress-bar: #4a4aff;
    --progress-track: #2a2a4a;
    --font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
    --border-radius: 8px;
}
```

---

## 4. CLI Host Migration (VoxFlow.Cli)

The CLI becomes a thin host that composes DI and delegates to Core:

```csharp
public static class Program
{
    public static async Task<int> Main(string[] args)
    {
        var services = new ServiceCollection();
        services.AddVoxFlowCore();
        var provider = services.BuildServiceProvider();

        using var cts = new CancellationTokenSource();
        Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

        var configService = provider.GetRequiredService<IConfigurationService>();
        var options = await configService.LoadAsync();

        var progress = new CliProgressHandler(options);

        if (options.IsBatchMode)
        {
            var batchService = provider.GetRequiredService<IBatchTranscriptionService>();
            var result = await batchService.TranscribeBatchAsync(
                new BatchTranscribeRequest(/* from options */),
                progress, cts.Token);
            return result.Failed > 0 ? 1 : 0;
        }

        var transcriptionService = provider.GetRequiredService<ITranscriptionService>();
        var fileResult = await transcriptionService.TranscribeFileAsync(
            new TranscribeFileRequest(options.InputFilePath),
            progress, cts.Token);
        return fileResult.Success ? 0 : 1;
    }
}
```

`CliProgressHandler` implements `IProgress<ProgressUpdate>` and renders the existing ANSI progress bar, spinner, and console output. All existing CLI behavior and output contract is preserved.

`ConsoleValidationReporter` renders validation results with the existing color-coded ANSI format.

---

## 5. MCP Server Migration (VoxFlow.McpServer)

The MCP server drops `InternalsVisibleTo` and the `Facades/` layer. Tools inject Core interfaces directly:

```csharp
// Program.cs — simplified composition root
builder.Services.AddVoxFlowCore();
builder.Services.AddSingleton<IPathPolicy>(sp => new PathPolicy(mcpOptions));

// WhisperMcpTools.cs — inject Core interfaces directly
[McpServerToolType]
public sealed class WhisperMcpTools(
    ITranscriptionService transcriptionService,
    IBatchTranscriptionService batchService,
    IValidationService validationService,
    IModelService modelService,
    IConfigurationService configService,
    ITranscriptReader transcriptReader,
    IPathPolicy pathPolicy)
{
    [McpServerTool("validate_environment")]
    public async Task<string> ValidateEnvironment(CancellationToken ct)
    {
        var options = await configService.LoadAsync();
        var result = await validationService.ValidateAsync(options, ct);
        return JsonSerializer.Serialize(result);
    }

    // ... other tools follow the same pattern
}
```

**What stays MCP-specific:**
- `IPathPolicy` and `PathPolicy` — MCP security boundary, not in Core
- `McpOptions` — MCP configuration
- MCP prompts and resources
- `Console.SetOut(Console.Error)` for stdout protection

---

## 6. Desktop App Composition Root

```csharp
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts => { /* system fonts */ });

        builder.Services.AddMauiBlazorWebView();
        builder.Services.AddVoxFlowCore();
        builder.Services.AddSingleton<AppViewModel>();
        builder.Services.AddSingleton<SettingsViewModel>();

        return builder.Build();
    }
}
```

The Desktop uses the same `AddVoxFlowCore()` as CLI and MCP. It adds `AppViewModel` which wraps Core calls and manages the state machine.

---

## 7. Progress Reporting

### IProgress<ProgressUpdate> Flow

```
VoxFlow.Core (services)
    │
    │  IProgress<ProgressUpdate>.Report(update)
    │
    ├──► CLI: CliProgressHandler → ANSI progress bar + spinner
    ├──► Desktop: BlazorProgressHandler → InvokeAsync → Blazor UI update
    └──► MCP: NullProgress (no visual progress needed)
```

### BlazorProgressHandler

```csharp
public sealed class BlazorProgressHandler : IProgress<ProgressUpdate>
{
    private readonly AppViewModel _viewModel;

    public void Report(ProgressUpdate value)
    {
        // SynchronizationContext handles UI thread marshaling
        _viewModel.CurrentProgress = value;
        _viewModel.NotifyStateChanged();
    }
}
```

### CliProgressHandler

Wraps the existing `ConsoleProgressService` logic — animated spinner, percentage, elapsed time, batch context. No behavioral changes to CLI output.

---

## 8. First-Run State Handling

### On Launch

1. `AppViewModel.InitializeAsync()` runs `IValidationService.ValidateAsync()`
2. If all checks pass → state = `Ready`
3. If any check fails → state = `NotReady`, show checklist

### NotReady Checklist

Each `ValidationCheck` maps to a UI row:

| Check Status | Visual | Action Button |
|-------------|--------|---------------|
| Passed | Green checkmark | None |
| Warning | Yellow warning | None (informational) |
| Failed (ffmpeg) | Red X | "Install ffmpeg" link to homebrew/website |
| Failed (model) | Red X | "Download Model" button (triggers `IModelService`) |
| Failed (directory) | Red X | "Create Directory" or "Choose Directory" |
| Skipped | Gray dash | None |

The "Retry Validation" button at the bottom re-runs `IValidationService.ValidateAsync()`.

### Model Download

When the user clicks "Download Model" in the NotReady checklist:

1. `IModelService.CreateFactoryAsync()` is called (this downloads if missing)
2. Progress reported via `IProgress<ProgressUpdate>` with `Stage = LoadingModel`
3. On success, re-validate to transition to Ready
4. On failure, show error in the checklist row

---

## 9. Settings Management

### SettingsViewModel

Exposes the key settings for the visual editor:

```csharp
public class SettingsViewModel : INotifyPropertyChanged
{
    public string ModelType { get; set; }          // dropdown: Tiny, Base, Small, Medium, Large
    public string Language { get; set; }            // dropdown from supported languages
    public string OutputDirectory { get; set; }     // directory picker
    public string FfmpegPath { get; set; }          // file picker
    public string ConfigFilePath { get; }           // read-only display

    public Task SaveAsync();                        // writes to appsettings.json
    public void OpenConfigInEditor();               // opens JSON in default editor
}
```

### Configuration File Location (Desktop)

The `.app` bundle is read-only (code signing + Hardened Runtime). The desktop app uses a layered config approach:

- **Bundled defaults:** `appsettings.json` inside the `.app` bundle (read-only)
- **User overrides:** `~/Library/Application Support/VoxFlow/appsettings.json` (writable)
- **Resolution:** User overrides merge on top of bundled defaults (standard .NET configuration layering)

`IConfigurationService.LoadAsync()` handles this layering internally. The CLI continues using its existing config resolution (`TRANSCRIPTION_SETTINGS_PATH` or local `appsettings.json`).

### Save Behavior

When the user clicks "Save":
1. Read current user override file (or create if missing)
2. Update only the changed fields
3. Write to `~/Library/Application Support/VoxFlow/appsettings.json`
4. Re-load `TranscriptionOptions` via `IConfigurationService`
5. Re-validate environment (settings change may affect validation)

---

## 10. Document Updates Required (Task 1)

### PRD.md Updates

| Section | Change |
|---------|--------|
| Purpose | Add desktop app as a product surface alongside CLI and MCP |
| Product Goals | Add: "Provide a macOS desktop app for visual transcription workflow" |
| Non-Goals | Remove: "Web or desktop UI" — desktop is now a goal |
| Non-Goals | Add: "Linux/Windows desktop support in Phase 1" |
| External Contract | Add: desktop app as an input surface (file picker, drag-and-drop) |
| Functional Requirements | Add: FR13 Desktop App (state machine, first-run UX, settings) |
| Functional Requirements | Add: FR14 First-Run Bootstrap (dependency check, model download) |
| Testing Requirements | Add: desktop smoke tests |
| Engineering Requirements | Add: shared core library requirement, DI architecture |
| MCP Server section | Update: remove InternalsVisibleTo reference, note direct Core interface injection |

### Architecture Document Updates

**01-system-context.md:**
- Add VoxFlow Desktop as a third actor/container
- Update trust boundaries diagram to show Desktop
- Update data flow table

**02-container-view.md:**
- Add VoxFlow.Desktop container
- Add VoxFlow.Core as the shared library
- Remove "Why Static Services" section — replaced with DI
- Remove "Application Facades" section — replaced with Core interfaces
- Update module boundary rules for new architecture

**03-component-view.md:**
- Restructure around Core interfaces
- Add Desktop components (AppViewModel, Blazor pages)
- Remove facade components
- Add DI registration component

**04-runtime-sequences.md:**
- Add Desktop single-file transcription sequence
- Update CLI sequence to show DI service calls
- Update MCP sequence to show direct Core interface calls (no facades)
- Add first-run/validation sequence for Desktop

**05-quality-attributes.md:**
- Update Maintainability — interfaces + DI replace static services
- Update Testability — mock-friendly interfaces
- Update "Deliberate Simplicity" trade-off matrix — static→DI is now justified by three hosts
- Add Desktop-specific quality attributes (responsive UI, state machine correctness)

**06-decision-log.md:**
- Add ADR-019: Extract shared VoxFlow.Core library with DI
- Add ADR-020: Use IProgress<T> for host-agnostic progress reporting
- Add ADR-021: Blazor Hybrid for macOS desktop UI
- Add ADR-022: Contextual flow navigation for desktop
- Add ADR-023: Eliminate InternalsVisibleTo in favor of shared library
- Update ADR-001 status: Superseded by ADR-019 (no longer console-only)
- Update ADR-016 status: Superseded by ADR-023 (facades eliminated)

**07-architecture-review.md:**
- Update executive summary for multi-host architecture
- Update "Deliberate Simplicity" section — DI is now justified
- Update evolution table — "Third host" trigger has been activated

### ROADMAP.md Updates

- Update Phase 1 status to reflect active implementation
- Update Phase 1 technology decisions (Blazor Hybrid confirmed, contextual flow UI)

---

## 11. Test Strategy

### VoxFlow.Core.Tests

All existing unit tests migrate here. Tests now use interfaces where appropriate:

| Test Area | What Changes |
|-----------|-------------|
| TranscriptionOptions tests | No change — pure config loading |
| TranscriptionFilter tests | No change — pure function |
| WavAudioLoader tests | No change — pure parsing |
| StartupValidation tests | Test via `IValidationService` interface |
| LanguageSelection tests | Test via `ILanguageSelectionService` interface |
| OutputWriter tests | No change — `BuildOutputText` remains testable |
| FileDiscovery tests | No change — temp directory tests |
| BatchSummary tests | No change — pure formatting |
| NEW: TranscriptionService tests | Integration test for full pipeline via interface |
| NEW: DI registration tests | Verify `AddVoxFlowCore()` resolves all interfaces |

### VoxFlow.Cli.Tests

Existing end-to-end tests migrate here. They test the CLI executable as a process:

| Test | What Changes |
|------|-------------|
| ApplicationEndToEndTests | Updated project reference; same behavior |
| BatchProcessingEndToEndTests | Updated project reference; same behavior |

### VoxFlow.Desktop.Tests

New smoke tests for the desktop app:

| Test | What It Validates |
|------|-------------------|
| App starts | MAUI app initializes without crash |
| Blazor loads | WebView renders root component |
| Validation renders | NotReady view shows check results |
| State transitions | ViewModel state machine: NotReady → Ready → Running → Complete |
| File selection reaches pipeline | File path passed to `ITranscriptionService` |
| Progress renders | `ProgressUpdate` events update UI |
| Complete state shows output | Result view displays transcript preview and path |

### VoxFlow.McpServer.Tests

Existing tests migrate. Updated to use Core interfaces instead of facades:

| Test | What Changes |
|------|-------------|
| PathPolicy tests | No change — PathPolicy stays in MCP |
| McpConfiguration tests | No change |
| ApplicationContract tests | Removed — DTOs are now Core models |
| Facade tests | Removed — facades eliminated |
| NEW: Tool integration tests | Verify tools call Core interfaces correctly |

### TestSupport

Shared utilities remain:
- `FakeFfmpegFactory` — mock ffmpeg
- `TemporaryDirectory` — temp dir lifecycle
- `TestProcessRunner` — process execution
- `TestProjectPaths` — path resolution
- `TestSettingsFileFactory` — generated config
- `TestWaveFileFactory` — generated WAV

---

## 12. Packaging (Phase 1 Scope)

### macOS Build Target

- Target framework: `net9.0-maccatalyst`
- Minimum macOS version: macOS 13.0 (Ventura) — required for .NET 9 MAUI
- Build output: `.app` bundle

### Hardened Runtime

**Decision: Enable Hardened Runtime.** It is required for notarization, which is required for Gatekeeper. Consequences:

- JIT compilation is restricted — .NET's ahead-of-time (AOT) compilation for Mac Catalyst handles this
- Unsigned in-memory code is restricted — Whisper.net loads `libwhisper` as a signed native binary, which is compatible
- `DYLD_*` environment variables are ignored — this does not affect VoxFlow since it does not rely on dynamic library path overrides
- Entitlements needed: `com.apple.security.cs.allow-unsigned-executable-memory` may be required for Whisper.net's native interop; test during build pipeline setup
- If Hardened Runtime proves incompatible with Whisper.net native loading, document the `xattr -cr` workaround and defer notarization to Phase 4 (as Phase 1.md allows)

### Distribution Artifacts

| Artifact | Format | Notes |
|----------|--------|-------|
| Desktop app | `.app` inside `.dmg` | Standard macOS distribution |
| Code signing | Apple Developer ID | Required for Gatekeeper |
| Notarization | `notarytool` + Hardened Runtime | Required for macOS 10.15+ |
| Checksums | SHA-256 | Published with release |

### ffmpeg Decision

**Bundle ffmpeg inside the `.app`.** Rationale:
- Users should not need to install Homebrew or download ffmpeg separately
- The `.app` should be self-contained for first-run success
- ffmpeg binary is ~80MB but acceptable for a desktop app
- The bundled path is set in the app's default configuration
- Users can override with their own ffmpeg via settings

### Model Storage

- Default location: `~/Library/Application Support/VoxFlow/models/`
- Created on first run if missing
- Model downloaded on first run when not present

### Temp/Output Defaults

- Default output: `~/Documents/VoxFlow/`
- Default temp: system temp directory

---

## 13. Out of Scope

Per Phase 1.md:
- Batch desktop UI
- MCP UI/setup/diagnostics in desktop
- Linux/Windows desktop
- New AI workflow features
- Blazor as standalone web app
- Full transcript workspace
