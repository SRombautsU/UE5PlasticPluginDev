// Copyright (c) 2016-2022 Codice Software

#pragma once

#include "CoreMinimal.h"
#include "Commandlets/Commandlet.h"
#include "SaveDirtyPackagesCommandlet.generated.h"

UCLASS()
class USaveDirtyPackagesCommandlet : public UCommandlet
{
	GENERATED_BODY()
public:

	USaveDirtyPackagesCommandlet();

	// UCommandlet interface
	virtual int32 Main(const FString& Params) override;

private:
	void PrintHelp() const;
};
