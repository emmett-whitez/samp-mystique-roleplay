#if defined _INC_wanted_init_inc
    #endinput
#endif
#define _INC_wanted_init_inc

#include <YSI_Coding\y_hooks>

stock WantedLevel_Set(const playerid, const level)
{
    if (!(0 <= level <= 6))
        return 0;

    if (Org_GetID(playerid) != 1)
    {
        SetPlayerWantedLevel(playerid, level);
        SetPlayerColor(playerid, 0xc13b3700);

        Account_SetWanted(playerid, level);
    }
    return 1;
}

ptask WL_DecreaseLevel[5 * 60 * 1000](playerid) // 5sec * 60sec = 30sec(5min) * 1000 => 300.000ms
{
    if (!GetPlayerWantedLevel(playerid))
    {
        SetPlayerColor(playerid, 0xFFFFFFAA);
        Account_SetWanted(playerid, 0);
        return 1;
    }

    SetPlayerWantedLevel(playerid, (GetPlayerWantedLevel(playerid) - 1));
    SendCustomMsgF(playerid, X11_RED, "[WANTED]: "WHITE"Trenutni wanted level: %d", GetPlayerWantedLevel(playerid));
    return 1;
}