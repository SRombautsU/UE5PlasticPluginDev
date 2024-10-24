// Copyright Unity Technologies. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class UE5PlasticPluginDevEditorTarget : TargetRules
{
	public UE5PlasticPluginDevEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V2;

		// Required starting from UE 5.4
		WindowsPlatform.bStrictConformanceMode = true;

		ExtraModuleNames.Add("UE5PlasticPluginDev");

		// Uncomment to rebuild the whole project without Unity Build, compiling each cpp source file individually, in order to test Includ Whay You Use (IWYU) policy
		// WARNING: don't uncomment on UnrealEngine Source Build, else you will trigger a full new Engine build (but easy to revert, will just relink 1200 lib/dll)
		bUseUnityBuild = false;
	}
}
