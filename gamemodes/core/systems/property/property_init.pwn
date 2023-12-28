#include <YSI_Coding\y_hooks>

const MAX_PROPERTY = 500;
#define PROPERTY_PATH "/Property/%d.ini"

enum
{
	PROPERTY_HOUSE = 1,
	PROPERTY_APARTMENT,
	PROPERTY_COTTAGE,
	PROPERTY_BUSINESS
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
	propName[64],
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
	Text3D:propertyLabel[MAX_PROPERTY];

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
	INI_String("name", PropertyData[i][propName]);
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
	INI_WriteString(File, "name", PropertyData[i][propName]);
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
				tempPickupID;

			if (PropertyData[i][propType] == PROPERTY_HOUSE)
			{
				if (!PropertyData[i][propOwned])
				{
					tempPickupID = 1272;
					format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite kucu kucajte\n"GREEN"/kupiimovinu", i, PropertyData[i][propPrice]);
				}

				else if (PropertyData[i][propOwned])
				{
					tempPickupID = 19522;
					format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d]\n"WHITE"Vlasnik: %s\nCena: $%d", i, PropertyData[i][propOwner], PropertyData[i][propPrice]);
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
	                Streamer_UpdateEx(playerid, PropertyData[i][propIntX], PropertyData[i][propIntY], PropertyData[i][propIntZ], PropertyData[i][propVW], .compensatedtime = 2000);
	            }
	            else
	                return GameTextForPlayer(playerid, "~r~ZAKLJUCANO!", 3000, 3);
	        }
	    
	        if (IsPlayerInRangeOfPoint(playerid, 2.0, PropertyData[i][propIntX], PropertyData[i][propIntY], PropertyData[i][propIntZ]) && GetPlayerVirtualWorld(playerid) == PropertyData[i][propVW])
	        {
	            SetPlayerVirtualWorld(playerid, 0);
	            Streamer_UpdateEx(playerid, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 0, .compensatedtime = 2000);
	            return 1;
	        }
        }
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
	}

	Account_SavePlayer(playerid);
	Property_Save(i);
	return 1;
}

Dialog: DIALOG_CREATEPROP(const playerid, response, listitem, string: inputtext[])
{
	if (!response)
		return 1;

	switch (listitem)
	{
		case 0:
		{
			Dialog_Show(playerid, "DIALOG_CREATEHOUSE", DIALOG_STYLE_INPUT,
				""MAIN_COLOR"Kreiranje imovine", ""WHITE"Unesite cenu kuce:",
				""MAIN_COLOR"Kreiraj", "Izlaz"
			);
		}
	}
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

	if (!(1 <= price <= 10000000))
	{
		SendErrorMsg(playerid, "Cena kuce moze biti od $1 do $10.000.000!");
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
	format(tempStr, sizeof(tempStr), ""GREEN"[KUCA - %d NA PRODAJU]\n"WHITE"Cena: $%d\nDa kupite kucu kucajte\n"GREEN"/kupikucu", i, PropertyData[i][propPrice]);
	propertyPickup[i] = CreateDynamicPickup(1272, 1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ]);
	propertyLabel[i] = CreateDynamic3DTextLabel(tempStr, -1, PropertyData[i][propExtX], PropertyData[i][propExtY], PropertyData[i][propExtZ], 10.00);

	Property_Save(i);
	SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[IMOVINA]: "WHITE"Kreirali ste kucu ID %d!", i);
	return 1;
}