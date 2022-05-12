// Copyright (c) 2016-2022 Codice Software

using UnrealBuildTool;

public class UE5PlasticPluginDev : ModuleRules
{
	public UE5PlasticPluginDev(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[]
			{
				"Core", "CoreUObject", "Engine", "InputCore",
				"UnrealEd",
				"SourceControl",
			}
		);
	}
}
