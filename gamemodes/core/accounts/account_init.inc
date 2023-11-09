#if defined _INC_account_init_inc
    #endinput
#endif
#define _INC_account_init_inc

#include <YSI_Coding\y_hooks>

new accountID[MAX_PLAYERS],
	accountCharID[MAX_PLAYERS],

	accountPassword[MAX_PLAYERS][MAX_PASSWORD_LENGTH],
	accountEmail[MAX_PLAYERS][128];

#define Account_GetID(%0) accountID[%0]
#define Account_GetCharID(%0) accountCharID[%0]
#define Account_GetPassword(%0) accountPassword[%0]

static accountSkin[MAX_PLAYERS],
	accountMoney[MAX_PLAYERS],
	accountScore[MAX_PLAYERS],
	accountGender[MAX_PLAYERS],
	accountCountry[MAX_PLAYERS],
	accountDOB[MAX_PLAYERS][24],
	accountSpawn[MAX_PLAYERS],
	accountBankCard[MAX_PLAYERS],
	accountBankMoney[MAX_PLAYERS],
	accountGold[MAX_PLAYERS],
	accountHours[MAX_PLAYERS],
	accountHouse[MAX_PLAYERS],
	accountExp[MAX_PLAYERS],
	bool:playerSpawned[MAX_PLAYERS],

	// Timers
	spawnTimer[MAX_PLAYERS],
	playerSKTimer[MAX_PLAYERS];

// function with tag result used before definition, forcing reparse
forward bool:Selection_GetUI(const playerid);

forward Float: House_GetPos(const houseid, const index);
forward Float: House_GetIntPos(const houseid, const index);

stock Account_GetSkin(const playerid) return accountSkin[playerid];
stock Account_GetMoney(const playerid) return accountMoney[playerid];
stock Account_GetScore(const playerid) return accountScore[playerid];
stock Account_GetGender(const playerid) return accountGender[playerid];
stock Account_GetCountry(const playerid) return accountCountry[playerid];
stock Account_GetDOB(const playerid) return accountDOB[playerid];
stock Account_GetSpawn(const playerid) return accountSpawn[playerid];
stock Account_GetBankCard(const playerid) return accountBankCard[playerid];
stock Account_GetBankMoney(const playerid) return accountBankMoney[playerid];
stock Account_GetGold(const playerid) return accountGold[playerid];
stock Account_GetHours(const playerid) return accountHours[playerid];
stock Account_GetHouse(const playerid) return accountHouse[playerid];
stock Player_Spawned(const playerid) return playerSpawned[playerid];
stock Account_GetExp(const playerid) return accountExp[playerid];

