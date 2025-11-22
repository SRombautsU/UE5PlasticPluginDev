# UEPlasticPlugin - Copilot Instructions

## Project Overview

The **UEPlasticPlugin** (Unity Version Control plugin for Unreal Engine) is the official source control integration plugin for Unreal Engine 5 (UE 5.0 to 5.7), with previous releases also supporting UE4.27. This plugin enables Unity Version Control (formerly Plastic SCM) functionality directly within the Unreal Engine Editor.

### Purpose

The plugin is a complementary tool that improves efficiency in daily workflows with assets in the Editor. It:
- Tracks status of assets, most notably locks
- Brings common source control tasks inside the Editor (updating, branching, merging)
- Provides visual diffing of Blueprints
- Helps import existing Unreal Projects into source control with appropriate `ignore.conf` files
- Is especially useful for tech designers, level designers, and artists since the Unreal Editor manages assets, not C++ source code

The plugin does **not** replace the Desktop Client or command line interface "cm" - it works alongside them to provide Editor integration.

## Architecture

### Module Structure

The plugin follows Unreal Engine's modular architecture:

- **Entry Point**: `FPlasticSourceControlModule` (`PlasticSourceControlModule.cpp/.h`)
  - Implements `IModuleInterface`
  - Registers the provider with the Editor's modular features system
  - Manages lifecycle (StartupModule/ShutdownModule)
  - Provides singleton access to the module

- **Core Provider**: `FPlasticSourceControlProvider` (`PlasticSourceControlProvider.cpp/.h`)
  - Implements `ISourceControlProvider` interface
  - High-level source control interface managing workspace states
  - Coordinates operations and maintains cached file states
  - Handles connection to Unity Version Control server

### Source Control Operations Architecture

The plugin implements Unreal Engine's Source Control API through a worker pattern:

1. **Operation Classes** (`PlasticSourceControlOperations.cpp/.h`)
   - Each operation extends `ISourceControlOperation` or `FSourceControlOperationBase`
   - Examples: `FCheckOut`, `FCheckIn`, `FMarkForAdd`, `FDelete`, `FRevert`, `FSync`, etc.
   - UE5-specific: `FPlasticRevertUnchanged`, `FPlasticSyncAll`, `FPlasticRevertAll`, `FPlasticRevertToRevision`

2. **Worker Classes** (`IPlasticSourceControlWorker.h` + implementations in `PlasticSourceControlOperations.cpp`)
   - Each operation has a corresponding Worker class implementing `IPlasticSourceControlWorker`
   - Workers execute the actual work (can run on background threads)
   - Workers update states after completion (always on main thread)
   - Examples: `FPlasticCheckOutWorker`, `FPlasticCheckInWorker`, `FPlasticMarkForAddWorker`, etc.

3. **Command System** (`PlasticSourceControlCommand.cpp/.h`)
   - `FPlasticSourceControlCommand` implements `IQueuedWork`
   - Describes parameters for each operation
   - Queued and executed by the provider's thread pool

### State Management

- **File States**: `FPlasticSourceControlState` (`PlasticSourceControlState.cpp/.h`)
  - Implements `ISourceControlState`
  - Tracks file status: controlled, checked-out, added, deleted, private, changed, ignored, not-up-to-date
  - Caches state to avoid redundant CLI calls

- **Revisions**: `FPlasticSourceControlRevision` (`PlasticSourceControlRevision.cpp/.h`)
  - Implements `ISourceControlRevision`
  - Represents a specific revision in file history
  - Used for diffing and history views

- **Changelists** (UE5): `FPlasticSourceControlChangelist` and `FPlasticSourceControlChangelistState`
  - Implements `ISourceControlChangelist` and `ISourceControlChangelistState`
  - Groups checked-out files by topic
  - Supports Shelves (temporary storage of changes)

### CLI Integration Layer

The plugin communicates with Unity Version Control through the "cm" command-line interface:

1. **Shell Wrapper** (`PlasticSourceControlShell.cpp/.h`)
   - Low-level wrapper around "cm shell" background process
   - Launches persistent shell process for better performance
   - Handles command execution and output parsing
   - Platform-specific delimiter handling (Windows: `\r\n`, Unix: `\n`)

2. **Utils Layer** (`PlasticSourceControlUtils.cpp/.h`)
   - High-level functions wrapping "cm" operations
   - Dedicated parsers for command outputs (status, history, etc.)
   - Functions for workspace management, branch operations, lock management
   - XML parsing for structured outputs (history, log, status --xml)

