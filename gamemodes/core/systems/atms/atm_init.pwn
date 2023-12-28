const MAX_ATMS = 50;
#define ATM_PATH "/Atms/%d.ini"

enum e_ATM_DATA
{
	atmCreated,
	atmObject,
	Float:atmX,
	Float:atmY,
	Float:atmZ,
	Float:atmRotX,
	Float:atmRotY,
	Float:atmRotZ,
	atmRobbed
};

new
	AtmData[MAX_ATMS][e_ATM_DATA],
	atmPanelOpened[MAX_PLAYERS],
	PlayerText:atmTextDraw[MAX_PLAYERS][38] = {PlayerText:INVALID_PLAYER_TEXT_DRAW,...},
	atmTextDrawPinCode[MAX_PLAYERS][8],
	atmRobTimer[MAX_PLAYERS],
	atmRobSeconds[MAX_PLAYERS],
	bool:atmEditing[MAX_PLAYERS],
	atmCurrentID[MAX_PLAYERS];
	// atmRobStarted[MAX_PLAYERS];

forward Atm_Load(atmid, const name[], const value[]);
public Atm_Load(atmid, const name[], const value[])
{
    INI_Float("atmX", AtmData[atmid][atmX]);
    INI_Float("atmY", AtmData[atmid][atmY]);
    INI_Float("atmZ", AtmData[atmid][atmZ]);
    INI_Float("atmRotX", AtmData[atmid][atmRotX]);
    INI_Float("atmRotY", AtmData[atmid][atmRotY]);
    INI_Float("atmRotZ", AtmData[atmid][atmRotZ]);
	return 1;
}

