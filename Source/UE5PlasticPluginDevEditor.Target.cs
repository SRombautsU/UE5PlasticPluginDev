// Copyright (c) 2016-2022 Codice Software

using UnrealBuildTool;
using System.Collections.Generic;

public class UE5PlasticPluginDevEditorTarget : TargetRules
{
	public UE5PlasticPluginDevEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V2;
		ExtraModuleNames.Add("UE5PlasticPluginDev");

		// Uncomment to rebuild the whole project without Unity Build, compiling each cpp source file individually, in order to test Includ Whay You Use (IWYU) policy
		// WARNING: don't uncomment on UnrealEngine Source Build, else you will trigger a full new Engine build (but easy to revert, will just relink 1200 lib/dll)
	//	bUseUnityBuild = false;
	}
}