### UI Components

- **Settings Window**: `SPlasticSourceControlSettings` (`SPlasticSourceControlSettings.cpp/.h`)
  - Source Control Login window
  - Wizard to create new workspace/repository
  - Configuration UI

- **Menu Extensions**: `PlasticSourceControlMenu` (`PlasticSourceControlMenu.cpp/.h`)
  - Extends main source control menu in status bar
  - Adds Unity Version Control-specific commands

- **Dockable Windows**:
  - `PlasticSourceControlBranchesWindow` - Branch management UI
  - `PlasticSourceControlChangesetsWindow` - Changeset history UI
  - `PlasticSourceControlLocksWindow` - Smart Locks management UI

- **Status Bar**: `SPlasticSourceControlStatusBar` - Shows current branch and changeset

## Implemented APIs

The plugin implements the following Unreal Engine Source Control operations:

### Core Operations
- **Connect** (`FPlasticConnectWorker`) - Connect to Unity Version Control server
- **UpdateStatus** (`FPlasticUpdateStatusWorker`) - Refresh file status
- **CheckOut** (`FPlasticCheckOutWorker`) - Check out files for exclusive editing
- **CheckIn** (`FPlasticCheckInWorker`) - Submit changes with commit message
- **MarkForAdd** (`FPlasticMarkForAddWorker`) - Add new files to source control
- **Delete** (`FPlasticDeleteWorker`) - Delete files from source control
- **Revert** (`FPlasticRevertWorker`) - Revert local changes
- **Sync** (`FPlasticSyncWorker`) - Update workspace to latest
- **GetFile** (`FPlasticGetFileWorker`) - Retrieve specific file revision

### Advanced Operations
- **RevertUnchanged** (`FPlasticRevertUnchangedWorker`) - Revert checked-out unchanged files
- **RevertAll** (`FPlasticRevertAllWorker`) - Revert all local changes
- **RevertToRevision** (`FPlasticRevertToRevisionWorker`) - Revert files to specific changeset
- **Resolve** (`FPlasticResolveWorker`) - Resolve merge conflicts
- **Copy** (`FPlasticCopyWorker`) - Migrate assets between projects

### Branch Operations
- **GetBranches** (`FPlasticGetBranchesWorker`) - List branches
- **Switch** (`FPlasticSwitchWorker`) - Switch workspace to branch/changeset
- **MergeBranch** (`FPlasticMergeBranchWorker`) - Merge branch into current
- **CreateBranch** (`FPlasticCreateBranchWorker`) - Create new branch
- **RenameBranch** (`FPlasticRenameBranchWorker`) - Rename branch
- **DeleteBranches** (`FPlasticDeleteBranchesWorker`) - Delete branches

### Lock Operations
- **GetLocks** (`FPlasticGetLocksWorker`) - List Smart Locks
- **Unlock** (`FPlasticUnlockWorker`) - Release/remove locks

### Changeset Operations
- **GetChangesets** (`FPlasticGetChangesetsWorker`) - List changesets
- **GetChangesetFiles** (`FPlasticGetChangesetFilesWorker`) - Get files in changeset

### Changelist Operations (UE5)
- **GetPendingChangelists** (`FPlasticGetPendingChangelistsWorker`) - List pending changelists
- **NewChangelist** (`FPlasticNewChangelistWorker`) - Create changelist
- **DeleteChangelist** (`FPlasticDeleteChangelistWorker`) - Delete changelist
- **EditChangelist** (`FPlasticEditChangelistWorker`) - Edit changelist description
- **Reopen** (`FPlasticReopenWorker`) - Move files between changelists
- **Shelve** (`FPlasticShelveWorker`) - Shelve changes
- **Unshelve** (`FPlasticUnshelveWorker`) - Unshelve changes
- **DeleteShelve** (`FPlasticDeleteShelveWorker`) - Delete shelve
- **GetChangelistDetails** (`FPlasticGetChangelistDetailsWorker`) - Get changelist details

### Workspace Operations
- **MakeWorkspace** (`FPlasticMakeWorkspaceWorker`) - Create new workspace/repository
- **SwitchToPartialWorkspace** (`FPlasticSwitchToPartialWorkspaceWorker`) - Switch to Gluon mode
- **GetProjects** (`FPlasticGetProjectsWorker`) - List Unity organization projects