hook OnGameModeInit()
{
	// atmCreated[i] = 1;
	// 	atmObject[i] = CreateDynamicObject(19324, atmX[i], atmY[i], atmZ[i], atmRotX[i], atmRotY[i], atmRotZ[i], .streamdistance = 600.00, .drawdistance = 600.00);
	// 	atmTotal++;
	for(new i; i < MAX_ATMS; i++)
	{
	    new atmFile[50];
        format(atmFile, sizeof(atmFile), ATM_PATH, i);
        if(fexist(atmFile))
        {
		    INI_ParseFile(atmFile, "Atm_Load", .bExtra = true, .extra = i);
            AtmData[i][atmObject] = CreateDynamicObject(19324, AtmData[i][atmX], AtmData[i][atmY], AtmData[i][atmZ], AtmData[i][atmRotX], AtmData[i][atmRotY], AtmData[i][atmRotZ], .streamdistance = 600.00, .drawdistance = 600.00);
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

stock Atm_CurrentID(const playerid, const atmid) return atmCurrentID[playerid] = atmid;
stock Account_SetAtmPin(const playerid, const pin) return PlayerData[playerid][pAtmPinCode] = pin;
stock Account_GetAtmPincode(const playerid) return PlayerData[playerid][pAtmPinCode];

hook OnPlayerEditDynObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if (response == EDIT_RESPONSE_FINAL)
	{
		if (atmCurrentID[playerid])
		{
			new atmid = atmCurrentID[playerid];
			if (atmid == -1)
				return 0;

			AtmData[atmid][atmX] = x;
			AtmData[atmid][atmY] = y;
			AtmData[atmid][atmZ] = z;
			AtmData[atmid][atmRotX] = rx;
			AtmData[atmid][atmRotY] = ry;
			AtmData[atmid][atmRotZ] = rz;

			Atm_Save(atmid);

			// SetDynamicObjectPos(AtmData[atmid][atmObject], AtmData[atmid][atmX], AtmData[atmid][atmY], AtmData[atmid][atmZ]);
			// SetDynamicObjectRot(AtmData[atmid][atmObject], AtmData[atmid][atmRotX], AtmData[atmid][atmRotY], AtmData[atmid][atmRotZ]);
			DestroyDynamicObject(AtmData[atmid][atmObject]);
			AtmData[atmid][atmObject] = CreateDynamicObject(19324, x, y, z, rx, ry, rz, .streamdistance = 600.00, .drawdistance = 600.00);

			SendInfoMsgF(playerid, "%s ste bankomat %d.", (Atm_GetEditingMode(playerid) ? "Azurirali" : "Kreirali"), atmid);

			if (Atm_GetEditingMode(playerid))
				Atm_SetEditingMode(playerid, false);

			atmCurrentID[playerid] = 0;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys & KEY_NO)
	{
		// new atmid = Atm_GetNearby(playerid);
		// if (atmid == Atm_GetMaxIDs())
		// 	return Y_HOOKS_BREAK_RETURN_0;
		
		if (Atm_IsPlayerNearby(playerid))
		{
			if (!Account_GetBankCard(playerid))
				return SendErrorMsg(playerid, "Nemate bankovni racun!");

			atmTextDraw[playerid][0] = CreatePlayerTextDraw(playerid, 188.700012, 137.577713, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][0], 254.000000, 221.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][0], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][0], -103);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][0], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][0], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][0], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][0], 0);

			atmTextDraw[playerid][1] = CreatePlayerTextDraw(playerid, 191.700012, 141.033218, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][1], 248.000000, 215.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][1], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][1], 52936345);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][1], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][1], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][1], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][1], 0);

			atmTextDraw[playerid][2] = CreatePlayerTextDraw(playerid, 317.000061, 142.088836, "B_A_N_K_O_M_A_T");
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][2], 0.162999, 0.784888);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][2], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][2], 255);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][2], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][2], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][2], 1);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][2], 1);

			atmTextDraw[playerid][3] = CreatePlayerTextDraw(playerid, 433.000061, 142.088836, "X");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][3], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][3], 0.296499, 1.046222);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][3], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][3], 255);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][3], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][3], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][3], 1);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][3], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][3], true);

			atmTextDraw[playerid][4] = CreatePlayerTextDraw(playerid, 204.500000, 169.311126, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][4], 110.000000, 22.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][4], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][4], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][4], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][4], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][4], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][4], 0);

			atmTextDraw[playerid][5] = CreatePlayerTextDraw(playerid, 204.500000, 169.311126, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][5], 110.000000, 22.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][5], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][5], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][5], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][5], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][5], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][5], 0);

			atmTextDraw[playerid][6] = CreatePlayerTextDraw(playerid, 208.000000, 176.933319, "UNESITE_PINKOD:");
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][6], 0.212499, 0.840888);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][6], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][6], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][6], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][6], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][6], 1);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][6], 1);

			atmTextDraw[playerid][7] = CreatePlayerTextDraw(playerid, 204.500091, 193.855651, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][7], 110.000000, 137.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][7], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][7], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][7], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][7], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][7], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][7], 0);

			atmTextDraw[playerid][8] = CreatePlayerTextDraw(playerid, 204.500091, 193.855651, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][8], 110.000000, 137.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][8], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][8], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][8], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][8], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][8], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][8], 0);

			atmTextDraw[playerid][9] = CreatePlayerTextDraw(playerid, 239.400817, 193.855651, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][9], 0.510000, 136.669631);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][9], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][9], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][9], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][9], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][9], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][9], 0);

			atmTextDraw[playerid][10] = CreatePlayerTextDraw(playerid, 278.303192, 193.855651, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][10], 0.590000, 136.900054);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][10], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][10], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][10], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][10], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][10], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][10], 0);

			atmTextDraw[playerid][11] = CreatePlayerTextDraw(playerid, 204.303192, 227.200378, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][11], 110.379867, 0.820000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][11], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][11], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][11], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][11], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][11], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][11], 0);

			atmTextDraw[playerid][12] = CreatePlayerTextDraw(playerid, 204.303192, 261.702484, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][12], 110.379867, 0.820000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][12], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][12], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][12], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][12], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][12], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][12], 0);

			atmTextDraw[playerid][13] = CreatePlayerTextDraw(playerid, 221.899902, 203.633270, "1");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][13], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][13], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][13], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][13], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][13], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][13], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][13], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][13], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][13], true);

			atmTextDraw[playerid][14] = CreatePlayerTextDraw(playerid, 258.799896, 203.811096, "2");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][14], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][14], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][14], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][14], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][14], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][14], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][14], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][14], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][14], true);

			atmTextDraw[playerid][15] = CreatePlayerTextDraw(playerid, 296.502197, 203.811096, "3");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][15], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][15], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][15], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][15], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][15], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][15], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][15], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][15], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][15], true);

			atmTextDraw[playerid][16] = CreatePlayerTextDraw(playerid, 222.102142, 238.311187, "4");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][16], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][16], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][16], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][16], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][16], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][16], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][16], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][16], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][16], true);

			atmTextDraw[playerid][17] = CreatePlayerTextDraw(playerid, 259.002288, 238.311187, "5");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][17], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][17], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][17], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][17], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][17], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][17], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][17], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][17], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][17], true);

			atmTextDraw[playerid][18] = CreatePlayerTextDraw(playerid, 296.302215, 237.688964, "6");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][18], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][18], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][18], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][18], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][18], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][18], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][18], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][18], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][18], true);

			atmTextDraw[playerid][19] = CreatePlayerTextDraw(playerid, 222.302215, 272.533447, "7");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][19], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][19], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][19], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][19], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][19], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][19], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][19], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][19], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][19], true);

			atmTextDraw[playerid][20] = CreatePlayerTextDraw(playerid, 258.802215, 272.533447, "8");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][20], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][20], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][20], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][20], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][20], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][20], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][20], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][20], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][20], true);

			atmTextDraw[playerid][21] = CreatePlayerTextDraw(playerid, 296.802215, 273.155670, "9");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][21], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][21], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][21], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][21], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][21], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][21], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][21], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][21], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][21], true);

			atmTextDraw[playerid][22] = CreatePlayerTextDraw(playerid, 203.803192, 296.267120, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][22], 110.379867, 0.820000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][22], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][22], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][22], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][22], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][22], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][22], 0);

			atmTextDraw[playerid][23] = CreatePlayerTextDraw(playerid, 221.302215, 307.377929, "<");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][23], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][23], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][23], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][23], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][23], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][23], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][23], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][23], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][23], true);

			atmTextDraw[playerid][24] = CreatePlayerTextDraw(playerid, 258.802215, 307.377929, "0");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][24], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][24], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][24], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][24], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][24], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][24], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][24], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][24], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][24], true);

			atmTextDraw[playerid][25] = CreatePlayerTextDraw(playerid, 296.802215, 307.522308, "~g~OK");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][25], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][25], 0.328999, 1.388444);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][25], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][25], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][25], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][25], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][25], 3);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][25], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][25], true);

			atmTextDraw[playerid][26] = va_CreatePlayerTextDraw(playerid, 204.000000, 333.088958, "VAS_PINKOD:%d", Account_GetAtmPincode(playerid));
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][26], 0.185000, 0.685333);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][26], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][26], 255);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][26], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][26], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][26], 1);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][26], 1);

			atmTextDraw[playerid][27] = CreatePlayerTextDraw(playerid, 326.000518, 169.633331, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][27], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][27], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][27], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][27], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][27], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][27], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][27], 0);

			atmTextDraw[playerid][28] = CreatePlayerTextDraw(playerid, 326.000518, 169.633331, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][28], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][28], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][28], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][28], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][28], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][28], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][28], 0);

			atmTextDraw[playerid][29] = CreatePlayerTextDraw(playerid, 326.000518, 202.035308, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][29], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][29], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][29], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][29], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][29], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][29], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][29], 0);

			atmTextDraw[playerid][30] = CreatePlayerTextDraw(playerid, 326.000518, 202.035308, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][30], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][30], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][30], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][30], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][30], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][30], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][30], 0);

			atmTextDraw[playerid][31] = CreatePlayerTextDraw(playerid, 326.000518, 234.637298, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][31], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][31], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][31], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][31], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][31], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][31], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][31], 0);

			atmTextDraw[playerid][32] = CreatePlayerTextDraw(playerid, 326.000518, 234.637298, "LD_SPAC:white");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][32], 105.000000, 25.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][32], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][32], 153);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][32], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][32], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][32], 4);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][32], 0);

			atmTextDraw[playerid][33] = CreatePlayerTextDraw(playerid, 377.000000, 175.444488, "OSTAVI_NOVAC");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][33], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][33], 0.209500, 1.208000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][33], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][33], X11_GRAY);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][33], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][33], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][33], 2);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][33], 1);
			// PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][33], true);

			atmTextDraw[playerid][34] = CreatePlayerTextDraw(playerid, 378.200042, 207.800079, "PODIGNI_NOVAC");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][34], 8.00, 20.00);
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][34], 0.209500, 1.208000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][34], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][34], X11_GRAY);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][34], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][34], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][34], 2);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][34], 1);
			// PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][34], true);

			atmTextDraw[playerid][35] = va_CreatePlayerTextDraw(playerid, 377.399993, 236.377960, "STANE_RACUA~n~~g~$~w~%d", Account_GetBankMoney(playerid));
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][35], 0.169500, 1.145778);
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][35], 0.000000, 159.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][35], 2);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][35], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][35], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][35], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][35], 2);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][35], 1);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][35], true);

			atmTextDraw[playerid][36] = CreatePlayerTextDraw(playerid, 284.500000, 215.977813, "");
			PlayerTextDrawTextSize(playerid, atmTextDraw[playerid][36], 188.000000, 176.000000);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][36], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][36], -1);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][36], 0);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][36], 0x00000000);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][36], 5);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][36], 0);
			PlayerTextDrawSetPreviewModel(playerid, atmTextDraw[playerid][36], 19792);
			PlayerTextDrawSetPreviewRot(playerid, atmTextDraw[playerid][36], 90.000000, 0.000000, 180.000000, 1.000000);

			atmTextDraw[playerid][37] = CreatePlayerTextDraw(playerid, 269.600036, 176.855499, "______");
			PlayerTextDrawLetterSize(playerid, atmTextDraw[playerid][37], 0.203500, 0.847110);
			PlayerTextDrawAlignment(playerid, atmTextDraw[playerid][37], 1);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][37], 1297802137);
			PlayerTextDrawSetShadow(playerid, atmTextDraw[playerid][37], 0);
			PlayerTextDrawSetOutline(playerid, atmTextDraw[playerid][37], 1);
			PlayerTextDrawBackgroundColor(playerid, atmTextDraw[playerid][37], 255);
			PlayerTextDrawFont(playerid, atmTextDraw[playerid][37], 1);
			PlayerTextDrawSetProportional(playerid, atmTextDraw[playerid][37], 1);

			for (new i = 0; i < 38; i++)
				PlayerTextDrawShow(playerid, atmTextDraw[playerid][i]);

			SelectTextDraw(playerid, X11_CYAN);
			SendInfoMsg(playerid, "Ukoliko vam ostanu textdrawovi i ne mozete da ih sklonite, kucajte /atmui!");
			atmPanelOpened[playerid] = 1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	for (new i = 13; i <= 21; i++)
	{
		if (playertextid == atmTextDraw[playerid][i])
		{
			if (strlen(atmTextDrawPinCode[playerid]) > 5)
				return 0;

			static
				tmpString[8],
				fmtString[8];

			if (isnull(atmTextDrawPinCode[playerid]))
				format(fmtString, sizeof(fmtString), "%s", itos(i - 12));

			else
			{
				strcopy(tmpString, atmTextDrawPinCode[playerid]);
				format(fmtString, sizeof(fmtString), "%s%s", tmpString, itos(i - 12));
			}

			strcopy(atmTextDrawPinCode[playerid], fmtString);
			PlayerTextDrawSetString(playerid, atmTextDraw[playerid][37], atmTextDrawPinCode[playerid]);
		}
	}

	if (playertextid == atmTextDraw[playerid][24])
	{
		static
			tmpString[8],
			fmtString[8];

		if (isnull(atmTextDrawPinCode[playerid]))
			strcopy(fmtString, "0");

		else
		{
			strcopy(tmpString, atmTextDrawPinCode[playerid]);
			format(fmtString, sizeof(fmtString), "%s0", tmpString);
		}

		strcopy(atmTextDrawPinCode[playerid], fmtString);
		PlayerTextDrawSetString(playerid, atmTextDraw[playerid][37], atmTextDrawPinCode[playerid]);
	}

	else if (playertextid == atmTextDraw[playerid][25])
	{
		if (!strcmp(atmTextDrawPinCode[playerid], itos(Account_GetAtmPincode(playerid)), false))
		{
			strcopy(atmTextDrawPinCode[playerid], "");
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][33], X11_WHITE);
			PlayerTextDrawColor(playerid, atmTextDraw[playerid][34], X11_WHITE);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][33], true);
			PlayerTextDrawSetSelectable(playerid, atmTextDraw[playerid][34], true);
			PlayerTextDrawSetString(playerid, atmTextDraw[playerid][37], "~g~TACAN");
			PlayerTextDrawShow(playerid, atmTextDraw[playerid][33]);
			PlayerTextDrawShow(playerid, atmTextDraw[playerid][34]);
		}

		else
		{
			strcopy(atmTextDrawPinCode[playerid], "");
			PlayerTextDrawSetString(playerid, atmTextDraw[playerid][37], "");
		}
	}

	else if (playertextid == atmTextDraw[playerid][23])
	{
		if (isnull(atmTextDrawPinCode[playerid]))
			return 0;

		strcopy(atmTextDrawPinCode[playerid][strlen(atmTextDrawPinCode[playerid]) - 1], "");
		PlayerTextDrawSetString(playerid, atmTextDraw[playerid][37], atmTextDrawPinCode[playerid]);
	}

	else if (playertextid == atmTextDraw[playerid][3])
	{
		CancelSelectTextDraw(playerid);
		Atm_DestroyUI(playerid);
	}

	else if (playertextid == atmTextDraw[playerid][34])
		Dialog_Show(playerid, "DIALOG_BANKTAKEMONEY", DIALOG_STYLE_INPUT,
			D_CAPTION,
			""MAIN_COLOR"Banka: "WHITE"Unesite koliko novca podizete:",
			""MAIN_COLOR"Potvrdi", "Izlaz"
		);
	
	else if (playertextid == atmTextDraw[playerid][33])
		Dialog_Show(playerid, "DIALOG_BANKLEAVEMONEY", DIALOG_STYLE_INPUT,
			D_CAPTION,
			""MAIN_COLOR"Banka: "WHITE"Unesite koliko novca ostavljate:",
			""MAIN_COLOR"Potvrdi", "Izlaz"
		);
	return Y_HOOKS_CONTINUE_RETURN_1;
}

