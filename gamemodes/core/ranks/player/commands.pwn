const LAPTOP_INDEX = 6;

static
	BitArray:Bit_PDDuty<MAX_PLAYERS>,
	askqTimer[MAX_PLAYERS],
	reportTimer[MAX_PLAYERS],
	playerLaptop[MAX_PLAYERS];

stock Player_GetLaptop(const playerid) return playerLaptop[playerid];

CMD:help(playerid, const params[])
{
    Dialog_Show(playerid, "DIALOG_PLAYERHELP", DIALOG_STYLE_MSGBOX,
        D_CAPTION,
        ""MAIN_COLOR"______________________________________________________\n\n\
        "MAIN_COLOR"Komande: "WHITE"/stats /askq /report /id /we /vreme /pojas\n\
        "MAIN_COLOR"Komande: "WHITE"/kupikucu /banka /otvoriracun /unrent /licnakarta\n\
        "MAIN_COLOR"Komande: "WHITE"/poslovi /hours /anim /vreme /otkaz /pljackajbankomat\n\
        "MAIN_COLOR"Komande: "WHITE"/posao /posaooprema /b /gps /rank /smokeweed\n\
        "MAIN_COLOR"Komande: "WHITE"/kupimobilni /kupimp3 /spawnchange /admins\n\
        "MAIN_COLOR"Komande: "WHITE"/kupiimovinu /imovina\n\
        "MAIN_COLOR"Telefon: "WHITE"/p /h /telefon\n\
        "MAIN_COLOR"Organizacija: "WHITE"/f /orgrank\n\
        "MAIN_COLOR"______________________________________________________",
        ""MAIN_COLOR"Zatvori"
    );
    return 1;
}

CMD:licnakarta(playerid, const params[])
{
	UI_CreateIDCard(playerid);
	return 1;
}

// CMD:kuca(playerid, const params[])
// {
// 	if (Account_GetHouse(playerid) == -1)
// 	    return SendErrorMsg(playerid, "Nemate kucu!");
// 	House_OpenMenu(playerid);
// 	return 1;
// }

CMD:v(playerid, const params[])
{
	Dialog_Show(playerid, "DIALOG_VEHMENU", DIALOG_STYLE_LIST,
		D_CAPTION,
		"Automobil 1\nAutomobil 2\nMotor\nBicikl",
		""MAIN_COLOR"Odaberi", "Izlaz"
	);
	return 1;
}

Dialog: DIALOG_VEHMENU(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch(listitem)
	{
		case 0:
		{
			if (!Account_GetCar(playerid, 1))
				return SendErrorMsg(playerid, "Nemate automobil na tom slotu!");

			Vehicle_SetSelected(playerid, Account_GetCar(playerid, 1));
			Vehicle_UpdateCarStatus(playerid);
		}

		case 1:
		{
			if (!Account_GetCar(playerid, 2))
				return SendErrorMsg(playerid, "Nemate automobil na tom slotu!");

			Vehicle_SetSelected(playerid, Account_GetCar(playerid, 2));
			Vehicle_UpdateCarStatus(playerid);
		}
	}
	return 1;
}

CMD:kupilaptop(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1489.0120,-1720.9556,8.2318))
		return SendErrorMsg(playerid, "Niste kod crnog trzista!");

	if (Player_GetLaptop(playerid))
		return SendErrorMsg(playerid, "Vec ste kupili laptop!");

	if (Account_GetMoney(playerid) < 20000)
		return SendErrorMsg(playerid, "Nemate dovoljno novca ($20.000)!");

	playerLaptop[playerid] = 1;
	SendInfoMsg(playerid, "Uspesno ste kupili laptop za $20.000");

	Account_SetMoney(playerid, (Account_GetMoney(playerid) - 20000));
	GivePlayerMoney(playerid, -20000);
	GameTextForPlayer(playerid, "~r~-$20.000", 3000, 3);
	return 1;
}

CMD:pljackajbankomat(playerid, const params[])
{
	if (!Atm_IsPlayerNearby(playerid))
		return SendErrorMsg(playerid, "Morate biti blizu bankomata!");

	if (!Player_GetLaptop(playerid))
		return SendErrorMsg(playerid, "Morate kupiti laptop za pljackanje bankomata!");

	new atmid = Atm_GetNearby(playerid);
	if (Atm_Robbed(atmid))
		return SendErrorMsg(playerid, "Taj bankomat je vec opljackan!");

	if (GetPlayerWantedLevel(playerid) < 6)
		WantedLevel_Set(playerid, 1);

	Org_LSPDMessage("!!! PAZNJA !!!");
	Org_LSPDMessage("%s pokusava da opljacka bankomat %d.", ReturnPlayerName(playerid), atmid);

	Atm_StartRob(playerid, atmid);

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	SetPlayerAttachedObject(playerid, LAPTOP_INDEX,
		19893, 5, 0.0, 0.0, 0.0, 90.0, 190.0, 100.0, 1.0, 1.0, 1.0, 0, 0
	);
	return 1;
}

// static Float:lapX, Float:lapY, Float:lapZ;

// CMD:rot(playerid, const params[])
// {
// 	if (sscanf(params, "fff", lapX, lapY, lapZ))
// 		return SendSyntaxMsg(playerid, "/rot [x] [y] [z]");

// 	if (IsPlayerAttachedObjectSlotUsed(playerid, LAPTOP_INDEX))
// 		RemovePlayerAttachedObject(playerid, LAPTOP_INDEX);

// 	SetPlayerAttachedObject(playerid, LAPTOP_INDEX,
// 		19893, 5, 0.0, 0.0, 0.0, lapX, lapY, lapZ, 1.0, 1.0, 1.0, 0, 0
// 	);
// 	// SetPlayerAttachedObject(playerid, index, modelid, bone, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0)
// 	return 1;
// }

// Command(name: spawnchange, rank: Rank_Player(), args: playerid, const string: params[])
CMD:spawnchange(playerid, const params[])
{
	Dialog_Show(playerid, "DIALOG_SPAWNCHANGE", DIALOG_STYLE_LIST,
		D_CAPTION,
		""MAIN_COLOR"[1]. "WHITE"Normalan spawn\n\
		"MAIN_COLOR"[2]. "WHITE"Spawn u kuci",
		""MAIN_COLOR"Odaberi", "Izlaz"
	);
	return 1;
}

/*Command(name: we, rank: Rank_Player(), args: playerid, const string: params[])
{
	static tmpStr[5][40];
    strcopy(tmpStr[0], (Winter_GetSnowObjStatus(playerid) ? (""LIGHTGREEN"Ukljuceno") : (""DARKRED"Iskljuceno")));
    strcopy(tmpStr[1], (Winter_GetSnowflakeStatus(playerid) ? (""LIGHTGREEN"Ukljuceno") : (""DARKRED"Iskljuceno")));
    strcopy(tmpStr[2], (Winter_GetSnowCapStatus(playerid) ? (""LIGHTGREEN"Ukljuceno") : (""DARKRED"Iskljuceno")));
    strcopy(tmpStr[4], (Winter_GetColdBreathStatus(playerid) ? (""LIGHTGREEN"Ukljuceno") : (""DARKRED"Iskljuceno")));
    
    if (Winter_GetAllStatus(playerid))
        strcopy(tmpStr[3], ""LIGHTGREEN"Iskljuci sve");
    else
        strcopy(tmpStr[3], ""DARKRED"Ukljuci sve");

    Dialog_Show(playerid, "DIALOG_WINTER", DIALOG_STYLE_TABLIST_HEADERS,
        ""MAIN_COLOR"gta-world - "WHITE"Winter Edition",
        ""MAIN_COLOR"Opcija\t"MAIN_COLOR"Status\n\
        "WHITE"Sneg po mapi\t%s\n\
        "WHITE"Padanje snega\t%s\n\
        "WHITE"Kapica\t%s\n\
        "WHITE"Dah iz usta\t%s\n\
        "WHITE"%s",
        "Potvrdi", "Izlaz",
        tmpStr[0], tmpStr[1], tmpStr[2], tmpStr[4], tmpStr[3]
    );
    return 1;
}*/

