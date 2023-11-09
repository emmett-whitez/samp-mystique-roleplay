#if defined _INC_mod_commands_inc
    #endinput
#endif
#define _INC_mod_commands_inc

// static wlTimer[MAX_PLAYERS];

// forward Timer_RemoveWLBug(const playerid);
// public Timer_RemoveWLBug(const playerid)
// {
// 	WantedLevel_Set(playerid, 0);
// 	return 1;
// }

forward Timer_KickPlayer(const playerid);
public Timer_KickPlayer(const playerid)
{
	Kick(playerid);
	return 1;
}

Command(name: mh, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	Dialog_Show(playerid, "DIALOG_ADMINHELP", DIALOG_STYLE_MSGBOX,
		""DARKGREEN"GENERATIONZ - "WHITE"Moderator komande",
		""DARKGREEN"______________________________________________________\n\n\
		"DARKGREEN"Moderator: "WHITE"/veh /pos /kill /cc /portjelka /kick /vrespawn /portkuca\n\
		"DARKGREEN"Moderator: "WHITE"/portkiosk /jetpack /pm /playmusic /a /givegun /gethere /goto\n\
		"DARKGREEN"Moderator: "WHITE"/setorg /setorgrank /setskin /port /setstats /dmevent /stopdmevent\n\
		"DARKGREEN"______________________________________________________",
		""DARKGREEN"Zatvori"
	);
	return 1;
}

Command(name: pos, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static Float: x, Float: y, Float: z;
	if (sscanf(params, "fff", x, y, z))
		return SendSyntaxMsg(playerid, "/pos [x] [y] [z]");

	Streamer_UpdateEx(playerid, x, y, z, .compensatedtime = 2000);
	return 1;
}

Command(name: kill, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/kill [targetid]");

	if (!IsPlayerConnected(strval(params)))
		return SendErrorMsg(playerid, "Taj korisnik nije prijavljen!");

	SetPlayerHealth(strval(params), 0.0);
	SendServerMsgF(strval(params), "%s Vas je ubio.", ReturnPlayerName(playerid));
	SendServerMsgF(playerid, "Ubili ste %s.", ReturnPlayerName(strval(params)));

	// wlTimer[strval(params)] = SetTimerEx("Timer_RemoveWLBug", 2000, false, "d", strval(params));
	return 1;
}

Command(name: cc, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/cc [lines]");

	if (!(10 <= strval(params) <= 60))
		return SendErrorMsg(playerid, "Ne mozete ispod 10 linija i iznad 60 linija!");

	foreach (new i: Player)
		Player_ClearChat(i, playerid, strval(params));
	return 1;
}

Command(name: setstats, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		option[12],
		value;

	SendClientMessage(playerid, X11_GRAY, "*** Stats opcije ***");
	SendClientMessage(playerid, X11_GRAY, "[score][money][skin][spawn][bankcard][gold][hours][job][orgid][orgrank]");
	SendClientMessage(playerid, X11_GRAY, "[marijuana][wl][jailtime][mobile][mobilenum][mobilecredit][mobilepower]");

	if (sscanf(params, "rs[12]i", targetid, option, value))
		return SendSyntaxMsg(playerid, "/setstats [targetid] [option] [value]");

	if (!strcmp(option, "score", false))
	{
		if (!(1 <= value <= 1000))
			return SendErrorMsg(playerid, "Ne mozete postaviti level ispod 1 i iznad 1000!");

		Account_SetScore(targetid, value);
		SetPlayerScore(targetid, value);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio level %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili level %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "money", false))
	{
		if (!(1 <= value <= 999999999))
			return SendErrorMsg(playerid, "Ne mozete postaviti novac ispod $1 i iznad $999.999.999!");

		Account_SetMoney(targetid, value);
		ResetPlayerMoney(targetid);
		GivePlayerMoney(targetid, value);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio novac na $%d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili novac na $%d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "skin", false))
	{
		if (!(1 <= value <= 311))
			return SendErrorMsg(playerid, "Ne mozete postaviti skin ispod 1 i iznad 311!");

		Account_SetSkin(targetid, value);
		SetPlayerSkin(targetid, value);
		UI_UpdateInfoTD(playerid);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio skin %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili skin %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "spawn", false))
	{
		if (!(1 <= value <= 3))
			return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 1 i iznad 3!");

		Account_SetSpawn(targetid, value);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio spawn na %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili spawn na %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "bankcard", false))
	{
		if (value > 1)
			return SendErrorMsg(playerid, "Ne mozete postaviti bankovni racun ispod 0 i iznad 1!");

		Account_SetBankCard(targetid, value);
		UI_UpdateInfoTD(playerid);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio status bankovnog racuna na %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili status bankovnog racuna na %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "gold", false))
	{
		if (value > 9999)
			return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 9999!");

		Account_SetGold(targetid, value);
		UI_UpdateInfoTD(playerid);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio zlato na %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili zlato na %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "hours", false))
	{
		if (value > 9999999)
			return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 9999999!");

		Account_SetHours(targetid, value);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio sate igre na %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili sate igre na %d. *", ReturnPlayerName(targetid), value);
	}

	else if (!strcmp(option, "job", false))
	{
		if (value > 4)
			return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 4!");

		Account_SetJob(targetid, value);

		SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio posao na %d. *", ReturnPlayerName(playerid), value);
		SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili posao na %d. *", ReturnPlayerName(targetid), value);
	}
	
	else
		return SendErrorMsg(playerid, "Pogresna opcija!");
	return 1;
}

