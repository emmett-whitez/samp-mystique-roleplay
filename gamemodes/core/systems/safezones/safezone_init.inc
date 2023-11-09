#if defined _INC_safezone_init_inc
	#endinput
#endif
#define _INC_safezone_init_inc

#include <YSI_Coding\y_hooks>

const MAX_SAFE_ZONES = 5;
static
	safeZoneID[MAX_SAFE_ZONES],
	safeZonePlayerVulnerable[MAX_PLAYERS],
	Float:safeZonePlayerOldHealth[MAX_PLAYERS],
	PlayerText:safeZonePlayerTD[MAX_PLAYERS];

static Float:safeZonePos[][][] =
{
	{1031.4168, -1793.3646, 1187.4168, -1704.3646},
	{1399.3821, -1820.3438, 1544.3821, -1584.3438}
};

hook OnGameModeInit()
{
	for (new i = 0; i < 2; i++)
		safeZoneID[i] = GangZoneCreate(safeZonePos[i][0][0], safeZonePos[i][1][0], safeZonePos[i][2][0], safeZonePos[i][3][0]);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerConnect(playerid)
{
	safeZonePlayerTD[playerid] = CreatePlayerTextDraw(playerid, 551.000000, 167.566528, "SAFE ZONE");
	PlayerTextDrawLetterSize(playerid, safeZonePlayerTD[playerid], 0.188999, 0.859555);
	PlayerTextDrawTextSize(playerid, safeZonePlayerTD[playerid], 0.000000, 239.000000);
	PlayerTextDrawAlignment(playerid, safeZonePlayerTD[playerid], 2);
	PlayerTextDrawColor(playerid, safeZonePlayerTD[playerid], 1943630335);
	PlayerTextDrawSetShadow(playerid, safeZonePlayerTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, safeZonePlayerTD[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, safeZonePlayerTD[playerid], 255);
	PlayerTextDrawFont(playerid, safeZonePlayerTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, safeZonePlayerTD[playerid], 1);

	for (new i = 0; i < MAX_SAFE_ZONES; i++)
		GangZoneShowForPlayer(playerid, safeZoneID[i], X11_LIGHTGREEN);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

// hook OnPlayerSpawn(playerid)
// {
// 	for (new i = 0; i < MAX_SAFE_ZONES; i++)
// 		GangZoneShowForPlayer(playerid, safeZoneID[i], X11_LIGHTGREEN);
// 	return Y_HOOKS_CONTINUE_RETURN_1;
// }

// hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
// {
// 	return Y_HOOKS_CONTINUE_RETURN_1;
// }

// hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
// {
// 	if (safeZonePlayerVulnerable[playerid] || safeZonePlayerVulnerable[issuerid])
// 		SetPlayerHealth(playerid, 999.00);
// 	else if (!safeZonePlayerVulnerable[playerid] && safeZonePlayerVulnerable[issuerid])
// 		SetPlayerHealth(playerid, 999.00);
// 	return Y_HOOKS_CONTINUE_RETURN_1;
// }

stock SafeZone_CoordsCheck(playerid, Float:minx, Float:miny, Float:maxx, Float:maxy)
{
	new Float:Poz[3];
	GetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
	if(Poz[0] > minx && Poz[0] < maxx && Poz[1] > miny && Poz[1] < maxy) return true;
	return false;
}

PTASK__ SafeZone_Check[400](playerid)
{
	if (SafeZone_CoordsCheck(playerid, safeZonePos[0][0][0], safeZonePos[0][1][0], safeZonePos[0][2][0], safeZonePos[0][3][0]))
	{
		GetPlayerHealth(playerid, safeZonePlayerOldHealth[playerid]);
		PlayerTextDrawShow(playerid, safeZonePlayerTD[playerid]);
		safeZonePlayerVulnerable[playerid] = 1;
	}
	else if (SafeZone_CoordsCheck(playerid, safeZonePos[1][0][0], safeZonePos[1][1][0], safeZonePos[1][2][0], safeZonePos[1][3][0]))
	{
		GetPlayerHealth(playerid, safeZonePlayerOldHealth[playerid]);
		PlayerTextDrawShow(playerid, safeZonePlayerTD[playerid]);
		safeZonePlayerVulnerable[playerid] = 1;
	}
	else
	{
		PlayerTextDrawHide(playerid, safeZonePlayerTD[playerid]);
		safeZonePlayerVulnerable[playerid] = 0;
		SetPlayerHealth(playerid, safeZonePlayerOldHealth[playerid]);
	}
}