// Command(name: pojas, rank: Rank_Player(), args: playerid, const string: params[])
CMD:pojas(playerid, const params[])
{
	if (IsPlayerInAnyVehicle(playerid))
		Vehicle_SetSeatbelt(playerid);
	return 1;
}

// Command(name: otvoriracun, rank: Rank_Player(), args: playerid, const string: params[])
CMD:otvoriracun(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1376.3872, -29.5206, 1000.8729))
		return SendErrorMsg(playerid, "Morate biti u banci!");

	if (Account_GetBankCard(playerid))
		return SendErrorMsg(playerid, "Vec imate otvoren bankovni racun!");

	new code = 100000 + random(899000);
	Account_SetAtmPin(playerid, code);
	Account_SetBankCard(playerid, 1);
	UI_UpdateInfoTD(playerid);
	SendServerMsg(playerid, "Uspesno ste otvorili bankovni racun!");
	return 1;
}

// Command(name: banka, rank: Rank_Player(), args: playerid, const string: params[])
CMD:banka(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1375.9037, -26.0387, 1000.8729))
		return SendErrorMsg(playerid, "Morate biti u banci!");

	if (!Account_GetBankCard(playerid))
		return SendErrorMsg(playerid, "Morate otvoriti bankovni racun!");

	Dialog_Show(playerid, "DIALOG_BANK", DIALOG_STYLE_TABLIST_HEADERS,
		D_CAPTION,
		""MAIN_COLOR"Opcija\t"MAIN_COLOR"Stanje\n\
		"WHITE"Podigni novac\t"DARKGREEN"$"WHITE"%d "GREY"u banci\n\
		"WHITE"Ostavi novac\t"DARKGREEN"$"WHITE"%d "GREY"kod sebe\n\
		"WHITE"Prebaci novac", ""MAIN_COLOR"Potvrdi", "Izlaz",
		Account_GetBankMoney(playerid), Account_GetMoney(playerid)
	);
	return 1;
}

// Command(name: posao, rank: Rank_Player(), args: playerid, const string: params[])
CMD:posao(playerid, const params[])
{
	if (Account_GetJob(playerid))
		return SendErrorMsg(playerid, "Vec imate posao! Za otkaz, idite u opstinu.");

	// Postman
	if (IsPlayerInRangeOfPoint(playerid, 2.0, 986.8093, -1252.5247, 16.9844))
	{
		Account_SetJob(playerid, 1);
		SendServerMsg(playerid, "Uspesno ste se zaposlili kao postar!");
		SendServerMsg(playerid, "Komande posla: /posaooprema, /pokreniposao, /prekiniposao");
	}

	// Lawn mower
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 940.5753, -1085.9894, 24.2962))
	{
		Account_SetJob(playerid, 2);
		SendServerMsg(playerid, "Uspesno ste se zaposlili kao kosac trave!");
		SendServerMsg(playerid, "Komande posla: /posaooprema, /pokreniposao, /prekiniposao");
	}

	// Bus driver
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1808.0718,-1904.3878,13.5755))
	{
		Account_SetJob(playerid, 3);
		SendServerMsg(playerid, "Uspesno ste se zaposlili kao bus vozac!");
		SendServerMsg(playerid, "Komande posla: /posaooprema, /pokreniposao, /prekiniposao");
	}

	// Weed grower
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2491.6658,-957.3235,82.3045))
	{
		Account_SetJob(playerid, 4);
		SendServerMsg(playerid, "Uspesno ste se zaposlili kao uzgajivac marihuane!");
		SendServerMsg(playerid, "Komande posla: /posaooprema, /pokreniposao, /uzmiseme, /uzmitorbu, /prekiniposao");
	}
	return 1;
}

// Command(name: posaooprema, rank: Rank_Player(), args: playerid, const string: params[])
CMD:posaooprema(playerid, const params[])
{
	// Postman
	if (IsPlayerInRangeOfPoint(playerid, 2.0, 979.5859, -1254.7031, 16.9465) && Account_GetJob(playerid) == 1)
		Account_SetJobUniform(playerid, Account_GetJob(playerid), !Account_GetJobUniform(playerid));
	// Lawn mower
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 940.5753, -1085.9894, 24.2962) && Account_GetJob(playerid) == 2)
		Account_SetJobUniform(playerid, Account_GetJob(playerid), !Account_GetJobUniform(playerid));
	// Bus driver
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1808.1638,-1907.4720,13.5732) && Account_GetJob(playerid) == 3)
		Account_SetJobUniform(playerid, Account_GetJob(playerid), !Account_GetJobUniform(playerid));
	// Weed grower
	else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2495.8860,-953.0092,82.2543) && Account_GetJob(playerid) == 4)
		Account_SetJobUniform(playerid, Account_GetJob(playerid), !Account_GetJobUniform(playerid));
	return 1;
}

// Command(name: otkaz, rank: Rank_Player(), args: playerid, const string: params[])
CMD:otkaz(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1025.9491, -681.8823, -3.9059))
		return SendErrorMsg(playerid, "Morate biti u opstini!");

	if (!Account_GetJob(playerid))
		return SendErrorMsg(playerid, "Nemate posao!");

	if (Account_GetJobUniform(playerid))
		Account_SetJobUniform(playerid, Account_GetJob(playerid), false);
			
	Account_SetJob(playerid, 0);
	SendCustomMsgF(playerid, X11_LIGHTBLUE, "POSAO: "WHITE"Uspesno ste dali otkaz na poslu!");
	return 1;
}

// Command(name: pokreniposao, rank: Rank_Player(), args: playerid, const string: params[])
CMD:pokreniposao(playerid, const params[])
{
	if (!Account_GetJobUniform(playerid))
		return SendErrorMsg(playerid, "Niste uzeli opremu za posao.");

	switch (Account_GetJob(playerid))
	{
		// Postman
		case 1:
		{
			if (!IsPlayerInRangeOfPoint(playerid, 2.0, 979.5859, -1254.7031, 16.9465))
				return SendErrorMsg(playerid, "Morate biti na mestu gde ste uzeli opremu za posao!");

			SendInfoMsg(playerid, "Zapoceli ste posao.");
			Account_SetJobStarted(playerid, Account_GetJob(playerid), true);
		}

		// Lawn mower
		case 2:
		{
			if (!IsPlayerInRangeOfPoint(playerid, 2.0, 940.5753, -1085.9894, 24.2962))
				return SendErrorMsg(playerid, "Morate biti na mestu gde ste uzeli opremu za posao!");

			SendInfoMsg(playerid, "Zapoceli ste posao.");
			Account_SetJobStarted(playerid, Account_GetJob(playerid), true);
		}

		// Bus driver
		case 3:
		{
			if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1808.1638,-1907.4720,13.5732))
				return SendErrorMsg(playerid, "Morate biti na mestu gde ste uzeli opremu za posao!");

			// SendInfoMsg(playerid, "Zapoceli ste posao.");
			Dialog_Show(playerid, "DIALOG_BUSROUTE", DIALOG_STYLE_LIST,
				D_CAPTION,
				""MAIN_COLOR"1. "WHITE"Prva ruta\n"MAIN_COLOR"2. "WHITE"Druga ruta (NIJE DOSTUPNO)",
				""MAIN_COLOR"Odaberi", "Izlaz"
			);
		}

		// Weed grower
		case 4:
		{
			if (!IsPlayerInRangeOfPoint(playerid, 2.0, 2495.8860,-953.0092,82.2543))
				return SendErrorMsg(playerid, "Morate biti na mestu gde ste uzeli opremu za posao!");

			if (!WeedGrower_GetBag(playerid))
				return SendErrorMsg(playerid, "Niste uzeli torbu!");

			if (!WeedGrower_GetSeed(playerid))
				return SendErrorMsg(playerid, "Niste uzeli seme!");

			SendInfoMsg(playerid, "Zapoceli ste posao.");
			Account_SetJobStarted(playerid, Account_GetJob(playerid), true);
		}
	}
	return 1;
}

