// Copyright (c) 2016-2022 Codice Software

using UnrealBuildTool;
using System.Collections.Generic;

public class UE5PlasticPluginDevTarget : TargetRules
{
	public UE5PlasticPluginDevTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.V2;
		ExtraModuleNames.Add("UE5PlasticPluginDev");
	}
}