## Unity Version Control "cm" CLI

The plugin relies on the Unity Version Control Command Line Interface tool "cm" (formerly Plastic SCM CLI). This is a critical dependency.

### CLI Location

- Default location: `C:\Program Files\PlasticSCM5\client\cm.exe` (Windows)
- The plugin searches for "cm" in the system PATH
- Can be configured via `BinaryPath` setting in Source Control Settings

### Key CLI Commands Used

The plugin uses various "cm" commands:

- `cm status` - Get file status (with `--xml` for structured output)
- `cm checkout` - Check out files for editing
- `cm checkin` - Submit changes
- `cm add` - Add files to source control
- `cm remove` - Remove files
- `cm revert` - Revert changes
- `cm update` - Sync workspace
- `cm cat` - Retrieve file content
- `cm history` / `cm log` - Get file history (XML output)
- `cm branch` - Branch operations (create, rename, delete)
- `cm switch` - Switch workspace to branch/changeset
- `cm merge` - Merge branches
- `cm lock list` - List Smart Locks
- `cm lock release` / `cm lock remove` - Manage locks
- `cm find` - Query changesets, branches, shelves
- `cm shell` - Persistent shell mode (used for performance)

### CLI Output Parsing

The plugin parses CLI output in two ways:
1. **Text parsing** - For simple commands (status, checkout, etc.)
2. **XML parsing** - For structured data (history, log, status --xml, changelists)

Parsers are implemented in `PlasticSourceControlParsers.cpp`.

### Performance Optimization

- Uses `cm shell` mode for better performance (persistent process)
- Caches file states to avoid redundant status calls
- Batches operations when possible (especially for One File Per Actor in UE5)
- Warms up shell with preliminary status command

## Building the Plugin

### Prerequisites

- Unreal Engine 5.0 to 5.7 (or UE4.27 for older versions)
- Visual Studio 2019 or 2022 with C++ language support (Community Edition is fine)
- Unity Version Control CLI ("cm") installed and in PATH

