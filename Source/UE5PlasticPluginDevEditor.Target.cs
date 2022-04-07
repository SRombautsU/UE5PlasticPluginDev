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
	}
}