PTASK__ ATM_Nearby[1000](playerid)
{
	new atmid = Atm_GetNearby(playerid);
	if (atmid == -1)
		return 0;

	if (!atmPanelOpened[playerid])
		UI_ShowInfoMessage(playerid, 1000, "Pritisnite ~y~'~w~N~y~' ~w~za otvaranje bankomata.");
	return 1;
}

stock Atm_PanelOpened(const playerid) return atmPanelOpened[playerid];
stock Atm_GetMaxIDs() return MAX_ATMS;
stock Atm_ReturnObject(const atmid) return AtmData[atmid][atmObject];
stock Atm_SetEditingMode(const playerid, const bool:status) return atmEditing[playerid] = status;
stock Atm_GetEditingMode(const playerid) return atmEditing[playerid];
stock Atm_Create(const atmid, Float:x, Float:y, Float:z)
{
	AtmData[atmid][atmCreated] = 1;
	AtmData[atmid][atmX] = x;
	AtmData[atmid][atmY] = y;
	AtmData[atmid][atmZ] = z;
	AtmData[atmid][atmObject] = CreateDynamicObject(19324, x, y, z, AtmData[atmid][atmRotX], AtmData[atmid][atmRotY], AtmData[atmid][atmRotZ], .streamdistance = 600.00, .drawdistance = 600.00);
	return 1;
}