// Command(name: ostavitorbu, rank: Rank_Player(), args: playerid, const string: params[])
CMD:ostavitorbu(playerid, const params[])
{
	if (Account_GetJob(playerid) != 4)
		return SendErrorMsg(playerid, "Nemate posao uzgajivac marihuane!");

	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 2488.9578,-961.3019,82.2570))
		return SendErrorMsg(playerid, "Niste na mestu gde se uzima torba!");

	if (!WeedGrower_GetJobDone(playerid))
		return SendErrorMsg(playerid, "Niste zavrsili posao!");

	WeedGrower_StopJob(playerid);
	WeedGrower_SetCheckpoint(playerid, 15);
	return 1;
}

// Command(name: uzmitorbu, rank: Rank_Player(), args: playerid, const string: params[])
CMD:uzmitorbu(playerid, const params[])
{
	if (Account_GetJob(playerid) != 4)
		return SendErrorMsg(playerid, "Nemate posao uzgajivac marihuane!");

	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 2488.9578,-961.3019,82.2570))
		return SendErrorMsg(playerid, "Niste na mestu gde se uzima torba!");

	if (WeedGrower_GetBag(playerid))
		return SendErrorMsg(playerid, "Vec ste uzeli torbu!");

	WeedGrower_SetBag(playerid);
	SendCustomMsgF(playerid, X11_CYAN, "POSAO: "WHITE"Uzeli ste torbu gde cete staviti marihuanu.");
	return 1;
}

// Command(name: uzmiseme, rank: Rank_Player(), args: playerid, const string: params[])
CMD:uzmiseme(playerid, const params[])
{
	if (Account_GetJob(playerid) != 4)
		return SendErrorMsg(playerid, "Nemate posao uzgajivac marihuane!");

	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 2489.2358,-958.2571,82.2619))
		return SendErrorMsg(playerid, "Niste na mestu gde se uzima seme!");

	if (WeedGrower_GetSeed(playerid))
		return SendErrorMsg(playerid, "Vec ste uzeli seme!");

	WeedGrower_SetSeed(playerid);
	SendCustomMsgF(playerid, X11_CYAN, "POSAO: "WHITE"Uzeli ste seme koje cete posaditi.");
	return 1;
}

// Command(name: prekiniposao, rank: Rank_Player(), args: playerid, const string: params[])
CMD:prekiniposao(playerid, const params[])
{
	if (!Account_GetJob(playerid))
		return SendErrorMsg(playerid, "Nemate posao!");

	if (!Account_JobStarted(playerid))
		return SendErrorMsg(playerid, "Niste zapoceli sa poslom!");

	Account_SetJobStarted(playerid, Account_GetJob(playerid), false);
	SendInfoMsg(playerid, "Prekinuli ste sa poslom.");

	if (Account_GetJob(playerid) == 2)
		Mower_DestroyPlayerObjects(playerid);
	else if (Account_GetJob(playerid) == 4)
		WeedGrower_StopJob(playerid);
	return 1;
}

// Command(name: hours, rank: Rank_Player(), args: playerid, const string: params[])
CMD:hours(playerid, const params[])
{
	SendInfoMsgF(playerid, "Sati igre na serveru: %d.", Account_GetHours(playerid));
	return 1;
}

// Command(name: unrent, rank: Rank_Player(), args: playerid, const string: params[])
CMD:unrent(playerid, const params[])
{
	if (!Rent_GetPlayerTime(playerid))
		return SendErrorMsg(playerid, "Nemate iznajmljeno vozilo!");

	Rent_Destroy(playerid);
	SendCustomMsgF(playerid, X11_CYAN, "RENT: "WHITE"Vise ne iznajmljujete vozilo!");
	return 1;
}

// Command(name: kupikucu, rank: Rank_Player(), args: playerid, const string: params[])
// CMD:kupikucu(playerid, const params[])
// {
// 	if (Account_GetHouse(playerid) != -1)
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Vec imate kucu!");

//     new houseid = House_GetNearby(playerid);
//     if (houseid == House_GetMaxHouses())
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti blizu neke kuce!");

//     if (House_HasOwner(houseid))
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Ta kuca nije na prodaju.");

//     if (Account_GetMoney(playerid) < House_GetPrice(houseid))
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Nemate dovoljno novca za ovu kucu!");

//     Account_SetHouse(playerid, houseid);
//     Account_SetMoney(playerid, (Account_GetMoney(playerid) - House_GetPrice(houseid)));
//     GivePlayerMoney(playerid, -House_GetPrice(houseid));
//     House_Buy(playerid, houseid);

//     // new str_query_update[128];
//     // mysql_format(MySQL_GetHandle(), str_query_update, sizeof(str_query_update),
//     //     "UPDATE houses SET house_owned = '1', house_owner = '%e' WHERE house_id = '%d'",
//     //     ReturnPlayerName(playerid), (houseid + 1)
//     // );
//     // mysql_query(MySQL_GetHandle(), str_query_update);
// 	return 1;
// }

// Command(name: kuca, rank: Rank_Player(), args: playerid, const string: params[])
// {
// 	if (Account_GetHouse(playerid) == -1)
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Nemate kucu!");

//     new houseid = House_GetNearby(playerid);
//     if (houseid == House_GetMaxHouses())
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti blizu kuce!");

//     if (strcmp(ReturnPlayerName(playerid), House_GetOwner(houseid)))
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti kod svoje kuce!");

//     static tmpString[32];
//     strcopy(tmpString, (!House_IsLocked(houseid) ? (""DARKRED"Zakljucaj") : (""LIGHTGREEN"Otkljucaj")));

//     Dialog_Show(playerid, "DIALOG_HOUSEMENU", DIALOG_STYLE_LIST,
//         ""MAIN_COLOR"gta-world - "WHITE"Kuca",
//         "Komande za kucu\nPromeni opis kuce\n%s kucu\nProdaj kucu",
//         ""MAIN_COLOR"Potvrdi", "Izlaz", tmpString
//     );
// 	return 1;
// }

// Command(name: locirajkucu, rank: Rank_Player(), args: playerid, const string: params[])
// CMD:locirajkucu(playerid, const params[])
// {
// 	new houseid = Account_GetHouse(playerid);
// 	if (houseid == -1)
// 		return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Nemate kucu!");

// 	if (houseLocated[playerid])
// 	{
// 		houseLocated[playerid] = !houseLocated[playerid];
// 		SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Kuca): "WHITE"Prekinuli ste lociranje Vase kuce!");
// 		DisablePlayerCheckpoint(playerid);
// 		return 1;
// 	}

// 	SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Kuca): "WHITE"Vasa kuca je oznacena na mapi!");
// 	SetPlayerCheckpoint(playerid, House_GetPos(houseid, 0), House_GetPos(houseid, 1), House_GetPos(houseid, 2), 4.00);
// 	houseLocated[playerid] = !houseLocated[playerid];
// 	return 1;
// }