stock Account_SetPassword(const playerid, const password[])
{
	new Alloc:str_alloc = malloc(16);
	msets(str_alloc, 0, password);
	strcpy(accountPassword[playerid], mget(str_alloc, 0));

	new String: str_query_update = str_format(
		"UPDATE accounts SET account_password = '%e' WHERE account_id = '%d'",
		mget(str_alloc, 0), Account_GetID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	free(str_alloc);
	return 1;
}

stock Account_SetEmail(const playerid, const email[])
{
	strcopy(accountEmail[playerid], email);

	new String: str_query_update = str_format(
		"UPDATE accounts SET account_email = '%e' WHERE account_id = '%d'",
		Account_GetEmail(playerid), Account_GetID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetSkin(const playerid, const skin)
{
	accountSkin[playerid] = skin;
	SetPlayerSkin(playerid, skin);

	new String: str_query_update = str_format(
		"UPDATE characters SET char_skin = '%d' WHERE char_id = '%d'",
		Account_GetSkin(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetExp(const playerid, const value)
{
	accountExp[playerid] = value;
	new String: str_query_update = str_format(
		"UPDATE characters SET char_exp = '%d' WHERE char_id = '%d'",
		Account_GetExp(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetMoney(const playerid, const value)
{
	accountMoney[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_money = '%d' WHERE char_id = '%d'",
		Account_GetMoney(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetScore(const playerid, const score)
{
	accountScore[playerid] = score;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_score = '%d' WHERE char_id = '%d'",
		Account_GetScore(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetGender(const playerid, const gender)
{
	accountGender[playerid] = gender;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_gender = '%d' WHERE char_id = '%d'",
		Account_GetGender(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetDOB(const playerid, const date[])
{
	strcopy(accountDOB[playerid], date);

	new String: str_query_update = str_format(
		"UPDATE characters SET char_dob = '%e' WHERE char_id = '%d'",
		Account_GetDOB(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetSpawnID(const playerid, const spawnid)
{
	accountSpawn[playerid] = spawnid;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_spawn = '%d' WHERE char_id = '%d'",
		Account_GetSpawn(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetBankCard(const playerid, const value)
{
	accountBankCard[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_bankcard = '%d' WHERE char_id = '%d'",
		Account_GetBankCard(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetBankMoney(const playerid, const value)
{
	accountBankMoney[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_bankmoney = '%d' WHERE char_id = '%d'",
		Account_GetBankMoney(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetGold(const playerid, const value)
{
	accountGold[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_gold = '%d' WHERE char_id = '%d'",
		Account_GetGold(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetHours(const playerid, const value)
{
	accountHours[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_hours = '%d' WHERE char_id = '%d'",
		Account_GetHours(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_SetHouse(const playerid, const value)
{
	accountHouse[playerid] = value;

	new String: str_query_update = str_format(
		"UPDATE characters SET char_house = '%d' WHERE char_id = '%d'",
		Account_GetHouse(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);
	return 1;
}

stock Account_PlayerSpawned(const playerid, bool:status) return playerSpawned[playerid] = status;

hook OnPlayerConnect(playerid)
{
	TogglePlayerSpectating(playerid, 1);
	// PlayAudioStreamForPlayer(playerid, "https://sv11.onlinevideoconverter.com/download?813506-813130");
	SendClientMessage(playerid, MAIN_COLOR_HEX, "[SERVER]: Ocitavanje servera, sacekajte malo!");

	// We need to call it twice because objects are already created in OnGameModeInit
	// so we need to "recall" the function to set object status first to true then to false
	// Winter_ShowSnowObjects(playerid);
	// Winter_ShowSnowObjects(playerid);

	task_await(
		MySQL_QueryS(
			str_format(
				"SELECT * FROM accounts WHERE account_name = '%e'", ReturnPlayerName(playerid)
			)
		)
	);

	if (!cache_num_rows())
	{
		Dialog_Show(playerid, "DIALOG_REGISTER", DIALOG_STYLE_PASSWORD,
			""MAIN_COLOR"gta-world - "WHITE"Registracija",
			""MAIN_COLOR"_______________________________________________\n\
			"MAIN_COLOR">>> "WHITE"Unesite zeljenu lozinku\n\
			"WHITE"Lozinka mora sadrzati najmanje "MAIN_COLOR"%d "WHITE"i najvise "MAIN_COLOR"%d "WHITE"karaktera!\n\
			"MAIN_COLOR"_______________________________________________",
			""MAIN_COLOR"Unesi", "Izlaz",
			MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH
		);
	}

	else
	{
		new
			tmp_str[MAX_PASSWORD_LENGTH],
			Alloc:str_alloc = malloc(sizeof(tmp_str) + 1);

		cache_get_value_name_int(0, "account_id", Account_GetID(playerid));
		cache_get_value_name(0, "account_password", tmp_str);

		msets(str_alloc, 0, tmp_str);
		Account_SetPassword(playerid, mget(str_alloc, 0));
		free(str_alloc);

		task_await(
			MySQL_QueryS(
				str_format(
					"SELECT * FROM characters WHERE char_name = '%e'", ReturnPlayerName(playerid)
				)
			)
		);

		if (cache_num_rows())
		{
			static tmpInt, tmpDateString[24];
			cache_get_value_name_int(0, "char_id", Account_GetCharID(playerid));
			cache_get_value_name_int(0, "char_money", tmpInt);
            Account_SetMoney(playerid, tmpInt);
			cache_get_value_name_int(0, "char_score", tmpInt);
            Account_SetScore(playerid, tmpInt);
			cache_get_value_name_int(0, "char_gender", tmpInt);
            Account_SetGender(playerid, tmpInt);
			cache_get_value_name_int(0, "char_skin", tmpInt);
            Account_SetSkin(playerid, tmpInt);
			cache_get_value_name_int(0, "char_spawn", tmpInt);
			Account_SetSpawnID(playerid, tmpInt);
			cache_get_value_name_int(0, "char_vip", tmpInt);
			Rank_SetTempVIP(playerid, tmpInt);
			cache_get_value_name_int(0, "char_admin", tmpInt);
			Rank_SetTempAdmin(playerid, tmpInt);
			cache_get_value_name_int(0, "char_exp", tmpInt);
            Account_SetExp(playerid, tmpInt);
			cache_get_value_name_int(0, "char_bankcard", tmpInt);
            Account_SetBankCard(playerid, tmpInt);
			cache_get_value_name_int(0, "char_atmpincode", tmpInt);
            Atm_SetPlayerPinCode(playerid, tmpInt);
			cache_get_value_name_int(0, "char_bankmoney", tmpInt);
            Account_SetBankMoney(playerid, tmpInt);
			cache_get_value_name_int(0, "char_gold", tmpInt);
            Account_SetGold(playerid, tmpInt);
			cache_get_value_name_int(0, "char_hours", tmpInt);
            Account_SetHours(playerid, tmpInt);
			cache_get_value_name_int(0, "char_wl", tmpInt);
            WantedLevel_Set(playerid, tmpInt);
			cache_get_value_name_int(0, "char_job", tmpInt);
            Account_SetJob(playerid, tmpInt);
			cache_get_value_name_int(0, "char_house", tmpInt);
            Account_SetHouse(playerid, tmpInt);
			cache_get_value_name(0, "char_dob", tmpDateString);
            Account_SetDOB(playerid, tmpDateString);
			cache_get_value_name_int(0, "char_orgid", tmpInt);
            Org_SetID(playerid, tmpInt);
			cache_get_value_name_int(0, "char_orgrank", tmpInt);
            Org_SetRank(playerid, tmpInt);
			cache_get_value_name_int(0, "char_marijuana", tmpInt);
            WeedGrower_SetPlayerMarijuana(playerid, tmpInt);

			cache_get_value_name_int(0, "char_mobile", tmpInt);
            Mobile_Set(playerid, tmpInt);
			cache_get_value_name_int(0, "char_mobilenum", tmpInt);
            Mobile_SetNumber(playerid, tmpInt);
			cache_get_value_name_int(0, "char_mobilecredit", tmpInt);
            Mobile_SetCredit(playerid, tmpInt);
			cache_get_value_name_int(0, "char_mobilepower", tmpInt);
            Mobile_SetPower(playerid, tmpInt);
		}

		InterpolateCameraPos(playerid, 163.370742, -2130.891113, 3.614542, 150.508148, -1941.372436, 53.552555, 7000);
		InterpolateCameraLookAt(playerid, 163.097000, -2125.963867, 4.419613, 152.024612, -1945.852172, 51.930122, 7000);

		Dialog_Show(playerid, "DIALOG_LOGIN", DIALOG_STYLE_PASSWORD,
			""MAIN_COLOR"gta-world - "WHITE"Prijavljivanje",
			""MAIN_COLOR"_______________________________________________\n\n\
			"WHITE"Unesite tacnu lozinku\n\
			"WHITE"Lozinka sadrzi "MAIN_COLOR"%d "WHITE"karaktera.\n\
			"MAIN_COLOR"_______________________________________________",
			""MAIN_COLOR"Unesi", "Izlaz",
			strlen(Account_GetPassword(playerid))
		);

		UI_CreateLoginTextDraw(playerid);
	}

	Player_ClearChat(playerid, .lines = 60);
	SetPlayerColor(playerid, 0xFFFFFFAA);
	SetTimerEx("Timer_UpdateAccHours", 2700000, true, "d", playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	UI_SetPlayerIGTD(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerRequestClass(playerid, classic)
{
	if (Account_GetSpawn(playerid) == 1)
		SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
	else if (Account_GetSpawn(playerid) == 2)
	{
		new houseid = Account_GetHouse(playerid);
		SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), House_GetIntPos(houseid, 0), House_GetIntPos(houseid, 1), House_GetIntPos(houseid, 2), 0.0, 0, 0, 0, 0, 0, 0);
	}

	SpawnPlayer(playerid);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerSpawn(playerid)
{
	Account_PlayerSpawned(playerid, true);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	Account_PlayerSpawned(playerid, false);
	GivePlayerMoney(playerid, 100);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

forward Account_InsertAccountID(const playerid);
public Account_InsertAccountID(const playerid)
{
	accountID[playerid] = cache_insert_id();
	return 1;
}

forward Account_InsertCharID(const playerid);
public Account_InsertCharID(const playerid)
{
	accountCharID[playerid] = cache_insert_id();
	return 1;
}

forward Account_SetSpawnData(const playerid, const spawnid);
public Account_SetSpawnData(const playerid, const spawnid)
{
	KillTimer(spawnTimer[playerid]);
	switch (spawnid)
	{
		case 1: Account_SetSpawn(playerid, 1);
		case 2: Account_SetSpawn(playerid, 2);

		default:
		{
			print("[ERROR]: Invalid spawn ID!");
		}
	}
	return 1;
}

forward SK_Timer(const playerid);
public SK_Timer(const playerid)
{
	TogglePlayerControllable(playerid, 1);

	task_await(
		MySQL_QueryS(
			str_format(
				"SELECT * FROM characters WHERE char_name = '%e'", ReturnPlayerName(playerid)
			)
		)
	);
	KillTimer(playerSKTimer[playerid]);
	return 1;
}

stock Account_SetSpawn(const playerid, const spawnid)
{
	new String:str_query_update = str_format(
		"UPDATE characters SET char_spawn = '%d' WHERE char_id = '%d'",
		spawnid, Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);

	StopAudioStreamForPlayer(playerid);
	UI_UpdateInfoTD(playerid);
	TogglePlayerSpectating(playerid, 0);
	TogglePlayerControllable(playerid, 0);

	GameTextForPlayer(playerid, "~y~ANTI SPAWN KILL ZASTITA U TOKU...", 3000, 3);
	playerSKTimer[playerid] = SetTimerEx("SK_Timer", 3000, false, "d", playerid);

	switch (spawnid)
	{
		case 1:
		{
			SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
			SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
			
			for (new i = 0; i < 30; i++)
				SendClientMessage(playerid, -1, " ");

			SendServerMsgF(playerid, "Dobrodosao nazad %s %s.", Player_SplitName(playerid, "name"), Player_SplitName(playerid, "lastname"));
			SendServerMsgF(playerid, "Vas trenutni level: %d | Exp: %d/%d", Account_GetScore(playerid), Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
		}

		case 2:
		{
			new houseid = Account_GetHouse(playerid);
			SetPlayerVirtualWorld(playerid, House_GetVW(houseid));
            SetPlayerInterior(playerid, 0);
			SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), House_GetIntPos(houseid, 0), House_GetIntPos(houseid, 1), House_GetIntPos(houseid, 2), 0.0, 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
			
			for (new i = 0; i < 30; i++)
				SendClientMessage(playerid, -1, " ");

			SendServerMsgF(playerid, "Dobrodosao nazad %s %s.", Player_SplitName(playerid, "name"), Player_SplitName(playerid, "lastname"));
			SendServerMsgF(playerid, "Vas trenutni level: %d | Exp: %d/%d", Account_GetScore(playerid), Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
		}

		default:
		{
			print("[ERROR]: Invalid spawn ID!");
		}
	}
	return 1;
}

// Dialogs
Dialog: DIALOG_REGISTER(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
	{
		Dialog_Show(playerid, "DIALOG_REGISTER", DIALOG_STYLE_PASSWORD,
			""MAIN_COLOR"gta-world - "WHITE"Registracija",
			""MAIN_COLOR"_______________________________________________\n\
			"MAIN_COLOR">>> "WHITE"Unesite zeljenu lozinku\n\
			"WHITE"Lozinka mora sadrzati najmanje "MAIN_COLOR"%d "WHITE"i najvise "MAIN_COLOR"%d "WHITE"karaktera!\n\
			"MAIN_COLOR"_______________________________________________",
			""MAIN_COLOR"Unesi", "Izlaz",
			MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH
		);
		return SendErrorMsg(playerid, "Prekratka ili predugacka lozinka!");
	}

	strcopy(accountPassword[playerid], inputtext);

	new String: str_query_insert_acc,
		String: str_query_insert_char;

	str_query_insert_acc = str_format("INSERT INTO accounts (account_name, account_password) VALUES ('%e', '%e')", ReturnPlayerName(playerid), accountPassword[playerid]);
	str_query_insert_char = str_format("INSERT INTO characters (char_name) VALUES ('%e')", ReturnPlayerName(playerid));

	mysql_tquery_s(MySQL_GetHandle(), str_query_insert_acc, "Account_InsertAccountID", "d", playerid);
    mysql_tquery_s(MySQL_GetHandle(), str_query_insert_char, "Account_InsertCharID", "d", playerid);

    Dialog_Show(playerid, "DIALOG_GENDER", DIALOG_STYLE_LIST,
		""MAIN_COLOR"gta-world - "WHITE"Registracija",
		"Musko\nZensko",
		""MAIN_COLOR"Odaberi", "Izlaz"
	);
	return 1;
}

Dialog: DIALOG_GENDER(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	accountGender[playerid] = listitem + 1;
	new String: str_query_update = str_format(
		"UPDATE characters SET char_gender = '%d' WHERE char_id = '%d'",
		Account_GetGender(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);

	Account_SetSkin(playerid, Account_GetGender(playerid) == 1 ? 240 : 193);
	Dialog_Show(playerid, "DIALOG_COUNTRY", DIALOG_STYLE_LIST,
		""MAIN_COLOR"gta-world - "WHITE"Registracija",
		"Srbija\nHrvatska\nBosna i Hercegovina\nCrna Gora\nMakedonija\nOstalo",
		""MAIN_COLOR"Odaberi", "Izlaz"
	);
	return 1;
}

Dialog: DIALOG_COUNTRY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	accountCountry[playerid] = listitem + 1;
	new String: str_query_update = str_format(
		"UPDATE characters SET char_country = '%d' WHERE char_id = '%d'",
		Account_GetCountry(playerid), Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);

	Dialog_Show(playerid, "DIALOG_DOB", DIALOG_STYLE_INPUT,
		""MAIN_COLOR"gta-world - "WHITE"Registracija",
		""WHITE"Unesite datum Vaseg rodjenja u formatu: YYYY-MM-DD (npr. 2005-08-13):",
		""MAIN_COLOR"Unesi", "Izlaz"
	);
	return 1;
}

Dialog: DIALOG_DOB(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	strcopy(accountDOB[playerid], inputtext);
	Account_SetSpawnID(playerid, 1);
	spawnTimer[playerid] = SetTimerEx("Account_SetSpawnData", 3000, false, "di", playerid, Account_GetSpawn(playerid));
	UI_ShowLoadingTextDraw(playerid, "UCITAVANJE...", 3000);

	Account_SetMoney(playerid, 20000);
	Account_SetScore(playerid, 1);

	GivePlayerMoney(playerid, Account_GetMoney(playerid));
	SetPlayerScore(playerid, Account_GetScore(playerid));
	UI_SetPlayerIGTD(playerid);
	// Movement_CreateUI(playerid, true);

	new String: str_query_update = str_format(
		"UPDATE characters SET char_dob = '%e' WHERE char_id = '%d'", accountDOB[playerid], Account_GetCharID(playerid)
	);
	mysql_tquery_s(MySQL_GetHandle(), str_query_update);

	for (new i = 0; i < 30; i++)
		SendClientMessage(playerid, -1, " ");

	SendServerMsgF(playerid, "Dobrodosao %s.", ReturnPlayerName(playerid));
	return 1;
}

Dialog: DIALOG_LOGIN(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return Kick(playerid);

	if (!strcmp(inputtext, Account_GetPassword(playerid), false))
	{
		UI_CreateLoginTextDraw(playerid);
		UI_ShowLoadingTextDraw(playerid, "UCITAVANJE...", 3000);
		spawnTimer[playerid] = SetTimerEx("Account_SetSpawnData", 3000, false, "di", playerid, Account_GetSpawn(playerid));

		GivePlayerMoney(playerid, Account_GetMoney(playerid));
		SetPlayerScore(playerid, Account_GetScore(playerid));
		UI_SetPlayerIGTD(playerid);
		// Movement_CreateUI(playerid, true);
	}
	else
	{
		SendErrorMsg(playerid, "Netacna lozinka.");	
		Dialog_Show(playerid, "DIALOG_LOGIN", DIALOG_STYLE_PASSWORD,
			""MAIN_COLOR"gta-world - "WHITE"Prijavljivanje",
			""MAIN_COLOR"_______________________________________________\n\n\
			"WHITE"Unesite tacnu lozinku\n\
			"WHITE"Lozinka sadrzi "MAIN_COLOR"%d "WHITE"karaktera.\n\
			"MAIN_COLOR"_______________________________________________",
			""MAIN_COLOR"Unesi", "Izlaz",
			strlen(Account_GetPassword(playerid))
		);
	}
	return 1;
}

// Update player hours spent on server
// 3,600,000ms = 1 hour
// 2,700,000ms = 45 minutes
forward Timer_UpdateAccHours(const playerid);
public Timer_UpdateAccHours(const playerid)
{
	new salary, base, exp;

	base += (1500 + random(250));
	salary = (base * Account_GetScore(playerid));
	exp = (Account_GetScore(playerid) * 2);

	if (Account_GetScore(playerid) < 10)
		Account_SetExp(playerid, (Account_GetExp(playerid) + 2));
	else
		Account_SetExp(playerid, (Account_GetExp(playerid) + 1));

	Account_SetHours(playerid, Account_GetHours(playerid) + 1);
	Account_SetBankMoney(playerid, (Account_GetBankMoney(playerid) + salary));
	if (Account_GetExp(playerid) >= exp)
	{
		Account_SetScore(playerid, (Account_GetScore(playerid) + 1));
		SetPlayerScore(playerid, Account_GetScore(playerid));
		Account_SetExp(playerid, (Account_GetExp(playerid)) - exp);
		SendServerMsgF(playerid, "Presli ste u sledeci level! Sada ste level %d!", Account_GetScore(playerid));
	}

	Dialog_Show(playerid, "DIALOG_PAYDAY", DIALOG_STYLE_MSGBOX,
		""DARKGREEN"PAYDAY - "WHITE"Isplata",
		""DARKGREEN"Plata je stigla na Vas racun!\n\n\
		"WHITE"Plata: "DARKGREEN"$"WHITE"%d\n\
		"WHITE"Level: %d",
		"Izlaz", "",
		salary, Account_GetScore(playerid)
	);
	return 1;
}