stock Atm_Destroy(const atmid)
{
	AtmData[atmid][atmX] = 0.00;
	AtmData[atmid][atmY] = 0.00;
	AtmData[atmid][atmZ] = 0.00;
	AtmData[atmid][atmCreated] = 0;
	DestroyDynamicObject(AtmData[atmid][atmObject]);

	new atmFile[64];
	format(atmFile, sizeof(atmFile), ATM_PATH, atmid);
	
	if (fexist(atmFile))
		fremove(atmFile);
	return 1;
}

stock Atm_Save(atmid)
{
	new atmFile[60];
	format(atmFile, sizeof(atmFile), ATM_PATH, atmid);
	new INI:File = INI_Open(atmFile);
    INI_SetTag(File,"data");
    INI_WriteFloat(File, "atmX", AtmData[atmid][atmX]);
    INI_WriteFloat(File, "atmY", AtmData[atmid][atmY]);
    INI_WriteFloat(File, "atmZ", AtmData[atmid][atmZ]);
    INI_WriteFloat(File, "atmRotX", AtmData[atmid][atmRotX]);
    INI_WriteFloat(File, "atmRotY", AtmData[atmid][atmRotY]);
    INI_WriteFloat(File, "atmRotZ", AtmData[atmid][atmRotZ]);
    INI_Close(File);
    return 1;
}