// Command(name: poslovi, rank: Rank_Player(), args: playerid, const string: params[])
CMD:poslovi(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 1.00, 1024.2988, -681.9590, -3.9059))
		return SendErrorMsg(playerid, "Morate biti u opstini!");

	Dialog_Show(playerid, "DIALOG_JOBLIST", DIALOG_STYLE_INPUT,
		D_CAPTION,
		""MAIN_COLOR"1 - "WHITE"Postar\n"MAIN_COLOR"2 - "WHITE"Kosac trave\n"MAIN_COLOR"3 - "WHITE"Bus vozac\n"MAIN_COLOR"4 - "WHITE"Uzgajivac marihuane\n\n"WHITE"Unesite broj posla, na mapi ce\n\
		Vam biti oznacen zeljeni posao.", ""MAIN_COLOR"Unesi", "Izlaz"
	);
	return 1;
}

// Command(name: anim, rank: Rank_Player(), args: playerid, const string: params[])
CMD:anim(playerid, const params[])
{
	if (isnull(params) || IsNumeric(params))
		return SendSyntaxMsg(playerid, "/anim [list|name|stop]");

	if (!strcmp(params, "list", false))
	{
		SendCustomMsgF(playerid, X11_LIGHTGRAY, "Animacije: carjacked | drunk | bomb | laugh | lookout | robman | lay");
        SendCustomMsgF(playerid, X11_LIGHTGRAY, "Animacije: wave | slapass | deal | crack | groundsit | chat | chat2");
        SendCustomMsgF(playerid, X11_LIGHTGRAY, "Animacije: fucku | taichi | kiss | injured | sup1 | sup2 | sup3 | rap1");
        SendCustomMsgF(playerid, X11_LIGHTGRAY, "Animacije: rap2 | push | medic | koface | lifejump | leftslap | strip");
        SendCustomMsgF(playerid, X11_LIGHTGRAY, "Animacije: dance1 | dance2 | dance3 | dance4 | bed | lean | aim | sit");
        return 1;
	}

	else if (!strcmp(params, "stop", false))
	{
		ClearAnimations(playerid);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		Anim_StopLooping(playerid);
		Anim_SetIndex(playerid, -1);
	}

	else
	{
		Anim_SetIndex(playerid, -1);
		Anim_SetPlayerAnimation(playerid, params);
	}
	return 1;
}

// Command(name: vreme, rank: Rank_Player(), args: playerid, const string: params[])
CMD:vreme(playerid, const params[])
{
	static tmpString[64], currentHour, currentMin, currentSec;
	gettime(currentHour, currentMin, currentSec);

	Anim_Play(playerid, "COP_AMBIENT", "Coplook_watch", 3.5, 0, 0, 0, 0, 0);
	
	// if (Account_GetJailTime(playerid))
	// 	va_GameTextForPlayer(playerid, "~y~- %02d:%02d:%02d -~n~~r~Zatvoren: ~w~%d minuta", 3000, 3, currentHour, currentMin, currentSec, Account_GetJailTime(playerid));	
	// else
	va_GameTextForPlayer(playerid, "~y~- %02d:%02d:%02d -", 3000, 3, currentHour, currentMin, currentSec);

	format(tmpString, sizeof(tmpString), "%s podize ruku i gleda na sat.", ReturnPlayerName(playerid));
	Rank_RadiusMessage(20.0, playerid, tmpString, PURPLE_COLOR_HEX, PURPLE_COLOR_HEX, PURPLE_COLOR_HEX, PURPLE_COLOR_HEX, PURPLE_COLOR_HEX);
	return 1;
}

// Command(name: id, rank: Rank_Player(), args: playerid, const string: params[])
CMD:id(playerid, const params[])
{
	static targetName;
	if (sscanf(params, "u", targetName))
		return SendSyntaxMsg(playerid, "/id [playername]");

	if (!IsPlayerConnected(targetName))
		return SendErrorMsg(playerid, "Taj igrac nije prijavljen.");

	SendCustomMsgF(playerid, X11_CYAN, "====================================================");
	SendCustomMsgF(playerid, X11_CYAN, ""LIGHTGRAY"%s "CYAN"[ID:"LIGHTGRAY"%d"CYAN"]", ReturnPlayerName(targetName), targetName);
	SendCustomMsgF(playerid, X11_CYAN, "====================================================");
	return 1;
}

// Command(name: askq, rank: Rank_Player(), args: playerid, const string: params[])
CMD:askq(playerid, const params[])
{
	static tmpString[32], staffCount;
	foreach (new i: Player)
	{
		if (Rank_GetPlayerAdminLevel(i))
		{
			strcopy(tmpString, ""LIGHTGREEN"Ima staff-a");
			staffCount++;
		}
	}

	if (!staffCount)
	{
		strcopy(tmpString, ""RED"Nema staff-a");
		return SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Nema staff team-a, pa nemate kome poslati pitanje!");
	}

	if (gettime() < askqTimer[playerid])
		return SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Pitanje mozete postaviti svaka 2 minuta!");

	Dialog_Show(playerid, "DIALOG_ASKQSELECT", DIALOG_STYLE_TABLIST_HEADERS,
		D_CAPTION,
		""WHITE"Opcija\t"WHITE"Status\n\
		"WHITE"Staff team-u\t%s",
		""MAIN_COLOR"Odaberi", "Izlaz", tmpString
	);
	return 1;
}

// Command(name: report, rank: Rank_Player(), args: playerid, const string: params[])
CMD:report(playerid, const params[])
{
	static tmpString[32], staffCount;
	foreach (new i: Player)
	{
		if (Rank_GetPlayerAdminLevel(i))
		{
			strcopy(tmpString, ""LIGHTGREEN"Ima staff-a");
			staffCount++;
		}
	}

	if (!staffCount)
	{
		strcopy(tmpString, ""RED"Nema staff-a");
		return SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Nema staff team-a, pa nemate kome poslati prijavu!");
	}

	if (gettime() < reportTimer[playerid])
		return SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Prijavu mozete poslati svaka 2 minuta!");

	Dialog_Show(playerid, "DIALOG_REPORTSELECT", DIALOG_STYLE_TABLIST_HEADERS,
		D_CAPTION,
		""WHITE"Opcija\t"WHITE"Status\n\
		"WHITE"Staff team-u\t%s",
		""MAIN_COLOR"Odaberi", "Izlaz", tmpString
	);
	return 1;
}

// Command(name: kioskui, rank: Rank_Player(), args: playerid, const string: params[])
CMD:kioskui(playerid, const params[])
{
	if (!Kiosk_ChoosingItem(playerid))
		return 0;

	Kiosk_DestroyUI(playerid);
	return 1;
}

// Command(name: cardealershipui, rank: Rank_Player(), args: playerid, const string: params[])
CMD:cardealershipui(playerid, const params[])
{
	if (!Vehicle_ViewingCatalogue(playerid))
		return 0;

	Vehicle_CreateCOSUI(playerid, false);
	return 1;
}

// Command(name: f, rank: Rank_Player(), args: playerid, const string: params[])
CMD:f(playerid, const params[])
{
	if (!Org_GetID(playerid))
		return SendErrorMsg(playerid, "Niste u organizaciji!");

	if (isnull(params))
		return SendSyntaxMsg(playerid, "/f [text]");

	switch (Org_GetID(playerid))
	{
		case 1:
		{
			foreach (new i: Player)
				if (Org_GetID(i) == 1)
					SendCustomMsgF(i, X11_YELLOW, "(POLICIJA) | "WHITE"%s[%d]: "LIGHTGRAY"%s", ReturnPlayerName(playerid), playerid, params);
		}

		case 2:
		{
			foreach (new i: Player)
				if (Org_GetID(i) == 2)
					SendCustomMsgF(i, X11_YELLOW, "(HITNA POMOC) | "WHITE"%s[%d]: "LIGHTGRAY"%s", ReturnPlayerName(playerid), playerid, params);
		}
	}
	return 1;
}