**Before building:** Ensure `Source\UE5PlasticPluginDevEditor.Target.cs` has the correct settings uncommented for your UE version (see [Build Configuration](#build-configuration) section).

### Generating Visual Studio Solution Files

**IMPORTANT:** Before generating project files, ensure the Target.cs file has the correct settings for your UE version (see [Build Configuration](#build-configuration) section below).

The project includes a batch script to generate Visual Studio project files:

**Using GenerateProjectFiles.bat:**
```batch
GenerateProjectFiles.bat [ENGINE_VERSION]
```

- Defaults to UE 5.7 if no version specified
- Can specify version: `GenerateProjectFiles.bat 5.6`
- For source builds: `GenerateProjectFiles.bat S` (uses `C:\Workspace\UnrealEngine`)

**Manual method:**
1. **Check Target.cs configuration** - Ensure `IncludeOrderVersion`, `WindowsPlatform.bStrictConformanceMode`, and `CppStandard` are set correctly for your UE version
2. Right-click on the `.uproject` file
3. Select "Generate Visual Studio project files"
4. Or use UnrealBuildTool directly:
   ```batch
   "C:\Program Files\Epic Games\UE_5.7\Engine\Build\BatchFiles\Build.bat" -ProjectFiles "UE5PlasticPluginDev.uproject" -game -Rocket -progress
   ```

### Building the Plugin

**Using Build.bat:**
```batch
Build.bat [ENGINE_VERSION]
```

- Defaults to UE 5.7
- Builds in "Development Editor" configuration
- Output DLLs: `Plugins\UEPlasticPlugin\Binaries\Win64\UnrealEditor-PlasticSourceControl.dll`

**Manual method:**
1. Open the generated `.sln` file in Visual Studio
2. Set configuration to "Development Editor"
3. Build Solution (F7)
4. The plugin will be built automatically when building the project

**For Blueprint-only projects:**
1. Convert to C++ project (add C++ class via Editor)
2. Or manually add the plugin source to a C++ project
3. Generate project files
4. Build

### Build Configuration

#### Plugin Build Configuration (`PlasticSourceControl.Build.cs`)

The plugin's build rules are defined in `Plugins\UEPlasticPlugin\Source\PlasticSourceControl\PlasticSourceControl.Build.cs`:

**Include What You Use (IWYU) Configuration:**
- **UE 5.2 and earlier**: Uses `bEnforceIWYU = true;` (deprecated)
- **UE 5.2 and later**: Must use `IWYUSupport = IWYUSupport.Full;` instead
- The current configuration uses the newer `IWYUSupport` setting

**Current configuration:**
```csharp
PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
IWYUSupport = IWYUSupport.Full;  // Required for UE 5.2+
```

**Dependencies:**
- Core, CoreUObject, Engine, Slate, SlateCore, InputCore
- EditorStyle, UnrealEd, LevelEditor, DesktopPlatform
- SourceControl, SourceControlWindows
- XmlParser, Projects, AssetRegistry, DeveloperSettings
- ToolMenus, ContentBrowser

#### Project Target Configuration (`UE5PlasticPluginDevEditor.Target.cs`)

The project's target rules are defined in `Source\UE5PlasticPluginDevEditor.Target.cs`. **Important:** Certain settings must be enabled for recent Unreal Engine versions:

**UE 5.1+ Requirements:**
```csharp
IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
// or for specific version:
// IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_7;
```
- **Required starting from UE 5.1**
- Controls include file ordering to match Engine changes
- Set to `Latest` to always use the newest include order (may cause compile errors when upgrading Engine)
- Set to specific version (e.g., `Unreal5_7`) for stability

**UE 5.4+ Requirements:**
```csharp
WindowsPlatform.bStrictConformanceMode = true;
```
- **Required starting from UE 5.4**
- Enables strict C++ conformance mode on Windows
- Must be uncommented/enabled for UE 5.4 and later

**UE 5.5+ Requirements:**
```csharp
CppStandard = CppStandardVersion.Cpp20;
```
- **Required starting from UE 5.5**
- Sets C++ standard to C++20
- Required if not using Unity Builds
- Must be uncommented/enabled for UE 5.5 and later

**Unity Build Configuration:**
```csharp
bUseUnityBuild = true;  // Default: true
```
- Set to `false` to compile each `.cpp` file individually (useful for testing IWYU)
- **WARNING:** Don't disable on Unreal Engine source builds, as it will trigger a full Engine rebuild

**When setting up for a new UE version:**
1. Check the Target.cs file for commented-out version-specific requirements
2. Uncomment the appropriate settings for your UE version:
   - UE 5.1+: `IncludeOrderVersion`
   - UE 5.4+: `WindowsPlatform.bStrictConformanceMode`
   - UE 5.5+: `CppStandard`
3. Regenerate project files after making changes
4. Build and fix any compilation errors

### Output Location

Built binaries are located in:
- `Plugins\UEPlasticPlugin\Binaries\Win64\UnrealEditor-PlasticSourceControl.dll`
- `Plugins\UEPlasticPlugin\Binaries\Win64\UnrealEditor-PlasticSourceControl.pdb` (debug symbols)

## Development Workflow

1. **Make code changes** in `Plugins\UEPlasticPlugin\Source\PlasticSourceControl\Private\`
2. **Regenerate project files** if needed (when adding new files)
3. **Build** the plugin (either via Build.bat or Visual Studio)
4. **Restart Unreal Editor** to load the updated plugin
5. **Test** functionality in the Editor

## Key Files Reference

- `PlasticSourceControlModule.cpp/.h` - Module entry point
- `PlasticSourceControlProvider.cpp/.h` - Main provider implementation
- `PlasticSourceControlOperations.cpp/.h` - All operation and worker classes
- `PlasticSourceControlUtils.cpp/.h` - High-level CLI wrappers and parsers
- `PlasticSourceControlShell.cpp/.h` - Low-level CLI shell wrapper
- `PlasticSourceControlState.cpp/.h` - File state management
- `PlasticSourceControlParsers.cpp/.h` - CLI output parsers
- `PlasticSourceControl.Build.cs` - Build configuration

## Additional Notes

- The plugin follows [Unreal Engine C++ Coding Standard](https://dev.epicgames.com/documentation/en-us/unreal-engine/epic-cplusplus-coding-standard-for-unreal-engine)
- All source code is in `Plugins\UEPlasticPlugin\Source\PlasticSourceControl\Private\`
- The plugin supports both full and partial (Gluon) workspaces
- Smart Locks extend across all branches
- The plugin provides visual diffing for Blueprints using Unreal's built-in diff tools
- Console commands are available via `PlasticSourceControlConsole` to run "cm" commands directly

