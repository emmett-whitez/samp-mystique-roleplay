#include <YSI_Coding\y_hooks>

const MAX_PROPERTY = 500;
#define PROPERTY_PATH "/Property/%d.ini"

new GSWeaponsList[][][] =
{
	// name, ammo, price
	{"Digl", 50, 3200},
	{"Pancir", 1, 450},
	{"Med. kit", 1, 500},
	{"Noz", 1, 20},
	{"Palica", 1, 13},
	{"M4A1", 50, 8400},
	{"AK-47", 50, 8350},
	{"Tec-9", 50, 6320}
};

enum
{
	PROPERTY_HOUSE = 1,
	PROPERTY_APARTMENT,
	PROPERTY_COTTAGE,
	PROPERTY_BUSINESS
};

enum
{
	BUSINESS_MARKET = 1,
	BUSINESS_BURG,
	BUSINESS_GYM,
	BUSINESS_GUNSHOP,
	BUSINESS_BAR,
	BUSINESS_BINCO
};

enum e_PROPERTY_DATA
{
	propOwned,
	propOwner[MAX_PLAYER_NAME],
	propType,
	propVW,
	propInt,
	propLocked,
	propPrice,
	propIncome,
	propName[64],
	propBizName[24],
	propBizType,
	propBizInt,
	Float:propExtX,
	Float:propExtY,
	Float:propExtZ,
	Float:propIntX,
	Float:propIntY,
	Float:propIntZ
};

new
	PropertyData[MAX_PROPERTY][e_PROPERTY_DATA],
	propertyPickup[MAX_PROPERTY],
	Text3D:propertyLabel[MAX_PROPERTY],
	propertyMapIcon[MAX_PROPERTY],
	playerPropSelected[MAX_PLAYERS],
	playerPropCP[MAX_PLAYERS],
	propertyEntered[MAX_PLAYERS];

forward Property_Load(const i, const name[], const value[]);
public Property_Load(const i, const name[], const value[])
{
	INI_Int("owned", PropertyData[i][propOwned]);
	INI_String("owner", PropertyData[i][propOwner]);
	INI_Int("type", PropertyData[i][propType]);
	INI_Int("vw", PropertyData[i][propVW]);
	INI_Int("int", PropertyData[i][propInt]);
	INI_Int("locked", PropertyData[i][propLocked]);
	INI_Int("price", PropertyData[i][propPrice]);
	INI_Int("income", PropertyData[i][propIncome]);
	INI_String("name", PropertyData[i][propName]);
	INI_String("bizname", PropertyData[i][propBizName]);
	INI_Int("biztype", PropertyData[i][propBizType]);
	INI_Int("bizint", PropertyData[i][propBizInt]);
	INI_Float("extx", PropertyData[i][propExtX]);
	INI_Float("exty", PropertyData[i][propExtY]);
	INI_Float("extz", PropertyData[i][propExtZ]);
	INI_Float("intx", PropertyData[i][propIntX]);
	INI_Float("inty", PropertyData[i][propIntY]);
	INI_Float("intz", PropertyData[i][propIntZ]);
	return 1;
}

stock Property_Save(const i)
{
	new pFile[64];
	format(pFile, sizeof(pFile), PROPERTY_PATH, i);
	new INI:File = INI_Open(pFile);
	INI_SetTag(File, "propertydata");
	INI_WriteInt(File, "owned", PropertyData[i][propOwned]);
	INI_WriteString(File, "owner", PropertyData[i][propOwner]);
	INI_WriteInt(File, "type", PropertyData[i][propType]);
	INI_WriteInt(File, "vw", PropertyData[i][propVW]);
	INI_WriteInt(File, "int", PropertyData[i][propInt]);
	INI_WriteInt(File, "locked", PropertyData[i][propLocked]);
	INI_WriteInt(File, "price", PropertyData[i][propPrice]);
	INI_WriteInt(File, "income", PropertyData[i][propIncome]);
	INI_WriteString(File, "name", PropertyData[i][propName]);
	INI_WriteString(File, "bizname", PropertyData[i][propBizName]);
	INI_WriteInt(File, "biztype", PropertyData[i][propBizType]);
	INI_WriteInt(File, "bizint", PropertyData[i][propBizInt]);
	INI_WriteFloat(File, "extx", PropertyData[i][propExtX]);
	INI_WriteFloat(File, "exty", PropertyData[i][propExtY]);
	INI_WriteFloat(File, "extz", PropertyData[i][propExtZ]);
	INI_WriteFloat(File, "intx", PropertyData[i][propIntX]);
	INI_WriteFloat(File, "inty", PropertyData[i][propIntY]);
	INI_WriteFloat(File, "intz", PropertyData[i][propIntZ]);
	INI_Close(File);
	return 1;
}

