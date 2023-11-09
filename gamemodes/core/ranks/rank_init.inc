#if defined _INC_rank_rework
	#endinput
#endif
#define _INC_rank_rework

#include <YSI_coding\y_hooks>

enum
{
	e_RANK_VIP = 0,
	e_RANK_ADMIN_JUNIOR,
	e_RANK_ADMIN_SENIOR,
	e_RANK_ADMIN_OWNER
};

static
	playerVIP[MAX_PLAYERS],
	playerAdmin[MAX_PLAYERS];

stock Rank_VIP() return e_RANK_VIP;
stock Rank_Junior() return e_RANK_ADMIN_JUNIOR;
stock Rank_Senior() return e_RANK_ADMIN_SENIOR;
stock Rank_Owner() return e_RANK_ADMIN_OWNER;
stock Rank_IsPlayerVIP(const playerid) return playerVIP[playerid];
stock Rank_GetPlayerAdminLevel(const playerid) return playerAdmin[playerid];
stock Rank_InsufficientMsg(const playerid)
	return (SendErrorMsg(playerid, "Nemate odredjeni rank za koriscenje ove komande!"));

stock Rank_SetTempVIP(const playerid, const level) return playerVIP[playerid] = level; 
stock Rank_SetVIP(const playerid, const adminid, const level)
{
	if (Rank_GetPlayerAdminLevel(playerid))
			return SendErrorMsg(adminid, "Taj igrac je administrator!");

	playerVIP[playerid] = level;

	new String:str_query_update = str_format(
		"UPDATE characters SET char_vip = '%d' WHERE char_id = '%d'", level, Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	
	if (level)
	{
		if (Rank_IsPlayerVIP(playerid))
			return SendErrorMsg(adminid, "Taj igrac je vec VIP!");

		SendCustomMsgF(playerid, X11_LIMEGREEN, "[VIP]: "WHITE"Cestitamo! "LIMEGREEN"%s "WHITE"Vam je dodelio rank VIP!", ReturnPlayerName(adminid));
		SendCustomMsgF(adminid, X11_LIMEGREEN, "[VIP]: "WHITE"Igracu "LIMEGREEN"%s "WHITE"ste dodelili rank VIP!", ReturnPlayerName(playerid));
	}

	else
	{
		if (!Rank_IsPlayerVIP(playerid))
			return SendErrorMsg(adminid, "Taj igrac nema rank VIP!");

		SendCustomMsgF(playerid, X11_RED, "[VIP]: "WHITE"Admin "RED"%s "WHITE"Vam je skinuo rank VIP!", ReturnPlayerName(adminid));
		SendCustomMsgF(adminid, X11_RED, "[VIP]: "WHITE"Igracu "RED"%s "WHITE"ste skinuli rank VIP!", ReturnPlayerName(playerid));
	}
	return 1;
}

stock Rank_SetTempAdmin(const playerid, const level) return playerAdmin[playerid] = level;
stock Rank_SetAdminLevel(const playerid, const adminid, const level)
{
	if (Rank_GetPlayerAdminLevel(playerid) == level)
		return SendErrorMsg(adminid, "Taj igrac je vec taj admin level!");

	if (!(0 <= level <= 3))
		return SendErrorMsg(adminid, "Admin level ne moze biti manji od 0 i veci od 3!");

	playerAdmin[playerid] = level;

	new String:str_query_update = str_format(
		"UPDATE characters SET char_admin = '%d' WHERE char_id = '%d'", level, Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);

	if (level)
	{
		SendCustomMsgF(playerid, X11_YELLOW, "[ADMIN]: "WHITE"Cestitamo! "YELLOW"%s "WHITE"Vam je dodelio rank %s!", ReturnPlayerName(adminid), Rank_GetAdminName(level));
		SendCustomMsgF(adminid, X11_YELLOW, "[ADMIN]: "WHITE"Igracu "YELLOW"%s "WHITE"ste dodelili rank %s!", ReturnPlayerName(playerid), Rank_GetAdminName(level));

		Account_SetSkin(playerid, 294);
		UI_UpdateInfoTD(playerid);
	}

	else
	{
		SendCustomMsgF(playerid, X11_RED, "[ADMIN]: "WHITE"Admin "RED"%s "WHITE"Vam je skinuo rank admina!", ReturnPlayerName(adminid));
		SendCustomMsgF(adminid, X11_RED, "[ADMIN]: "WHITE"Igracu "RED"%s "WHITE"ste skinuli rank admina!", ReturnPlayerName(playerid));

		Account_SetSkin(playerid, 1);
		UI_UpdateInfoTD(playerid);
	}
	return 1;
}

stock Rank_GetAdminName(const adminlevel)
{
	static tmpString[16];
	switch (adminlevel)
	{
		case 1: { tmpString = "Junior Admin"; }
		case 2: { tmpString = "Senior Admin"; }
		case 3: { tmpString = "Owner"; }
	}
	return tmpString;
}

stock Rank_AdminMessage(const colour, const string[], va_args<>)
{
	foreach (new i: Player)
		if (Rank_GetPlayerAdminLevel(i) >= Rank_Junior())
			va_SendClientMessage(i, colour, va_return(string, va_start<2>));
	return 0;
}

stock Rank_RadiusMessage(Float: radi, playerid, const string: string[], c1, c2, c3, c4, c5)
{
	if (IsPlayerConnected(playerid))
    {
		new
            Float: pPosX, Float: pPosY, Float: pPosZ,
		    Float: oldpPosX, Float: oldpPosY, Float: oldpPosZ,
		    Float: tmpPosX, Float: tmpPosY, Float: tmpPosZ;

		GetPlayerPos(playerid, oldpPosX, oldpPosY, oldpPosZ);
		foreach(new i: Player)
        {
            if (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
            {
                GetPlayerPos(i, pPosX, pPosY, pPosZ);
                
                tmpPosX = (oldpPosX -pPosX);
                tmpPosY = (oldpPosY -pPosY);
                tmpPosZ = (oldpPosZ -pPosZ);
                
                if(((tmpPosX < radi/16) && (tmpPosX > -radi/16)) && ((tmpPosY < radi/16) && (tmpPosY > -radi/16)) && ((tmpPosZ < radi/16) && (tmpPosZ > -radi/16)))
                    SendClientMessage(i, c1, string);

                else if(((tmpPosX < radi/8) && (tmpPosX > -radi/8)) && ((tmpPosY < radi/8) && (tmpPosY > -radi/8)) && ((tmpPosZ < radi/8) && (tmpPosZ > -radi/8)))
                    SendClientMessage(i, c2, string);

                else if(((tmpPosX < radi/4) && (tmpPosX > -radi/4)) && ((tmpPosY < radi/4) && (tmpPosY > -radi/4)) && ((tmpPosZ < radi/4) && (tmpPosZ > -radi/4)))
                    SendClientMessage(i, c3, string);

                else if(((tmpPosX < radi/2) && (tmpPosX > -radi/2)) && ((tmpPosY < radi/2) && (tmpPosY > -radi/2)) && ((tmpPosZ < radi/2) && (tmpPosZ > -radi/2)))
                    SendClientMessage(i, c4, string);

                else if(((tmpPosX < radi) && (tmpPosX > -radi)) && ((tmpPosY < radi) && (tmpPosY > -radi)) && ((tmpPosZ < radi) && (tmpPosZ > -radi)))
                    SendClientMessage(i, c5, string);
            }
		}
	}
    
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	if (Mobile_IsCallOngoing(playerid))
	{
		new tmpCallString[128];
		format(tmpCallString, sizeof(tmpCallString), "Mobilni: "LIGHTGRAY"%s: "WHITE"%s.", ReturnPlayerName(playerid), text);
		SendCustomMsgF(Mobile_WhoCalled(playerid), X11_YELLOW, tmpCallString);
		format(tmpCallString, sizeof(tmpCallString), "Mobilni: "LIGHTGRAY"%s: "WHITE"%s.", ReturnPlayerName(playerid), text);
		SendCustomMsgF(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), X11_YELLOW, tmpCallString);
		return Y_HOOKS_BREAK_RETURN_0;
	}

    new tmpString[128];
    if (Rank_GetPlayerAdminLevel(playerid) == Rank_Junior())
        format(tmpString, sizeof(tmpString), "{C0C0C0}[%d]"LIGHTGREEN"%s kaze {C0C0C0}[Junior Admin]{FFFFFF} %s", playerid, ReturnPlayerName(playerid), text);
    
    else if (Rank_GetPlayerAdminLevel(playerid) == Rank_Senior())
        format(tmpString, sizeof(tmpString), "{C0C0C0}[%d]"LIGHTGREEN"%s kaze {C0C0C0}[Senior Admin]{FFFFFF} %s", playerid, ReturnPlayerName(playerid), text);

    else if (Rank_GetPlayerAdminLevel(playerid) == Rank_Owner())
        format(tmpString, sizeof(tmpString), "{C0C0C0}[%d]"LIGHTGREEN"%s kaze {C0C0C0}[Owner]{FFFFFF} %s", playerid, ReturnPlayerName(playerid), text);
    else
    	format(tmpString, sizeof(tmpString), "{C0C0C0}[%d]"LIGHTGREEN"%s kaze {C0C0C0}{FFFFFF} %s", playerid, ReturnPlayerName(playerid), text);
    
    Rank_RadiusMessage(20.0, playerid, tmpString, X11_WHITE, X11_WHITE, X11_WHITE, X11_WHITE, X11_WHITE);
    return Y_HOOKS_BREAK_RETURN_0;
}

// Include other module
#include <rank_commands>
#include <player/player_functions>