#if defined _INC_actor_init_inc
	#endinput
#endif
#define _INC_actor_init_inc

#include <YSI_Coding\y_hooks>

#if defined MAX_ACTORS
	#undef MAX_ACTORS
#endif
const MAX_ACTORS = 100;

#define ACTOR_PATH "/Actors/%d.ini"

enum e_ACTOR_DATA
{
	actorName[MAX_PLAYER_NAME],
	actorSkin,
	actorAnim,
	Float:actorX,
	Float:actorY,
	Float:actorZ,
	Float:actorA
};

static
	ActorData[MAX_ACTORS][e_ACTOR_DATA],
	actorID[MAX_ACTORS];

forward Actor_Load(actorid, const name[], const value[]);
public Actor_Load(actorid, const name[], const value[])
{
	INI_String("actorName", ActorData[actorid][actorName]);
	INI_Int("actorSkin", ActorData[actorid][actorSkin]);
	INI_Int("actorAnim", ActorData[actorid][actorAnim]);
	INI_Float("actorX", ActorData[actorid][actorX]);
	INI_Float("actorY", ActorData[actorid][actorY]);
	INI_Float("actorZ", ActorData[actorid][actorZ]);
	INI_Float("actorA", ActorData[actorid][actorA]);
	return 1;
}

hook OnGameModeInit()
{
    for(new i; i < MAX_ACTORS; i++)
    {
        new actorFile[50];
        format(actorFile, sizeof(actorFile), ACTOR_PATH, i);
        if(fexist(actorFile))
        {
            INI_ParseFile(actorFile, "Actor_Load", .bExtra = true, .extra = i);
            actorID[i] = FCNPC_Create(ActorData[i][actorName]);
            FCNPC_Spawn(actorID[i], ActorData[i][actorSkin], ActorData[i][actorX], ActorData[i][actorY], ActorData[i][actorZ]);
           	FCNPC_SetAngle(actorID[i], ActorData[i][actorA]);
           	switch (ActorData[i][actorAnim])
           	{
           		case 1: FCNPC_ApplyAnimation(actorID[i], "PED", "IDLE_CHAT", 4.0, 1, 0, 0, 0, 0, 1);
           		case 2: FCNPC_ApplyAnimation(actorID[i], "MISC","seat_talk_02", 2.0, 1, 0, 0, 0, 0, 1);
           		case 3: FCNPC_ApplyAnimation(actorID[i], animlib[], animname[], Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1);
           	}
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}