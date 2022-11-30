// Copyright Unity Technologies. All Rights Reserved.

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