// Command(name: pdduznost, rank: Rank_Player(), args: playerid, const string: params[])
CMD:pdduznost(playerid, const params[])
{
	if (Org_GetID(playerid) != 1)
		return SendErrorMsg(playerid, "Niste clan policije!");

	if (!IsPlayerInRangeOfPoint(playerid, 2.0, -6.0318,2661.6643,-49.2784))
		return SendErrorMsg(playerid, "Niste na mestu gde se uzima duznost!");

	if (Bit_Get(Bit_PDDuty, playerid))
	{
		SendCustomMsgToAllF(X11_BLUE, "#Policija: "WHITE"Policajac "BLUE"%s "WHITE"vise nije na duznosti.", ReturnPlayerName(playerid));
		Bit_Set(Bit_PDDuty, playerid, false);
		ResetPlayerWeapons(playerid);
		SetPlayerColor(playerid, X11_WHITE);
		SetPlayerSkin(playerid, Account_GetSkin(playerid));
		return 1;
	}

	SendCustomMsgToAllF(X11_BLUE, "#Policija: "WHITE"Policajac "BLUE"%s "WHITE"je sada na duznosti.", ReturnPlayerName(playerid));
	Bit_Set(Bit_PDDuty, playerid, true);

	SetPlayerColor(playerid, X11_BLUE);
	GivePlayerWeapon(playerid, 3, 1);
	GivePlayerWeapon(playerid, 22, 100);
	GivePlayerWeapon(playerid, 3, 1);
	return 1;
}

// Command(name: pdoprema, rank: Rank_Player(), args: playerid, const string: params[])
CMD:pdoprema(playerid, const params[])
{
	if (Org_GetID(playerid) != 1)
		return SendErrorMsg(playerid, "Niste clan policije!");

	if (!IsPlayerInRangeOfPoint(playerid, 2.0, -6.0318,2661.6643,-49.2784))
		return SendErrorMsg(playerid, "Niste na mestu gde se uzima oprema!");

	if (!Bit_Get(Bit_PDDuty, playerid))
		return SendErrorMsg(playerid, "Prvo morate uzeti duznost!");

	Dialog_Show(playerid, "DIALOG_PDEQUIP", DIALOG_STYLE_LIST,
		D_CAPTION,
		""BLUE"1. "WHITE"Patrolna oprema\n\
		"BLUE"2. "WHITE"Specijalna oprema\n\
		"BLUE"3. "WHITE"Snajperska oprema\n\
		"BLUE"4. "WHITE"Normalna oprema",
		""BLUE"Odaberi", "Izlaz"
	);
	return 1;
}

// Command(name: gps, rank: Rank_Player(), args: playerid, const string: params[])
CMD:gps(playerid, const params[])
{
	GPS_ShowMenu(playerid);
	return 1;
}

CMD:gpsoff(playerid, const params[])
{
	GPS_Disable(playerid);
	return 1;
}

// Command(name: b, rank: Rank_Player(), args: playerid, const string: params[])
CMD:b(playerid, const params[])
{
	if (isnull(params))
		return SendSyntaxMsg(playerid, "/b [ooc text]");

	static tmpString[128];
	format(tmpString, sizeof(tmpString), ""LIGHTBLUE"(OOC): (%d)%s: "WHITE"%s", playerid, ReturnPlayerName(playerid), params);
	Rank_RadiusMessage(20.0, playerid, tmpString, X11_WHITE, X11_WHITE, X11_WHITE, X11_WHITE, X11_WHITE);
	return 1;
}

// Command(name: orgrank, rank: Rank_Player(), args: playerid, const string: params[])
CMD:orgrank(playerid, const params[])
{
	if (Org_GetRank(playerid) != 5)
		return SendErrorMsg(playerid, "Samo lideri organizacije!");

	static
		targetid,
		rankid;

	if (sscanf(params, "ri", targetid, rankid))
		return SendSyntaxMsg(playerid, "/orgrank [targetid] [rank (1-5)]");

	if (targetid == _:playerid)
		return SendErrorMsg(playerid, "Ne mozete sami sebi postavljati rank!");

	if (!Org_GetID(targetid))
		return SendErrorMsg(playerid, "Taj igrac nije u organizaciji!");

	if (!(0 <= rankid <= 5))
		return SendErrorMsg(playerid, "Nepostojeci rank, (0-5)!");

	if (!rankid && Org_GetID(targetid))
	{
		SendCustomMsgF(targetid, X11_RED, "(Organizacija): "WHITE"%s Vas je izbacio iz organizacije.", ReturnPlayerName(playerid));
		SendCustomMsgF(playerid, X11_RED, "(Organizacija): "WHITE"Igraca %s ste izbacili iz organizacije.", ReturnPlayerName(targetid));
		Org_SetID(targetid, 0);
		Org_SetRank(targetid, 0);
		Account_SetSkin(targetid, 1);
		return 1;
	}

	if (rankid == Org_GetRank(targetid))
		return SendErrorMsg(playerid, "Taj igrac je vec taj rank!");

	Org_SetRank(targetid, rankid);
	SendCustomMsgF(targetid, X11_LIGHTGREEN, "(Organizacija): "WHITE"%s Vam je postavio '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(playerid), rankid);
	SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Organizacija): "WHITE"Igracu %s ste postavili '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(targetid), rankid);
	return 1;
}

// Command(name: stats, rank: Rank_Player(), args: playerid, const string: params[])
CMD:stats(playerid, const params[])
{
	Dialog_Show(playerid, "DIALOG_STATS", DIALOG_STYLE_MSGBOX,
		D_CAPTION,
		""MAIN_COLOR"_____________________________\n\
		"MAIN_COLOR"Ime i prezime: "WHITE"%s %s\n\
		"MAIN_COLOR"Spol: "WHITE"%s\n\
		"MAIN_COLOR"ID: "WHITE"%d\n\n\
		"MAIN_COLOR"Skin: "WHITE"%d\n\
		"MAIN_COLOR"Sati igre: "WHITE"%d\n\
		"MAIN_COLOR"Level: "WHITE"%d\n\
		"MAIN_COLOR"Exp: "WHITE"%d/%d\n\
		"MAIN_COLOR"Novac kod sebe: "DARKGREEN"$"WHITE"%d\n\
		"MAIN_COLOR"Novac u banci: "DARKGREEN"$"WHITE"%d\n\
		"MAIN_COLOR"Zlato: "WHITE"%d"YELLOW"g\n\
		"MAIN_COLOR"Marihuana: "WHITE"%dg\n\n\
		"MAIN_COLOR"Posao: "WHITE"%s\n\
		"MAIN_COLOR"Organizacija: "WHITE"%s (rank: %d)\n\
		"MAIN_COLOR"_____________________________",
		"Izlaz", "",
		Player_SplitName(playerid, "name"), Player_SplitName(playerid, "lastname"),
		((Account_GetGender(playerid) == 1) ? "Musko" : "Zensko"), playerid,
		Account_GetSkin(playerid), Account_GetHours(playerid),
		Account_GetScore(playerid), Account_GetExp(playerid), (Account_GetScore(playerid) * 2),
		Account_GetMoney(playerid), Account_GetBankMoney(playerid), Account_GetGold(playerid),
		WeedGrower_GetPlayerMarijuana(playerid), Account_GetJobNameByID(Account_GetJob(playerid)),
		Org_GetNameByID(Org_GetID(playerid)), Org_GetRank(playerid)
	);
	return 1;
}