stock Atm_Goto(const playerid, const atmid)
{
	new atmFile[32];
	format(atmFile, sizeof(atmFile), ATM_PATH, atmid);
	
	if (!fexist(atmFile))
		return 0;

    Streamer_UpdateEx(playerid, AtmData[atmid][atmX] + 4.00, AtmData[atmid][atmY], AtmData[atmid][atmZ], .compensatedtime = 2000);
    if (IsPlayerInAnyVehicle(playerid))
    {
    	new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, AtmData[atmid][atmX], AtmData[atmid][atmY] + 4.00, AtmData[atmid][atmZ]);
        PutPlayerInVehicle(playerid, vehicleid, 0);
    }
    return 1;
}

stock Atm_Robbed(const atmid)
	return (AtmData[atmid][atmRobbed] == 1 ? 1 : 0);

stock Atm_GetNextID(const len)
{
	new id = -1;
    for (new loop = 0, provjera = -1, Data_[64] = "\0"; loop != len; ++loop)
	{
		provjera = loop + 1;
		format(Data_, (sizeof Data_), ATM_PATH, provjera);
		if (!fexist(Data_))
		{
			id = provjera;
			break;
		} 
	}
  	return id;
}

stock Atm_IsPlayerNearby(const playerid)
{
	for (new i = 0; i < MAX_ATMS; i++)
		if (IsPlayerInRangeOfPoint(playerid, 3.0, AtmData[i][atmX], AtmData[i][atmY], AtmData[i][atmZ]))
			return 1;
	return 0;
}

