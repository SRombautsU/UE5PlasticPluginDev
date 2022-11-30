// Copyright Unity Technologies. All Rights Reserved.

#include "UE5PlasticPluginDevGameMode.h"
#include "UE5PlasticPluginDevCharacter.h"
#include "UObject/ConstructorHelpers.h"

AUE5PlasticPluginDevGameMode::AUE5PlasticPluginDevGameMode()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnBPClass(TEXT("/Game/ThirdPerson/Blueprints/BP_ThirdPersonCharacter"));
	if (PlayerPawnBPClass.Class != NULL)
	{
		DefaultPawnClass = PlayerPawnBPClass.Class;
	}
}
