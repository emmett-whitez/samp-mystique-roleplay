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

        new String:str_query_update = str_format(
            "UPDATE characters SET char_wl = '%d' WHERE char_id = '%d'",
            GetPlayerWantedLevel(playerid), Account_GetCharID(playerid)
        );
        mysql_tquery_s(MySQL_GetHandle(), str_query_update);
    }
    return 1;
}

ptask WL_DecreaseLevel[2 * 60 * 1000](playerid) // 2sec * 60sec = 120sec(2min) * 1000 => 120.000ms
{
    if (!GetPlayerWantedLevel(playerid))
    {
        SetPlayerColor(playerid, 0xFFFFFFAA);
        new String:str_query_update = str_format("UPDATE characters SET char_wl = '0' WHERE char_id = '%d'",
            Account_GetCharID(playerid)
        );
        mysql_tquery_s(MySQL_GetHandle(), str_query_update);
        return 1;
    }

    SetPlayerWantedLevel(playerid, (GetPlayerWantedLevel(playerid) - 1));
    SendCustomMsgF(playerid, X11_RED, "[WANTED]: "WHITE"Trenutni wanted level: %d", GetPlayerWantedLevel(playerid));
    return 1;
}