stock Atm_GetNearby(const playerid)
{
	for (new i = 0; i < MAX_ATMS; i++)
		if (IsPlayerInRangeOfPoint(playerid, 5.0, AtmData[i][atmX], AtmData[i][atmY], AtmData[i][atmZ]))
			return i;
	return -1;
}

stock Atm_DestroyUI(const playerid)
{
	atmPanelOpened[playerid] = 0;
	strcopy(atmTextDrawPinCode[playerid], "");
	for (new i = 0; i < 38; i++)
	{
		PlayerTextDrawDestroy(playerid, atmTextDraw[playerid][i]);
		atmTextDraw[playerid][i] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
	}
	return 1;
}

forward Atm_RobProcess(const playerid, const atmid);
public Atm_RobProcess(const playerid, const atmid)
{
	atmRobSeconds[playerid]++;
	va_GameTextForPlayer(playerid, "~Y~JOS ~r~%d ~y~SEKUNDI!", 1000, 3, atmRobSeconds[playerid]);

	if (atmRobSeconds[playerid] == 10) // 120
	{
		new atmMoney = random(600000) + 200000;
		SendClientMessage(playerid, X11_GREEN, "=========================================================");
		SendCustomMsgF(playerid, X11_GREEN, "[BANKOMAT]: "WHITE"Uspesno ste opljackali bankomat %d!", atmid);
		SendCustomMsgF(playerid, X11_GREEN, "[BANKOMAT]: "WHITE"Kolicina opljackanog novca: "GREEN"$"WHITE"%d.", atmMoney);
		SendClientMessage(playerid, X11_GREEN, "[BANKOMAT]: "WHITE"Pokusajte pobeci od policije i odneti pare na odredjenu lokaciju!");
		SendClientMessage(playerid, X11_GREEN, "=========================================================");

		AtmData[atmid][atmRobbed] = 1;
		KillTimer(atmRobTimer[playerid]);
	}
	return 1;
}

stock Atm_StartRob(const playerid, const atmid)
{
	// #pragma unused playerid, atmid
	atmRobSeconds[playerid] = 0;
	SendClientMessage(playerid, X11_RED, "[BANKOMAT]: "WHITE"Zapoceli ste "RED"pljacku "WHITE"bankomata!");
	// atmRobTimer[playerid] = SetTimerEx("Atm_RobFinished", 120000, false, "di", playerid, atmid);
	atmRobTimer[playerid] = SetTimerEx("Atm_RobProcess", 1000, true, "di", playerid, atmid);
	return 1;
}