// Command(name: smokeweed, rank: Rank_Player(), args: playerid, const string: params)
CMD:smokeweed(playerid, const params[])
{
	if (WeedGrower_GetPlayerMarijuana(playerid) < 10)
		return SendErrorMsg(playerid, "Nemate marihuane kod sebe (min. 10g)!");

	WeedGrower_UseMarijuana(playerid);
	return 1;
}

// Command(name: kupimobilni, rank: Rank_Player(), args: playerid, const string: params[])
CMD:kupimobilni(playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 2.0, 1310.2061,-1189.7286,23.7329))
		return SendErrorMsg(playerid, "Morate biti u elkoru, (/gps)!");

	if (Mobile_Get(playerid))
		return SendErrorMsg(playerid, "Vec imate mobilni telefon.");

	if (Account_GetMoney(playerid) < 10000)
		return SendErrorMsg(playerid, "Nemate "RED"$10000 "WHITE"da kupite mobilni.");

	new number = 100000 + random(899000);
	Mobile_Set(playerid, 1);
	Mobile_SetPower(playerid, 1);
	Mobile_SetNumber(playerid, number);

	Account_SetMoney(playerid, (Account_GetMoney(playerid) - 10000));
	GivePlayerMoney(playerid, -10000);
	GameTextForPlayer(playerid, "~r~-$10000", 3000, 3);

	SendCustomMsgF(playerid, X11_YELLOW, "Mobilni: "WHITE"Uspesno ste kupili mobilni telefon! Vas broj: "YELLOW"%d"WHITE".", Mobile_GetNumber(playerid));
	SendCustomMsgF(playerid, X11_YELLOW, "Mobilni: "WHITE"Za uputstvo koriscenja telefona kucajte "YELLOW"/help"WHITE".");
	return 1;
}

// Command(name: telefon, rank: Rank_Player(), args: playerid, const string: params[])
CMD:telefon(playerid, const params[])
{
	if (!Mobile_Get(playerid))
		return SendErrorMsg(playerid, "Nemate mobilni telefon, kupite ga u elkoru (/gps)!");

	Dialog_Show(playerid, "DIALOG_PHONEMENU", DIALOG_STYLE_TABLIST_HEADERS,
		D_CAPTION,
		""WHITE"Opcija\t"WHITE"-\t"WHITE"Status\n\
		Vas broj telefona\t"LIMEGREEN">\t"WHITE"%d\n\
		Stanje kredita\t"LIMEGREEN">\t"WHITE"%d\n\
		Pozovi korisnika\t"LIMEGREEN">\t"WHITE"%s\n\
		Posalji sms korisniku\t"LIMEGREEN">\t"WHITE"Nije odabrano\n\
		%s telefon\t"LIMEGREEN">\t"WHITE"%s",
		""MAIN_COLOR"Izaberi", "Izlaz",
		Mobile_GetNumber(playerid),
		Mobile_GetCredit(playerid),
		ReturnPlayerName(Mobile_SelectedPlayer(playerid)),
		(!Mobile_GetPower(playerid) ? ""LIGHTGREEN"Upali" : ""DARKRED"Ugasi"),
		(!Mobile_GetPower(playerid) ? "Ugasen" : "Upaljen")
	);
	return 1;
}

// Command(name: mobileui, rank: Rank_Player(), args: playerid, const string: params[])
CMD:mobileui(playerid, const params[])
{
	if (Mobile_GetUI(playerid))
		Mobile_CreateUI(playerid);
	return 1;
}

// Command(name: selectui, rank: Rank_Player(), args: playerid, const string: params[])
// CMD:selectui(playerid, const params[])
// {
// 	if (Selection_GetUI(playerid))
// 		Selection_CreateUI(playerid);
// 	return 1;
// }

// Command(name: p, rank: Rank_Player(), args: playerid, const stirng: params[])
CMD:p(playerid, const params[])
{
	if (!Mobile_Ringing(playerid))
		return SendErrorMsg(playerid, "Ne zvoni vam mobilni telefon!");

	if (Mobile_Answered(playerid))
		return SendErrorMsg(playerid, "Vec ste se javili na telefon!");

	SendCustomMsgF(playerid, X11_YELLOW, "Mobilni: "WHITE"Javili ste se na mobilni telefon!");
	SendCustomMsgF(Mobile_WhoCalled(playerid), X11_YELLOW, "Mobilni: "WHITE"Korisnik %s se javio na telefon.", ReturnPlayerName(playerid));
	Mobile_CallOngoing(Mobile_WhoCalled(playerid), 1);
	Mobile_CallOngoing(playerid, 1);
	Mobile_SetAnswer(playerid, 1);
	Mobile_SetRing(playerid, 0);

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
	SetPlayerAttachedObject(playerid, Mobile_GetPhoneSlot(), 330, 6, 0.04, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	SetPlayerSpecialAction(Mobile_WhoCalled(playerid), SPECIAL_ACTION_USECELLPHONE);
	SetPlayerAttachedObject(Mobile_WhoCalled(playerid), Mobile_GetPhoneSlot(), 330, 6, 0.04, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	return 1;
}

// Command(name: h, rank: Rank_Player(), args: playerid, const stirng: params[])
CMD:h(playerid, const params[])
{
	if (Mobile_Ringing(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))))
	{
		Mobile_SetRing(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), 0);
		// if (_:playerid != Mobile_WhoCalled(playerid))
		// 	SendCustomMsgF(Mobile_WhoCalled(playerid), X11_RED, "Mobilni: "WHITE"%s je "RED"prekinuo "WHITE"poziv!", ReturnPlayerName(playerid));
		// else
		// 	SendCustomMsgF(playerid, X11_RED, "Mobilni: prekinuli "WHITE"ste poziv!");
		return 1;
	}

	if (Mobile_IsCallOngoing(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))))
	{
		Mobile_SetAnswer(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), 0);
		Mobile_SetRing(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), 0);
		Mobile_SetAnswer(Mobile_WhoCalled(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))), 0);
		Mobile_SetRing(Mobile_WhoCalled(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))), 0);
		Mobile_CallOngoing(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), 0);
		Mobile_CallOngoing(Mobile_WhoCalled(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))), 0);

		SetPlayerSpecialAction(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), SPECIAL_ACTION_STOPUSECELLPHONE);
		RemovePlayerAttachedObject(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid)), Mobile_GetPhoneSlot());
		SetPlayerSpecialAction(Mobile_WhoCalled(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))), SPECIAL_ACTION_STOPUSECELLPHONE);
		RemovePlayerAttachedObject(Mobile_WhoCalled(Mobile_SelectedPlayer(Mobile_WhoCalled(playerid))), Mobile_GetPhoneSlot());
	}
	return 1;
}

CMD:admins(playerid, const params[])
{
	foreach (new i: Player)
	{
		if (!Rank_GetPlayerAdminLevel(i))
			SendErrorMsg(playerid, "Trenutno nema admina na serveru.");
		else
		{
			Dialog_Show(playerid, "DIALOG_ADMINLIST", DIALOG_STYLE_TABLIST,
				D_CAPTION,
				""WHITE"Ime\t"YELLOW"Rank\n\
				%s\t"YELLOW"%s",
				""YELLOW"Zatvori", "",
				ReturnPlayerName(i), Rank_GetAdminName(Rank_GetPlayerAdminLevel(i))
			);
		}
	}
	return 1;
}

