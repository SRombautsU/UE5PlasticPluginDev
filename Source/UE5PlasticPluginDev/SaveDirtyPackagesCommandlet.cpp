// Copyright Unity Technologies. All Rights Reserved.

#include "SaveDirtyPackagesCommandlet.h"

#if WITH_EDITOR
#include "Editor/UnrealEd/Public/FileHelpers.h"
#include "SourceControl/Public/ISourceControlModule.h"
#include "SourceControl/Public/SourceControlHelpers.h"

DEFINE_LOG_CATEGORY_STATIC(LogSaveDirtyPackagesCommandlet, Log, All);
#endif

USaveDirtyPackagesCommandlet::USaveDirtyPackagesCommandlet()
{
	IsClient = false;
	IsEditor = true;
	IsServer = false;
	LogToConsole = true;
}

int32 USaveDirtyPackagesCommandlet::Main(const FString& Params)
{
	int32 ReturnCode = 0;
#if WITH_EDITOR
	TArray<FString> Tokens;
	TArray<FString> Switches;
	TMap<FString, FString> ParamVals;
	ParseCommandLine(*Params, Tokens, Switches, ParamVals);

	TArray<UPackage*> PackagesToSave;
	FEditorFileUtils::GetDirtyContentPackages(PackagesToSave);

	if (PackagesToSave.Num() > 0)
	{
		ISourceControlModule::Get().GetProvider().Init();

		if (USourceControlHelpers::IsEnabled())
		{
			TArray<FString> packageFilenames = USourceControlHelpers::PackageFilenames(PackagesToSave);

			for (const FString& filename : packageFilenames)
			{
				// NOTE: CheckOutOrAddFiles() for multiple files at once would be faster but is is bugged in UE5.0
				if (!USourceControlHelpers::CheckOutOrAddFile(filename))
				{
					UE_LOG(LogSaveDirtyPackagesCommandlet, Error, TEXT("Cannot checkout %s"), *filename);
				}
			}

			// Need the files to be writable
			FEditorFileUtils::SaveDirtyPackages(false, false, true, true);

			const FString CommandletCommitMessage = TEXT("Saved dirty packages");
			if (!USourceControlHelpers::CheckInFiles(packageFilenames, CommandletCommitMessage))
			{
				UE_LOG(LogSaveDirtyPackagesCommandlet, Error, TEXT("Cannot checkin"));
			}
		}
	}
	else
	{
		UE_LOG(LogSaveDirtyPackagesCommandlet, Display, TEXT("No asset to save."));
	}
#endif

	return ReturnCode;
}