stock Property_GetNextID(const len)
{
    new id = -1;
    for (new loop = 0, provjera = -1, Data_[64] = "\0"; loop != len; ++loop)
    {
        provjera = loop + 1;
        format(Data_, (sizeof Data_), PROPERTY_PATH, provjera);
        if (!fexist(Data_))
        {
            id = provjera;
            break;
        } 
    }
    return id;
}

stock Property_GetNearby(const playerid)
{
	for (new i = 1; i < MAX_PROPERTY; i++)
		if (IsPlayerInRangeOfPoint(playerid, 2.0, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]))
			return i;
	return 0;
}

stock Property_Dialog(const playerid)
{
	Dialog_Show(playerid, "DIALOG_PROPERTYPLAYER", DIALOG_STYLE_LIST, D_CAPTION,
		"Informacije\nLociraj imovinu\nProdaj imovinu drzavi\nProdaj imovinu igracu\nZakljucaj/Otkljucaj\nUzmi zaradu", ""MAIN_COLOR"Izaberi", "Izlaz"
	);
	return 1;
}

hook OnGameModeInit()
{
	for (new i = 1; i < MAX_PROPERTY; i++)
	{
		new pFile[64];
		format(pFile, sizeof(pFile), PROPERTY_PATH, i);
		if (fexist(pFile))
		{
			INI_ParseFile(pFile, "Property_Load", .bExtra = true, .extra = i);

			new
				tempStr[128],
				tempPickupID,
				tempMapIconID;

			if (PropertyData[i][propType] == PROPERTY_HOUSE)
			{
				if (!PropertyData[i][propOwned])
				{
					tempPickupID = 1272;
					tempMapIconID = 31;
					format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite kucu kucajte\n"GREEN"/kupiimovinu", i, PropertyData[i][propPrice]);
				}

				else if (PropertyData[i][propOwned])
				{
					tempPickupID = 19522;
					tempMapIconID = 32;
					format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
				}

				propertyPickup[i] = CreateDynamicPickup(tempPickupID, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
				propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
				propertyMapIcon[i] = CreateDynamicMapIcon(PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], tempMapIconID, -1, 0, 0, -1, 30.00);
			}

			else if (PropertyData[i][propType] == PROPERTY_BUSINESS)
			{
				if (!PropertyData[i][propOwned])
					format(tempStr, sizeof(tempStr), ""RED"[FIRMA - "WHITE"%s(%d) "RED"NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite firmu kucajte\n"GREEN"/kupiimovinu", PropertyData[i][propBizName], i, PropertyData[i][propPrice]);

				else if (PropertyData[i][propOwned])
					format(tempStr, sizeof(tempStr), ""RED"[FIRMA - "WHITE"%s(%d)"RED"]\n"WHITE"Vlasnik: %s\nCena: $%d", PropertyData[i][propBizName], i, PropertyData[i][propOwner], PropertyData[i][propPrice]);

				switch (PropertyData[i][propBizType])
				{
					case BUSINESS_MARKET: tempMapIconID = 56;
					case BUSINESS_BURG: tempMapIconID = 10;
					case BUSINESS_GYM: tempMapIconID = 54;
					case BUSINESS_GUNSHOP: tempMapIconID = 18;
					case BUSINESS_BAR: tempMapIconID = 49;
					case BUSINESS_BINCO: tempMapIconID = 45;
				}

				propertyPickup[i] = CreateDynamicPickup(1274, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
				propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
				propertyMapIcon[i] = CreateDynamicMapIcon(PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], tempMapIconID, -1, 0, 0, -1, 30.00);
			}

			else if (PropertyData[i][propType] == PROPERTY_APARTMENT)
			{
				if (!PropertyData[i][propOwned])
				{
					tempPickupID = 19605;
					format(tempStr, sizeof(tempStr), ""YELLOW"[STAN - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite stan kucajte\n"YELLOW"/kupiimovinu", i, PropertyData[i][propPrice]);
				}

				else if (PropertyData[i][propOwned])
				{
					tempPickupID = 19606;
					format(tempStr, sizeof(tempStr), ""YELLOW"[STAN - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
				}

				propertyPickup[i] = CreateDynamicPickup(tempPickupID, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
				propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
			}

			else if (PropertyData[i][propType] == PROPERTY_COTTAGE)
			{
				if (!PropertyData[i][propOwned])
				{
					tempPickupID = 1273;
					format(tempStr, sizeof(tempStr), ""BLUE"[VIKENDICA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite vikendicu kucajte\n"BLUE"/kupiimovinu", i, PropertyData[i][propPrice]);
				}

				else if (PropertyData[i][propOwned])
				{
					tempPickupID = 19523;
					format(tempStr, sizeof(tempStr), ""BLUE"[VIKENDICA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
				}

				propertyPickup[i] = CreateDynamicPickup(tempPickupID, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
				propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (PRESSED(KEY_SECONDARY_ATTACK))
    {
    	for (new i = 1; i < MAX_PROPERTY; i++)
    	{
	        if (IsPlayerInRangeOfPoint(playerid, 2.0, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]))
	        {
	            if (!PropertyData[i][propLocked])
	            {
	                SetPlayerVirtualWorld(playerid, PropertyData[i][propVW]);
	                SetPlayerInterior(playerid, PropertyData[i][propInt]);
	                Streamer_UpdateEx(playerid, PropertyData[i][propIntX], PropertyData[i][propIntY], PropertyData[i][propIntZ], PropertyData[i][propVW], .compensatedtime = 2000);

	                propertyEntered[playerid] = i;

	               	if (PropertyData[i][propBizType] == BUSINESS_GUNSHOP)
	               		GameTextForPlayer(playerid, "~y~/kupioruzje", 3000, 3);
	               	else if (PropertyData[i][propBizType] == BUSINESS_GYM)
	               		GameTextForPlayer(playerid, "~y~/teretana", 3000, 3);
	            }
	            else
	                return GameTextForPlayer(playerid, "~r~ZAKLJUCANO!", 3000, 3);
	        }
	    
	        if (IsPlayerInRangeOfPoint(playerid, 2.0, PropertyData[i][propIntX], PropertyData[i][propIntY], PropertyData[i][propIntZ]) && GetPlayerVirtualWorld(playerid) == PropertyData[i][propVW])
	        {
	            SetPlayerVirtualWorld(playerid, 0);
	            SetPlayerInterior(playerid, 0);
	            Streamer_UpdateEx(playerid, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 0, .compensatedtime = 2000);
	            return 1;
	        }
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerEnterDynamicCP(playerid, STREAMER_TAG_CP: checkpointid)
{
	if (checkpointid == playerPropCP[playerid])
	{
		DestroyDynamicCP(playerPropCP[playerid]);
		SendClientMessage(playerid, -1, "Stigli ste na oznacenu imovinu!");
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

CMD:kreirajimovinu(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    Dialog_Show(playerid, "DIALOG_CREATEPROP", DIALOG_STYLE_LIST,
        ""MAIN_COLOR"Kreiranje imovine", "1. Kreiraj kucu\n2. Kreiraj stan\n3. Kreiraj vikendicu\n4. Kreiraj firmu",
        ""MAIN_COLOR"Izaberi", "Izlaz"
    );
    return 1;
}

CMD:kupiimovinu(const playerid, const params[])
{
	if (Account_GetProperty(playerid, 1) && Account_GetProperty(playerid, 2) && Account_GetProperty(playerid, 3))
		return SendErrorMsg(playerid, "Imate 3 imovine, morate nesto prodati!");

	if (!Property_GetNearby(playerid))
		return SendErrorMsg(playerid, "Morate biti blizu neke imovine!");

	new i = Property_GetNearby(playerid);
	if (PropertyData[i][propOwned])
		return SendErrorMsg(playerid, "Ta imovina vec poseduje vlasnika!");

	if (Account_GetMoney(playerid) < PropertyData[i][propPrice])
		return SendErrorMsg(playerid, "Nemate dovoljno novca u dzepu!");

	if (!Account_GetProperty(playerid, 1))
		Account_SetProperty(playerid, 1, i);

	else if (!Account_GetProperty(playerid, 2))
		Account_SetProperty(playerid, 2, i);

	else if (!Account_GetProperty(playerid, 3))
		Account_SetProperty(playerid, 3, i);

	SendInfoMsg(playerid, "Uspesno ste kupili imovinu!");

	strcpy(PropertyData[i][propOwner], ReturnPlayerName(playerid));
	PropertyData[i][propOwned] = 1;

	if (PropertyData[i][propType] == PROPERTY_HOUSE)
	{
		new propUpdateStr[128];
		format(propUpdateStr, sizeof(propUpdateStr), ""GREEN"[KUCA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
		UpdateDynamic3DTextLabelText(propertyLabel[i], -1, propUpdateStr);
		DestroyDynamicPickup(propertyPickup[i]);
		propertyPickup[i] = CreateDynamicPickup(19522, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	}

	else if (PropertyData[i][propType] == PROPERTY_APARTMENT)
	{
		new propUpdateStr[128];
		format(propUpdateStr, sizeof(propUpdateStr), ""YELLOW"[STAN - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
		UpdateDynamic3DTextLabelText(propertyLabel[i], -1, propUpdateStr);
		DestroyDynamicPickup(propertyPickup[i]);
		propertyPickup[i] = CreateDynamicPickup(19606, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	}

	else if (PropertyData[i][propType] == PROPERTY_COTTAGE)
	{
		new propUpdateStr[128];
		format(propUpdateStr, sizeof(propUpdateStr), ""BLUE"[VIKENDICA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
		UpdateDynamic3DTextLabelText(propertyLabel[i], -1, propUpdateStr);
		DestroyDynamicPickup(propertyPickup[i]);
		propertyPickup[i] = CreateDynamicPickup(19523, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	}

	Account_SavePlayer(playerid);
	Property_Save(i);
	return 1;
}

CMD:imovina(const playerid, const params[])
{
	Dialog_Show(playerid, "DIALOG_PROPERTYMENU", DIALOG_STYLE_LIST, D_CAPTION, "Imovina 1\nImovina 2\nImovina 3", ""MAIN_COLOR"Izaberi", "Izlaz");
	return 1;
}

CMD:kupioruzje(const playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 20.0, 295.3026,-38.3906,1001.5156))
		return SendErrorMsg(playerid, "Morate biti u gun shopu!");

	new tempStr[256];

	for (new i = 0; i < sizeof(GSWeaponsList); i++)
		format(tempStr, sizeof(tempStr), "%s\n"WHITE"%s\t%d\t"GREEN"$%d", tempStr, GSWeaponsList[i][0][0], GSWeaponsList[i][1][0], GSWeaponsList[i][2][0]);
	
	Dialog_Show(playerid, "DIALOG_BUYWEAPON", DIALOG_STYLE_TABLIST_HEADERS, D_CAPTION,
		""WHITE"Oruzije\t"GRAY"Municija\t"GRAY"Cena\n\
		%s", ""MAIN_COLOR"Kupi", "Izlaz",
		tempStr
	);
	return 1;
}

CMD:teretana(const playerid, const params[])
{
	if (!IsPlayerInRangeOfPoint(playerid, 20.0, 774.213989,-48.924297,1000.585937))
		return SendErrorMsg(playerid, "Morate biti u teretani!");

	Dialog_Show(playerid, "DIALOG_FIGHTSTYLE", DIALOG_STYLE_LIST, D_CAPTION,
		"Normal\nBoxing\nKung Fu\nElbow\nGrab kick\nKnee head", ""MAIN_COLOR"Izaberi", "Izlaz"
	);
	return 1;
}

Dialog: DIALOG_FIGHTSTYLE(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (Account_GetMoney(playerid) < 100)
		return SendErrorMsg(playerid, "Fali vam $100 da naucite odredjenu vestinu!");

	switch (listitem)
	{
		case 0: SetPlayerFightingStyle(playerid, 4);
		case 1: SetPlayerFightingStyle(playerid, 5);
		case 2: SetPlayerFightingStyle(playerid, 6);
		case 3: SetPlayerFightingStyle(playerid, 16);
		case 4: SetPlayerFightingStyle(playerid, 15);
		case 5: SetPlayerFightingStyle(playerid, 7);
	}

	GivePlayerMoney(playerid, -100);
	Account_SetMoney(playerid, (Account_GetMoney(playerid) - 100));

	PropertyData[propertyEntered[playerid]][propIncome] += 100;
	Property_Save(propertyEntered[playerid]);
	Account_SavePlayer(playerid);
	return 1;
}

Dialog: DIALOG_BUYWEAPON(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (Account_GetMoney(playerid) < GSWeaponsList[listitem][2][0])
		return SendErrorMsg(playerid, "Nemate dovoljno novca!");

	switch (listitem)
	{
		case 0: GivePlayerWeapon(playerid, 24, GSWeaponsList[listitem][1][0]);
		case 1: SetPlayerArmour(playerid, 100.00);
		case 2: SetPlayerHealth(playerid, 100.00);
		case 3: GivePlayerWeapon(playerid, 4, GSWeaponsList[listitem][1][0]);
		case 4: GivePlayerWeapon(playerid, 5, GSWeaponsList[listitem][1][0]);
		case 5: GivePlayerWeapon(playerid, 31, GSWeaponsList[listitem][1][0]);
		case 6: GivePlayerWeapon(playerid, 30, GSWeaponsList[listitem][1][0]);
		case 7: GivePlayerWeapon(playerid, 32, GSWeaponsList[listitem][1][0]);
	}
	
	Account_SetMoney(playerid, (Account_GetMoney(playerid) - GSWeaponsList[listitem][2][0]));
	GivePlayerMoney(playerid, -GSWeaponsList[listitem][2][0]);
	va_GameTextForPlayer(playerid, "~r~-$%d", 2000, 3, GSWeaponsList[listitem][2][0]);

	PropertyData[propertyEntered[playerid]][propIncome] += GSWeaponsList[listitem][2][0];
	Property_Save(propertyEntered[playerid]);
	Account_SavePlayer(playerid);
	return 1;
}

Dialog: DIALOG_PROPERTYMENU(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (!Account_GetProperty(playerid, (listitem + 1)))
	{
		SendErrorMsg(playerid, "Nemate imovinu na tom slotu!");
		return cmd_imovina(playerid, "");
	}

	new i;

	i = (listitem == 0 ? Account_GetProperty(playerid, 1) : listitem == 1 ? Account_GetProperty(playerid, 2) :
		listitem == 2 ? Account_GetProperty(playerid, 3) : 0);

	if (!i)
		return 0;

	playerPropSelected[playerid] = i;
	Property_Dialog(playerid);
	return 1;
}

Dialog: DIALOG_PROPINFO(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_imovina(playerid, "");
	return 1;
}

Dialog: DIALOG_PROPERTYPLAYER(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_imovina(playerid, "");

	switch (listitem)
	{
		case 0:
		{
			static tmpStr[24];
			if (PropertyData[playerPropSelected[playerid]][propLocked]) { tmpStr = ""RED"Da"; }
			else { tmpStr = ""LIMEGREEN"Ne"; }

			Dialog_Show(playerid, "DIALOG_PROPINFO", DIALOG_STYLE_MSGBOX, D_CAPTION,
				""WHITE"Imovina broj %d\nVlasnik: %s\nCena imovine: "GREEN"$"WHITE"%d\n\
				"WHITE"Zakljucano: %s\n\
				"WHITE"Tip imovine: %s\n\
				"WHITE"Zarada: "GREEN"$"WHITE"%d",
				"Izlaz", "",
				playerPropSelected[playerid], PropertyData[playerPropSelected[playerid]][propOwner],
				PropertyData[playerPropSelected[playerid]][propPrice], tmpStr,
				(PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_HOUSE ? "Kuca" :
				PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_APARTMENT ? "Stan" :
				PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_BUSINESS ? "Firma" :
				PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_COTTAGE ? "Vikendica" : "N/A"),
				PropertyData[playerPropSelected[playerid]][propIncome]
			);
		}

		case 1:
		{
			if (!IsPlayerInRangeOfPoint(playerid, 800.00, PropertyData[playerPropSelected[playerid]][propExtX],
				PropertyData[playerPropSelected[playerid]][propExtY],
				PropertyData[playerPropSelected[playerid]][propExtZ])
			) return SendErrorMsg(playerid, "Previse ste odaljeni od imovine, ne mozemo je locirati!");

			GameTextForPlayer(playerid, "~y~IMOVINA OZNACENA NA RADARU!", 3000, 3);
			playerPropCP[playerid] = CreateDynamicCP(
				PropertyData[playerPropSelected[playerid]][propExtX],
				PropertyData[playerPropSelected[playerid]][propExtY],
				PropertyData[playerPropSelected[playerid]][propExtZ], 2.0,
				.playerid = playerid, .streamdistance = 800.00
			);
		}

		// case 2:
		// {
		// 	Dialog_Show(playerid, "DIALOG_PROPPRICE", DIALOG_STYLE_INPUT, D_CAPTION,
		// 		""WHITE"Unesite novu cenu imovine:", ""MAIN_COLOR"Unesi", "Izlaz"
		// 	);
		// }

		case 2:
		{
			Dialog_Show(playerid, "DIALOG_SELLPROP", DIALOG_STYLE_MSGBOX, D_CAPTION,
				""WHITE"Da li ste sigurni da zelite prodati imovinu drzavi?\n\
				"WHITE"Imovina ce biti prodata po ceni od "GREEN"$"RED"%d"WHITE"!",
				""MAIN_COLOR"Prodaj", "Izlaz", ((PropertyData[playerPropSelected[playerid]][propPrice] / 2) - 280)
			);
		}

		case 4:
		{
			SendInfoMsgF(playerid, "%s "WHITE"ste imovinu.", (PropertyData[playerPropSelected[playerid]][propLocked] == 1 ? ""LIMEGREEN"Otkljucali" : ""DARKRED"Zakljucali"));
			PropertyData[playerPropSelected[playerid]][propLocked] = !PropertyData[playerPropSelected[playerid]][propLocked];
			Property_Save(playerPropSelected[playerid]);
		}
	}
	return 1;
}

Dialog: DIALOG_SELLPROP(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return cmd_imovina(playerid, "");

	if (Account_GetProperty(playerid, 1) == playerPropSelected[playerid])
		Account_SetProperty(playerid, 1, 0);

	else if (Account_GetProperty(playerid, 2) == playerPropSelected[playerid])
		Account_SetProperty(playerid, 2, 0);

	else if (Account_GetProperty(playerid, 3) == playerPropSelected[playerid])
		Account_SetProperty(playerid, 3, 0);

	new soldPrice = ((PropertyData[playerPropSelected[playerid]][propPrice] / 2) - 280);
	SendInfoMsgF(playerid, "Prodali ste imovinu %d za "GREEN"$%d"WHITE"!", soldPrice);
	Account_SetMoney(playerid, (Account_GetMoney(playerid) + soldPrice));
	GivePlayerMoney(playerid, soldPrice);

	strcpy(PropertyData[playerPropSelected[playerid]][propOwner], "Niko");
	PropertyData[playerPropSelected[playerid]][propOwned] = 0;

	if (PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_HOUSE)
	{
		new propUpdateStr[128];
		format(propUpdateStr, sizeof(propUpdateStr), ""GREEN"[KUCA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite kucu kucajte\n"GREEN"/kupiimovinu",
			playerPropSelected[playerid], PropertyData[playerPropSelected[playerid]][propPrice]
		);
		UpdateDynamic3DTextLabelText(propertyLabel[playerPropSelected[playerid]], -1, propUpdateStr);
	}

	Property_Save(playerPropSelected[playerid]);
	Account_SavePlayer(playerid);

	playerPropSelected[playerid] = 0;
	return 1;
}

// Dialog: DIALOG_PROPPRICE(const playerid, response, listitem, string: inputtext[])
// {
// 	if (!response)
// 		return cmd_imovina(playerid, "");

// 	new price = strval(inputtext);
// 	if (!(1000 <= price <= 1000000))
// 	{
// 		SendErrorMsg(playerid, "Cena ne moze biti manja od $1.000 i veca od $1.000.000!");
// 		return cmd_imovina(playerid, "");
// 	}

// 	PropertyData[playerPropSelected[playerid]][propPrice] = price;
// 	if (PropertyData[playerPropSelected[playerid]][propType] == PROPERTY_HOUSE)
// 	{
// 		new propUpdateStr[128];
// 		format(propUpdateStr, sizeof(propUpdateStr), ""GREEN"[KUCA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d",
// 			playerPropSelected[playerid], PropertyData[playerPropSelected[playerid]][propOwner], PropertyData[playerPropSelected[playerid]][propPrice]
// 		);
// 		UpdateDynamic3DTextLabelText(propertyLabel[playerPropSelected[playerid]], -1, propUpdateStr);
// 	}

// 	SendInfoMsgF(playerid, "Promenili ste cenu imovine, nova cena je: "GREEN"$"WHITE"%d", price);
// 	Property_Save(playerPropSelected[playerid]);
// 	return 1;
// }

Dialog: DIALOG_CREATEPROP(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0:
		{
			Dialog_Show(playerid, "DIALOG_CREATEHOUSE", DIALOG_STYLE_INPUT,
				D_CAPTION, ""WHITE"Unesite cenu kuce:",
				""MAIN_COLOR"Kreiraj", "Izlaz"
			);
		}

		case 1:
		{
			Dialog_Show(playerid, "DIALOG_CREATEAPARTMENT", DIALOG_STYLE_INPUT,
				D_CAPTION, ""WHITE"Unesite cenu stana:",
				""MAIN_COLOR"Kreiraj", "Izlaz"
			);
		}

		case 2:
		{
			Dialog_Show(playerid, "DIALOG_CREATECOTTAGE", DIALOG_STYLE_INPUT,
				D_CAPTION, ""WHITE"Unesite cenu vikendice:",
				""MAIN_COLOR"Kreiraj", "Izlaz"
			);
		}

		case 3:
		{
			Dialog_Show(playerid, "DIALOG_CREATEBIZ", DIALOG_STYLE_INPUT, D_CAPTION,
				""WHITE"Unesite vrstu firme i cenu firme:\n\nVrste firmi:\n\
				"LIGHTGRAY"1. Market 2. Burg 3. Gym 4. Gunshop 5. Bar 6. Binco",
				""MAIN_COLOR"Unesi", "Izlaz"
			);
		}
	}
	return 1;
}

Dialog: DIALOG_CREATEBIZ(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	new biztype, bizprice;
	if (sscanf(inputtext, "ii", biztype, bizprice))
	{
		SendErrorMsg(playerid, "Niste dobro uneli cenu firme!");
		return cmd_kreirajimovinu(playerid, "");
	}

	if (!(1 <= biztype <= 6))
	{
		SendErrorMsg(playerid, "Niste dobro uneli vrstu firme!");
		return cmd_kreirajimovinu(playerid, "");
	}

	if (!(5000 <= bizprice <= 10000000))
	{
		SendErrorMsg(playerid, "Cena firme moze biti od $5.000 do $10.000.000!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new
		i = Property_GetNextID(MAX_PROPERTY),
		Float:x, Float:y, Float:z,
		Float:intx, Float:inty, Float:intz,
		bizName[24], tempMapIconID;

	GetPlayerPos(playerid, x, y, z);
	PropertyData[i][propType] = PROPERTY_BUSINESS;
	PropertyData[i][propBizType] = biztype;
	PropertyData[i][propPrice] = bizprice;
	PropertyData[i][propExtX] = x;
	PropertyData[i][propExtY] = y;
	PropertyData[i][propExtZ] = z;
	PropertyData[i][propOwned] = 0;
	PropertyData[i][propVW] = i;
	PropertyData[i][propLocked] = 0;
	strcpy(PropertyData[i][propOwner], "Niko");

	switch (PropertyData[i][propBizType])
	{
		case BUSINESS_MARKET:
		{
			bizName = "Market 24/7";
			tempMapIconID = 56;
			intx = -27.312299, inty = -29.277599, intz = 1003.557250;
			PropertyData[i][propInt] = 16;
		}

		case BUSINESS_BURG:
		{
			bizName = "Burg";
			tempMapIconID = 10;
			intx = 365.3115, inty = -10.8708, intz = 1001.8516;
			PropertyData[i][propInt] = 9;
		}

		case BUSINESS_GYM:
		{
			bizName = "Gym";
			tempMapIconID = 54;
			intx = 774.213989, inty = -48.924297, intz = 1000.585937;
			PropertyData[i][propInt] = 6;
		}

		case BUSINESS_GUNSHOP:
		{
			bizName = "Gunshop";
			tempMapIconID = 18;
			intx = 286.148986, inty = -40.644397, intz = 1001.515625;
			PropertyData[i][propInt] = 1;
		}

		case BUSINESS_BAR:
		{
			bizName = "Bar";
			tempMapIconID = 49;
			intx = 501.980987, inty = -69.150199, intz = 998.757812;
			PropertyData[i][propInt] = 11;
		}

		case BUSINESS_BINCO:
		{
			bizName = "Binco";
			tempMapIconID = 45;
			intx = 207.737991, inty = -109.019996, intz = 1005.132812;
			PropertyData[i][propInt] = 15;
		}
	}

	PropertyData[i][propIntX] = intx;
	PropertyData[i][propIntY] = inty;
	PropertyData[i][propIntZ] = intz;
	strcpy(PropertyData[i][propBizName], bizName);

	new tempStr[128];
	format(tempStr, sizeof(tempStr), ""RED"[FIRMA - "WHITE"%s(%d) "RED"NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite firmu kucajte\n"GREEN"/kupiimovinu", bizName, i, PropertyData[i][propPrice]);
	propertyPickup[i] = CreateDynamicPickup(1274, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
	propertyMapIcon[i] = CreateDynamicMapIcon(PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], tempMapIconID, -1, 0, 0, -1, 30.00);

	Property_Save(i);
	SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[IMOVINA]: "WHITE"Kreirali ste imovinu (firmu - %s) ID %d!", bizName, i);
	return 1;
}

Dialog: DIALOG_CREATEHOUSE(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (isnull(inputtext) && !IsNumeric(inputtext))
	{
		SendErrorMsg(playerid, "Niste dobro uneli cenu kuce!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new price = strval(inputtext);

	if (!(5000 <= price <= 10000000))
	{
		SendErrorMsg(playerid, "Cena kuce moze biti od $5.000 do $10.000.000!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new
		i = Property_GetNextID(MAX_PROPERTY),
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	PropertyData[i][propType] = PROPERTY_HOUSE;
	PropertyData[i][propPrice] = price;
	PropertyData[i][propExtX] = x;
	PropertyData[i][propExtY] = y;
	PropertyData[i][propExtZ] = z;
	PropertyData[i][propIntX] = -277.4879;
	PropertyData[i][propIntY] = 1584.5845;
	PropertyData[i][propIntZ] = 462.7619;
	PropertyData[i][propOwned] = 0;
	PropertyData[i][propInt] = 0;
	PropertyData[i][propVW] = i;
	PropertyData[i][propLocked] = 0;
	strcpy(PropertyData[i][propOwner], "Niko");

	new tempStr[128];
	format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite kucu kucajte\n"GREEN"/kupiimovinu", i, PropertyData[i][propPrice]);
	propertyPickup[i] = CreateDynamicPickup(1272, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);
	propertyMapIcon[i] = CreateDynamicMapIcon(PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 31, -1, 0, 0, -1, 30.00);

	Property_Save(i);
	SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[IMOVINA]: "WHITE"Kreirali ste imovinu ID %d!", i);
	return 1;
}

Dialog: DIALOG_CREATEAPARTMENT(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (isnull(inputtext) && !IsNumeric(inputtext))
	{
		SendErrorMsg(playerid, "Niste dobro uneli cenu stana!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new price = strval(inputtext);

	if (!(1000 <= price <= 10000000))
	{
		SendErrorMsg(playerid, "Cena stana moze biti od $1.000 do $10.000.000!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new
		i = Property_GetNextID(MAX_PROPERTY),
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	PropertyData[i][propType] = PROPERTY_APARTMENT;
	PropertyData[i][propPrice] = price;
	PropertyData[i][propExtX] = x;
	PropertyData[i][propExtY] = y;
	PropertyData[i][propExtZ] = z;
	PropertyData[i][propIntX] = 2196.85;
	PropertyData[i][propIntY] = -1204.25;
	PropertyData[i][propIntZ] = 1049.02;
	PropertyData[i][propOwned] = 0;
	PropertyData[i][propInt] = 6;
	PropertyData[i][propVW] = i;
	PropertyData[i][propLocked] = 0;
	strcpy(PropertyData[i][propOwner], "Niko");

	new tempStr[128];
	format(tempStr, sizeof(tempStr), ""YELLOW"[STAN - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite stan kucajte\n"YELLOW"/kupiimovinu", i, PropertyData[i][propPrice]);
	propertyPickup[i] = CreateDynamicPickup(19605, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);

	Property_Save(i);
	SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[IMOVINA]: "WHITE"Kreirali ste imovinu ID %d!", i);
	return 1;
}

Dialog: DIALOG_CREATECOTTAGE(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	if (isnull(inputtext) && !IsNumeric(inputtext))
	{
		SendErrorMsg(playerid, "Niste dobro uneli cenu vikendice!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new price = strval(inputtext);

	if (!(1000 <= price <= 10000000))
	{
		SendErrorMsg(playerid, "Cena vikendice moze biti od $1.000 do $10.000.000!");
		return cmd_kreirajimovinu(playerid, "");
	}

	new
		i = Property_GetNextID(MAX_PROPERTY),
		Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	PropertyData[i][propType] = PROPERTY_COTTAGE;
	PropertyData[i][propPrice] = price;
	PropertyData[i][propExtX] = x;
	PropertyData[i][propExtY] = y;
	PropertyData[i][propExtZ] = z;
	PropertyData[i][propIntX] = -42.59;
	PropertyData[i][propIntY] = 1405.47;
	PropertyData[i][propIntZ] = 1084.43;
	PropertyData[i][propOwned] = 0;
	PropertyData[i][propInt] = 8;
	PropertyData[i][propVW] = i;
	PropertyData[i][propLocked] = 0;
	strcpy(PropertyData[i][propOwner], "Niko");

	new tempStr[128];
	format(tempStr, sizeof(tempStr), ""BLUE"[VIKENDICA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite vikendicu kucajte\n"BLUE"/kupiimovinu", i, PropertyData[i][propPrice]);
	propertyPickup[i] = CreateDynamicPickup(1273, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);

	Property_Save(i);
	SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[IMOVINA]: "WHITE"Kreirali ste imovinu ID %d!", i);
	return 1;
}