Dialog: DIALOG_PHONEMENU(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0..1: cmd_telefon(playerid, "");
		case 2: Dialog_Show(playerid, "DIALOG_CALLSELECT", DIALOG_STYLE_INPUT,
					D_CAPTION,
					""WHITE"Unesite ID/Ime igraca ciji broj zelite da pozovete:",
					""MAIN_COLOR"Unesi", "Izlaz"
				);
		case 3..4: cmd_telefon(playerid, "");
	}
	return 1;
}

Dialog: DIALOG_CALLSELECT(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		cmd_telefon(playerid, "");

	// We'll use sscanf because we can serach player by id or name
	// with isnull(...) and IsNumeric(...), we can't do that
	static targetid;
	if (sscanf(inputtext, "r", targetid))
		return cmd_telefon(playerid, "");

	Mobile_SelectPlayer(playerid, targetid);
	Mobile_CreateUI(playerid);
	SendInfoMsg(playerid, "Ukoliko vam ostanu textdrawovi i ne mozete da ih sklonite, kucajte /mobileui!");
	// Command_Call(name: telefon, args: playerid, "");
	return 1;
}

Dialog: DIALOG_PDEQUIP(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0:
		{
			SendInfoMsg(playerid, "Uzeli ste opremu za patroliranje!");
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 22, 100);
			GivePlayerWeapon(playerid, 41, 500);
			GivePlayerWeapon(playerid, 3, 1);
			SetPlayerSkin(playerid, Account_GetSkin(playerid));
		}
		
		case 1:
		{
			SendInfoMsg(playerid, "Uzeli ste opremu specijalnu opremu!");
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 22, 100);
			GivePlayerWeapon(playerid, 31, 200);
			GivePlayerWeapon(playerid, 29, 200);
			GivePlayerWeapon(playerid, 17, 200);
			SetPlayerSkin(playerid, 285);
		}

		case 2:
		{
			SendInfoMsg(playerid, "Uzeli ste opremu za snajperiste!");
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 22, 100);
			GivePlayerWeapon(playerid, 34, 100);
			SetPlayerSkin(playerid, Account_GetSkin(playerid));
		}

		case 3:
		{
			SendInfoMsg(playerid, "Uzeli ste normalnu opremu!");
			ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid, 3, 1);
			GivePlayerWeapon(playerid, 22, 100);
			GivePlayerWeapon(playerid, 3, 1);
			SetPlayerSkin(playerid, Account_GetSkin(playerid));
		}
	}
	return 1;
}

Dialog: DIALOG_BUSROUTE(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	BusDriver_SetRoute(playerid, (listitem + 1));
	Account_SetJobStarted(playerid, Account_GetJob(playerid), true);
	return 1;
}

Dialog: DIALOG_ASKQSELECT(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;
	
	if (!listitem)
		Dialog_Show(playerid, "DIALOG_ASKQSTAFF", DIALOG_STYLE_INPUT,
			D_CAPTION,
			""WHITE"Unesite pitanje koje zelite da postavite staff team-u:",
			""MAIN_COLOR"Unesi", "Izlaz"
		);
	return 1;
}

Dialog: DIALOG_REPORTSELECT(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;
	
	if (!listitem)
		Dialog_Show(playerid, "DIALOG_REPORTSTAFF", DIALOG_STYLE_INPUT,
			D_CAPTION,
			""WHITE"Unesite prijavu koju zelite da posaljete staff team-u:",
			""MAIN_COLOR"Unesi", "Izlaz"
		);
	return 1;
}

Dialog: DIALOG_ASKQSTAFF(const playerid, response, listitem, const string: inputtext[])
{
	if (!response)
		return cmd_askq(playerid, "");

	if (isnull(inputtext))
	{
		SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Morate napisati nesto, (inv/askq)!");
		return cmd_askq(playerid, "");
	}

	if (strlen(inputtext) > 128)
	{
		SendCustomMsgF(playerid, X11_RED, "ASKQ: "WHITE"Predugacak tekst, (inv/askq)!");
		return cmd_askq(playerid, "");
	}

	SendCustomMsgF(playerid, X11_YELLOW, "ASKQ: "WHITE"Poslali ste pitanje staff team-u!");
	Rank_AdminMessage(X11_YELLOW, "#Q: "WHITE"%s(%d) pita: "YELLOW"%s", ReturnPlayerName(playerid), playerid, inputtext);
	askqTimer[playerid] = (gettime() + (60 * ASKQ_TIMER_MIN));
	return 1;
}

Dialog: DIALOG_REPORTSTAFF(const playerid, response, listitem, const string: inputtext[])
{
	if (!response)
		return cmd_report(playerid, "");

	if (isnull(inputtext))
	{
		SendCustomMsgF(playerid, X11_RED, "REPORT: "WHITE"Morate napisati nesto, (inv/report)!");
		return cmd_report(playerid, "");
	}

	if (strlen(inputtext) > 128)
	{
		SendCustomMsgF(playerid, X11_RED, "REPORT: "WHITE"Predugacak tekst, (inv/report)!");
		return cmd_report(playerid, "");	
	}

	SendCustomMsgF(playerid, X11_RED, "REPORT: "WHITE"Poslali ste prijavu staff team-u!");
	Rank_AdminMessage(X11_RED, "#REPORT: "WHITE"%s(%d) prijavljuje: "RED"%s", ReturnPlayerName(playerid), playerid, inputtext);
	reportTimer[playerid] = (gettime() + (60 * ASKQ_TIMER_MIN));
	return 1;
}

Dialog: DIALOG_PLAYERHELP(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	return 1;
}

/*Dialog:DIALOG_WINTER(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    switch (listitem)
    {
    	case 0:
    	{
    		Winter_ShowSnowObjects(playerid);
    		return Command_Call(name: we, args: playerid, "");
    	}
    	
        case 1:
    	{
    		Winter_SetSnowflakeStatus(playerid);
    		return Command_Call(name: we, args: playerid, "");
    	}
    	
        case 2:
    	{
    		Winter_SetSnowCapStatus(playerid);
    		return Command_Call(name: we, args: playerid, "");
    	}
    	
        case 3:
    	{
    		Winter_SetColdBreathStatus(playerid);
    		return Command_Call(name: we, args: playerid, "");
    	}
    	
        case 4:
        {
        	Winter_SetStatusAll(playerid);
        	return Command_Call(name: we, args: playerid, "");
        }
    }
    return 1;
}*/

Dialog: DIALOG_BANK(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0:
		{
			if (!Account_GetBankMoney(playerid))
			{
				SendErrorMsg(playerid, "Nemate novca u banci!");
				cmd_banka(playerid, "");
				return 1;
			}

			Dialog_Show(playerid, "DIALOG_BANKTAKEMONEY", DIALOG_STYLE_INPUT,
				D_CAPTION,
				""MAIN_COLOR"Banka: "WHITE"Unesite koliko novca podizete:",
				""MAIN_COLOR"Potvrdi", "Izlaz"
			);
		}

		case 1:
		{
			if (!Account_GetMoney(playerid))
			{
				SendErrorMsg(playerid, "Nemate novca kod sebe!");
				cmd_banka(playerid, "");
				return 1;
			}

			Dialog_Show(playerid, "DIALOG_BANKLEAVEMONEY", DIALOG_STYLE_INPUT,
				D_CAPTION,
				""MAIN_COLOR"Banka: "WHITE"Unesite koliko novca ostavljate:",
				""MAIN_COLOR"Potvrdi", "Izlaz"
			);
		}

		case 2:
		{
			if (!Account_GetBankMoney(playerid) && !Account_GetMoney(playerid))
			{
				SendErrorMsg(playerid, "Nemate novca ni u banci ni kod sebe!");
				cmd_banka(playerid, "");
				return 1;
			}

			Dialog_Show(playerid, "DIALOG_BANKTRANSFERMONEY", DIALOG_STYLE_LIST,
				D_CAPTION,
				""WHITE"Prebaci sa bankovnog racuna\n"WHITE"Prebaci sa novcem kod sebe",
				""MAIN_COLOR"Potvrdi", "Izlaz"
			);
		}
	}
	return 1;
}