Command(name: kick, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static targetid, reason[MAX_REASON_LENGTH];
	if (sscanf(params, "rs["#MAX_REASON_LENGTH"]", targetid, reason))
		return SendSyntaxMsg(playerid, "/kick [targetid] [reason]");

	if (targetid == _:playerid)
		return SendErrorMsg(playerid, "Ne mozete kikovati sebe!");

	if (Rank_GetID(targetid) == Rank_Moderator() || Rank_GetID(targetid) == Rank_Administrator())
		return SendErrorMsg(playerid, "Ne mozete kikovati moderatora/administratora!");

	SendCustomMsgF(targetid, X11_RED, "(Kick): "WHITE"Kikovani ste od strane %s zbog "RED"%s"WHITE".", ReturnPlayerName(playerid), reason);
	SendCustomMsgF(playerid, X11_RED, "(Kick): "WHITE"Kikovali ste %s zbog "RED"%s"WHITE".", ReturnPlayerName(targetid), reason);
	SetTimerEx("Timer_KickPlayer", 1000, false, "d", targetid);
	return 1;
}

Command(name: vrespawn, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (!IsPlayerInAnyVehicle(playerid))
		return SendErrorMsg(playerid, "Morate biti u vozilu!");

	SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	SendInfoMsg(playerid, "Respawnovali ste vozilo.");
	return 1;
}

Command(name: pm, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		message[MAX_REASON_LENGTH];

	if (sscanf(params, "rs["#MAX_REASON_LENGTH"]", targetid, message))
		return SendSyntaxMsg(playerid, "/pm [targetid] [message]");

	SendCustomMsgF(playerid, X11_CYAN, "#PM: "WHITE"Poslali ste poruku "CYAN"%s "WHITE"koja glasi: "CYAN"%s", ReturnPlayerName(targetid), message);
	SendCustomMsgF(targetid, X11_CYAN, "#PM: "WHITE"Poruka od "CYAN"%s "WHITE"koja glasi: "CYAN"%s", ReturnPlayerName(playerid), message);
	return 1;
}

Command(name: playmusic, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params))
		return SendSyntaxMsg(playerid, "/playmusic [url]");

	if (strfind(params, "http", false))
		return SendErrorMsg(playerid, "Nevazeci URL!");

	foreach (new i: Player)
	{
		PlayAudioStreamForPlayer(i, params);
		SendCustomMsgF(i, X11_LIGHTGREEN, "#Music: "WHITE"%s je pustio pesmu!", ReturnPlayerName(playerid));
	}
	return 1;
}

Command(name: a, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params))
		return SendSyntaxMsg(playerid, "/a [text]");

	if (strlen(params) > 128)
		return SendErrorMsg(playerid, "Predugacak tekst!");

	Rank_StaffMessage(X11_YELLOW, "[A-CHAT]: "LIGHTGRAY"[%s"LIGHTGRAY"] %s(%d): "WHITE"%s",
		Rank_GetID(playerid) == Rank_Moderator() ? ""DARKGREEN"Moderator" : ""YELLOW"Administrator",
		ReturnPlayerName(playerid), playerid, params
	);
	return 1;
}

Command(name: givegun, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		weaponid,
		ammo;

	if (sscanf(params, "rii", targetid, weaponid, ammo))
		return SendSyntaxMsg(playerid, "/givegun [targetid] [weaponid] [ammo]");

	if (Rank_GetID(playerid) != Rank_Administrator())
	{
		switch (weaponid)
		{
			case 9: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 15: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 16: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 17: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 18: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 26: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 35: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 36: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 37: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 38: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 39: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
			case 40: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
		}
	}

	if (!(1 <= ammo <= 999))
		return SendErrorMsg(playerid, "Ne mozete municiju ispod 1 i iznad 999!");

	GivePlayerWeapon(targetid, weaponid, ammo);
	SendCustomMsgF(playerid, X11_GRAY, "#Weapon: "WHITE"Dali ste oruzije %d igracu %s (ammo: %d)", weaponid, ReturnPlayerName(targetid), ammo);
	SendCustomMsgF(targetid, X11_GRAY, "#Weapon: "WHITE"Dobili ste oruzije %d od %s (ammo: %d)", weaponid, ReturnPlayerName(playerid), ammo);
	return 1;
}

Command(name: portkuca, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/portkuca [id]");

	if (!House_Goto(playerid, strval(params)))
		return SendErrorMsg(playerid, "Pogresan ID!");
	House_Goto(playerid, strval(params));
	return 1;
}

Command(name: portkiosk, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/portkiosk [id]");

	if (!Kiosk_Goto(playerid, strval(params)))
		return SendErrorMsg(playerid, "Pogresan ID!");
	Kiosk_Goto(playerid, strval(params));
	return 1;
}

