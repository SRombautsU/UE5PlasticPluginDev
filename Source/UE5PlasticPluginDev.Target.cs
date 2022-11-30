// Copyright Unity Technologies. All Rights Reserved.

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