Dialog: DIALOG_BANKTAKEMONEY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_banka(playerid, "");

	if (Account_GetBankMoney(playerid) < strval(inputtext))
	{
		SendErrorMsg(playerid, "Nemate toliko novca u banci!");
		cmd_banka(playerid, "");
		return 1;
	}

	SendServerMsgF(playerid, "Podigli ste "DARKGREEN"$"WHITE"%d iz banke.", strval(inputtext));
	Account_SetBankMoney(playerid, Account_GetBankMoney(playerid) - strval(inputtext));
	Account_SetMoney(playerid, Account_GetMoney(playerid) + strval(inputtext));
	GivePlayerMoney(playerid, strval(inputtext));

	if (Atm_PanelOpened(playerid))
		Atm_DestroyUI(playerid);

	CancelSelectTextDraw(playerid);
	UI_UpdateInfoTD(playerid);
	return 1;
}

Dialog: DIALOG_BANKLEAVEMONEY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_banka(playerid, "");

	if (Account_GetMoney(playerid) < strval(inputtext))
	{
		SendErrorMsg(playerid, "Nemate toliko novca kod sebe!");
		cmd_banka(playerid, "");
		return 1;
	}

	SendServerMsgF(playerid, "Ostavili ste "DARKGREEN"$"WHITE"%d u banku.", strval(inputtext));
	Account_SetBankMoney(playerid, Account_GetBankMoney(playerid) + strval(inputtext));
	Account_SetMoney(playerid, Account_GetMoney(playerid) - strval(inputtext));
	GivePlayerMoney(playerid, -strval(inputtext));

	if (Atm_PanelOpened(playerid))
		Atm_DestroyUI(playerid);

	CancelSelectTextDraw(playerid);
	UI_UpdateInfoTD(playerid);
	return 1;
}

Dialog: DIALOG_BANKTRANSFERMONEY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_banka(playerid, "");

	switch (listitem)
	{
		case 0:
		{
			Dialog_Show(playerid, "DIALOG_TFBANKMONEY", DIALOG_STYLE_INPUT,
				D_CAPTION,
				""WHITE"Unesite kolicinu novca i id/ime igraca kojem saljete novac:",
				""MAIN_COLOR"Potvrdi", "Izlaz"
			);
		}

		case 1:
		{
			Dialog_Show(playerid, "DIALOG_TFPOCKETMONEY", DIALOG_STYLE_INPUT,
				D_CAPTION,
				""WHITE"Unesite kolicinu novca i id/ime igraca kojem saljete novac:",
				""MAIN_COLOR"Potvrdi", "Izlaz"
			);
		}
	}
	return 1;
}

Dialog: DIALOG_TFBANKMONEY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_banka(playerid, "");

	static targetid, money;
	if (sscanf(inputtext, "ir", money, targetid))
	{
		SendErrorMsg(playerid, "Unesite kolicinu novca i ID/Ime igraca kojem saljete!");
		return cmd_banka(playerid, "");
	}

	if (!IsPlayerConnected(targetid))
	{
		SendErrorMsg(playerid, "Taj korisnik nije prijavljen!");
		return cmd_banka(playerid, "");
	}

	if (Account_GetBankMoney(playerid) < money)
	{
		SendErrorMsg(playerid, "Nemate toliko novca na bankovnom racunu!");
		return cmd_banka(playerid, "");
	}

	if (!Account_GetBankCard(targetid))
	{
		SendErrorMsg(playerid, "Taj korisnik nema otvoren bankovni racun!");
		return cmd_banka(playerid, "");
	}

	SendServerMsgF(playerid, "Poslali ste "DARKGREEN"$"WHITE"%d igracu "MAIN_COLOR"%s"WHITE".", money, ReturnPlayerName(targetid));
	SendServerMsgF(playerid, "Dobili ste "DARKGREEN"$"WHITE"%d od igraca "MAIN_COLOR"%s"WHITE".", money, ReturnPlayerName(playerid));

	Account_SetBankMoney(playerid, Account_GetMoney(playerid) - money);
	Account_SetBankMoney(targetid, Account_GetBankMoney(targetid) + money);
	UI_UpdateInfoTD(playerid);
	UI_UpdateInfoTD(targetid);
	return 1;
}

Dialog: DIALOG_TFPOCKETMONEY(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_banka(playerid, "");

	static targetid, money;
	if (sscanf(inputtext, "ir", money, targetid))
	{
		SendErrorMsg(playerid, "Unesite kolicinu novca i ID/Ime igraca kojem saljete!");
		return cmd_banka(playerid, "");
	}

	if (!IsPlayerConnected(targetid))
	{
		SendErrorMsg(playerid, "Taj korisnik nije prijavljen!");
		return cmd_banka(playerid, "");
	}

	if (Account_GetMoney(playerid) < money)
	{
		SendErrorMsg(playerid, "Nemate toliko novca kod sebe!");
		return cmd_banka(playerid, "");
	}

	if (!Account_GetBankCard(targetid))
	{
		SendErrorMsg(playerid, "Taj korisnik nema otvoren bankovni racun!");
		return cmd_banka(playerid, "");
	}

	SendServerMsgF(playerid, "Poslali ste "DARKGREEN"$"WHITE"%d igracu "MAIN_COLOR"%s"WHITE".", money, ReturnPlayerName(targetid));
	SendServerMsgF(playerid, "Dobili ste "DARKGREEN"$"WHITE"%d od igraca "MAIN_COLOR"%s"WHITE".", money, ReturnPlayerName(playerid));

	Account_SetMoney(playerid, Account_GetMoney(playerid) - money);
	GivePlayerMoney(playerid, -money);
	Account_SetBankMoney(targetid, Account_GetBankMoney(targetid) + money);
	
	UI_UpdateInfoTD(playerid);
	UI_UpdateInfoTD(targetid);
	return 1;
}

Dialog: DIALOG_JOBLIST(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (isnull(inputtext) && !IsNumeric(inputtext))
		return cmd_poslovi(playerid, "");

	switch (strval(inputtext))
	{
		case 1:
		{
			SetPlayerCheckpoint(playerid, 986.8093, -1252.5247, 16.9844, 3.00);
			GameTextForPlayer(playerid, "~w~POSAO JE ~g~OZNACEN ~w~NA MAPI!", 3000, 3);
		}

		case 2:
		{
			SetPlayerCheckpoint(playerid, 940.5753, -1085.9894, 24.2962, 3.00);
			GameTextForPlayer(playerid, "~w~POSAO JE ~g~OZNACEN ~w~NA MAPI!", 3000, 3);
		}

		case 3:
		{
			SetPlayerCheckpoint(playerid, 1808.0718,-1904.3878,13.5755, 3.00);
			GameTextForPlayer(playerid, "~w~POSAO JE ~g~OZNACEN ~w~NA MAPI!", 3000, 3);
		}

		case 4:
		{
			SetPlayerCheckpoint(playerid, 2491.6658,-957.3235,82.3045, 3.00);
			GameTextForPlayer(playerid, "~w~POSAO JE ~g~OZNACEN ~w~NA MAPI!", 3000, 3);
		}
		
		default: cmd_poslovi(playerid, "");
	}
	return 1;
}

Dialog: DIALOG_SPAWNCHANGE(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0: Account_SetSpawn(playerid, 1); // normal spawn
		case 1: Account_SetSpawn(playerid, 2); // house spawn
	}
	return 1;
}