Command(name: goto, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/goto [targetid]");

	if (!IsPlayerConnected(strval(params)))
		return 0;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(strval(params), x, y, z);
	
	if (IsPlayerInAnyVehicle(playerid))
		SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);

	SetPlayerPos(playerid, x, y, z);
	SendCustomMsgF(strval(params), X11_RED, "#GOTO: "WHITE"%s se teleportovao do Vas!", ReturnPlayerName(playerid));
	SendCustomMsgF(playerid, X11_RED, "#GOTO: Teleportovali ste se do "WHITE"%s!", ReturnPlayerName(strval(params)));
	return 1;
}

Command(name: gethere, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	if (isnull(params) && !IsNumeric(params))
		return SendSyntaxMsg(playerid, "/gethere [targetid]");

	if (!IsPlayerConnected(strval(params)))
		return 0;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	
	if (IsPlayerInAnyVehicle(strval(params)))
		SetVehiclePos(GetPlayerVehicleID(strval(params)), x, y, z);

	SetPlayerPos(strval(params), x, y, z);
	SendCustomMsgF(strval(params), X11_RED, "#GET-HERE: "WHITE"%s Vas je teleportovao do sebe!", ReturnPlayerName(playerid));
	SendCustomMsgF(playerid, X11_RED, "#GET-HERE: Teleportovali ste "WHITE"%s do sebe!", ReturnPlayerName(strval(params)));
	return 1;
}

Command(name: setorg, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		orgid;

	if (sscanf(params, "ri", targetid, orgid))
		return SendSyntaxMsg(playerid, "/setorg [targetid] [orgid (/orglist)]");

	if (!(0 <= orgid <= 7))
		return SendErrorMsg(playerid, "Nepostojeca organizacija, (/orglist)!");

	if (!orgid && !Org_GetID(targetid))
		return SendErrorMsg(playerid, "Taj igrac nije u organizaciji!");

	if (!orgid && Org_GetID(targetid))
	{
		SendCustomMsgF(targetid, X11_RED, "(Organizacija): "WHITE"%s Vas je izbacio iz organizacije.", ReturnPlayerName(playerid));
		SendCustomMsgF(playerid, X11_RED, "(Organizacija): "WHITE"Igraca %s ste izbacili iz organizacije.", ReturnPlayerName(targetid));
		Org_SetID(targetid, 0);
		Org_SetRank(targetid, 0);
		Account_SetSkin(targetid, 1);
		return 1;
	}

	if (Org_GetID(targetid) == orgid)
		return SendErrorMsg(playerid, "Taj igrac je vec u toj organizaciji!");

	Org_SetID(targetid, orgid);
	SendCustomMsgF(targetid, X11_LIGHTGREEN, "(Organizacija): "WHITE"%s Vas je ubacio u organizaciju '"LIGHTGREEN"%s"WHITE"'.", ReturnPlayerName(playerid), Org_GetNameByID(orgid));
	SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Organizacija): "WHITE"Ubacili ste %s u organizaciju '"LIGHTGREEN"%s"WHITE"'.", ReturnPlayerName(targetid), Org_GetNameByID(orgid));
	return 1;
}

Command(name: setorgrank, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		rankid;

	if (sscanf(params, "ri", targetid, rankid))
		return SendSyntaxMsg(playerid, "/setorgrank [targetid] [rank (1-5)]");

	if (!Org_GetID(targetid))
		return SendErrorMsg(playerid, "Taj igrac nije u organizaciji!");

	if (!(1 <= rankid <= 5))
		return SendErrorMsg(playerid, "Nepostojeci rank, (1-5)!");

	if (rankid == Org_GetRank(targetid))
		return SendErrorMsg(playerid, "Taj igrac je vec taj rank!");

	Org_SetRank(targetid, rankid);
	SendCustomMsgF(targetid, X11_LIGHTGREEN, "(Organizacija): "WHITE"%s Vam je postavio '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(playerid), rankid);
	SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Organizacija): "WHITE"Igracu %s ste postavili '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(targetid), rankid);
	return 1;
}

Command(name: org, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	SendInfoMsgF(playerid, "org: %d | rank: %d", Org_GetID(playerid), Org_GetRank(playerid));
	return 1;
}

Command(name: setskin, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	static
		targetid,
		skinid;

	if (sscanf(params, "ri", targetid, skinid))
		return SendSyntaxMsg(playerid, "/setskin [targetid] [skinid]");

	if (!(1 <= skinid <= 299))
		return SendErrorMsg(playerid, "Ne mozete skin id ispod 1 i iznad 299!");

	Account_SetSkin(targetid, skinid);
	SendCustomMsgF(playerid, X11_CYAN, "#Skin: "WHITE"Postavili ste igracu %s skin id %d.", ReturnPlayerName(targetid), skinid);
	SendCustomMsgF(targetid, X11_CYAN, "#Skin: "WHITE"%s Vam je postavio skin id %d.", ReturnPlayerName(playerid), skinid);
	return 1;
}

Command(name: port, rank: Rank_Moderator(), args: playerid, const string: params[])
{
	Port_ShowMenu(playerid);
	return 1;
}