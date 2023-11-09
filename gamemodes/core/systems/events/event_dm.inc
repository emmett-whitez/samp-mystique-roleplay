#if defined _INC_event_dm_inc
	#endinput
#endif
#define _INC_event_dm_inc

/*
TODO:
1. Promeniti koordinate spawna
2. Napraviti OnPlayerDeath kada igrac ubije igraca u eventu da mu se poveca playerDMKills i
   na 5 killova da dobije full armor a na 10 killova dobije $5000 i resetuje mu se playerDMKills
*/

#include <YSI_Coding\y_hooks>

static
 	playerCountDMEvent,
	playerDMKills[MAX_PLAYERS],
	bool:playerInDMEvent[MAX_PLAYERS],
	bool:dmEventStarted,
	Float:playerCurrentHealth[MAX_PLAYERS],
	Float:playerCurrentArmour[MAX_PLAYERS],
	Float:playerPosX[MAX_PLAYERS],
	Float:playerPosY[MAX_PLAYERS],
	Float:playerPosZ[MAX_PLAYERS];

new Float:dmEventSpawns[][] =
{
	{288.745971,169.350997,1007.171875, 0.00}
};

hook OnPlayerSpawn(playerid)
{
	if (playerInDMEvent[playerid])
	{
		new rand = random(sizeof(dmEventSpawns));
		SetPlayerInterior(playerid, 3);
		SetPlayerPos(playerid, dmEventSpawns[rand][0], dmEventSpawns[rand][1], dmEventSpawns[rand][2]);
		SetPlayerFacingAngle(playerid, dmEventSpawns[rand][3]);
		
		SetPlayerHealth(playerid, 99.00);
		SetPlayerArmour(playerid, 99.00);

	    ResetPlayerWeapons(playerid);
		GivePlayerWeapon(playerid, 4, 1);
		GivePlayerWeapon(playerid, 24, 999);
		GivePlayerWeapon(playerid, 31, 999);
		GivePlayerWeapon(playerid, 33, 999);
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	if (playerInDMEvent[killerid])
	{
		if (playerDMKills[killerid] == 10)
			playerDMKills[killerid] = 0;

		playerDMKills[killerid]++;

		if (playerDMKills[killerid] == 5)
			SetPlayerArmour(killerid, 99.00);
		else if (playerDMKills[killerid] == 10)
		{
			Account_SetMoney(killerid, (Account_GetMoney(killerid) + 5000));
			GivePlayerMoney(killerid, 5000);
		}

	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

// Command(name: dmevent, rank: Rank_Administrator(), args: playerid, const string: params[])
YCMD:dmevent(const playerid, const params[], help)
{
	if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
		return Rank_InsufficientMsg(playerid);

	if (dmEventStarted)
		return SendErrorMsg(playerid, "Event je vec pokrenut!");

	SendClientMessageToAll(X11_RED, "==============================================================");
	SendClientMessageToAll(X11_RED, "[DM Event]: "WHITE"DM Event je pokrenut, da se pridruzite kucajte "RED"/joindmevent"WHITE"!");
	SendClientMessageToAll(X11_RED, "==============================================================");

	dmEventStarted = true;
	playerCountDMEvent = 0;
	return COMMAND_OK;
}

// Command(name: stopdmevent, rank: Rank_Administrator(), args: playerid, const string: params[])
YCMD:stopdmevent(const playerid, const params[], help)
{
	if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
		return Rank_InsufficientMsg(playerid);

	if (!dmEventStarted)
		return SendErrorMsg(playerid, "Event nije pokrenut!");

	SendClientMessageToAll(X11_RED, "==============================================================");
	SendClientMessageToAll(X11_RED, "[DM Event]: "WHITE"DM Event je "RED"zaustavljen"WHITE"!");
	SendClientMessageToAll(X11_RED, "==============================================================");

	dmEventStarted = false;
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (playerInDMEvent[i])
		{
		    playerInDMEvent[i] = false;
			playerDMKills[i] = 0;

			SetPlayerPos(i, playerPosX[i], playerPosY[i], playerPosZ[i]);
			SetPlayerHealth(i, playerCurrentHealth[i]);
			SetPlayerArmour(i, playerCurrentArmour[i]);
			SetPlayerInterior(i, 0);
			ResetPlayerWeapons(i);
		}
	}
    return COMMAND_OK;
}

YCMD:joindmevent(const playerid, const params[], help)
{
	if (!dmEventStarted)
		return SendErrorMsg(playerid, "Event nije pokrenut!");
		
    if (IsPlayerInAnyVehicle(playerid))
		return SendErrorMsg(playerid, "Morate izaci iz vozila da biste usli na event!");

	if (playerInDMEvent[playerid])
		return SendErrorMsg(playerid, "Vec ste usli na event!");

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerHealth(playerid, playerCurrentHealth[playerid]);
	GetPlayerArmour(playerid, playerCurrentArmour[playerid]);

	playerPosX[playerid] = x;
	playerPosY[playerid] = y;
	playerPosZ[playerid] = z;

	new rand = random(sizeof(dmEventSpawns));
	SetPlayerInterior(playerid, 3);
	SetPlayerPos(playerid, dmEventSpawns[rand][0], dmEventSpawns[rand][1], dmEventSpawns[rand][2]);
	SetPlayerFacingAngle(playerid, dmEventSpawns[rand][3]);

	SetPlayerHealth(playerid, 99.00);
	SetPlayerArmour(playerid, 99.00);

    ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 4, 1);
	GivePlayerWeapon(playerid, 24, 999);
	GivePlayerWeapon(playerid, 31, 999);
	GivePlayerWeapon(playerid, 33, 999);

	SendClientMessage(playerid, X11_RED, "[DM Event]: "WHITE"Da napustite event kucajte "RED"/leavedmevent"WHITE"!");
	SendClientMessage(playerid, X11_RED, "* Na 5 killova dobijate full armour, na 10 killova dobijate $5.000!");
	SendClientMessage(playerid, X11_RED, "* Nakon 10 killova kill score Vam se resetuje na 0!");

	GameTextForPlayer(playerid, "~y~USLI STE NA DM EVENT!", 3000, 3);

	playerInDMEvent[playerid] = true;
	playerCountDMEvent++;
    return COMMAND_OK;
}

YCMD:leavedmevent(const playerid, const params[], help)
{
	if (!dmEventStarted)
		return SendErrorMsg(playerid, "Event nije pokrenut!");

	if (!playerInDMEvent[playerid])
		return SendErrorMsg(playerid, "Niste usli na event!");

	SetPlayerPos(playerid, playerPosX[playerid], playerPosY[playerid], playerPosZ[playerid]);
	SetPlayerHealth(playerid, playerCurrentHealth[playerid]);
	SetPlayerArmour(playerid, playerCurrentArmour[playerid]);
	SetPlayerInterior(playerid, 0);
	ResetPlayerWeapons(playerid);

	SendClientMessage(playerid, X11_RED, "* Napustili ste event.");

	playerInDMEvent[playerid] = false;
	playerDMKills[playerid] = 0;
	playerCountDMEvent--;
	return COMMAND_OK;
}