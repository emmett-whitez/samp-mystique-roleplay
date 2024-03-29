#if defined _INC_vehicle_init_inc
    #endinput
#endif
#define _INC_vehicle_init_inc

#include <YSI_Coding\y_hooks>

#if defined MAX_VEHICLES
    #undef MAX_VEHICLES
#endif

const MAX_VEHICLES = 500;
#define VEHICLES_PATH "/Vehicles/%d.ini"

enum e_VEHICLE_DATA
{
    vehicleCreated,
    vehicleModel,
    vehicleLocked,
    vehicleModelID,
    vehicleOwner[MAX_PLAYER_NAME],
    vehicleOwned,
    Text3D:vehicleLabel,
    Float:vehiclePosX,
    Float:vehiclePosY,
    Float:vehiclePosZ,
    Float:vehiclePosA,
    vehicleColor[2]
};

#define Vehicle_Owner(%0) VehicleData[%0][vehicleOwner]

new
    VehicleData[MAX_VEHICLES][e_VEHICLE_DATA],
    PlayerText:vehicleCOSUI[MAX_PLAYERS][32] = {PlayerText:INVALID_PLAYER_TEXT_DRAW,...},
    vehicleViewingCatalogue[MAX_PLAYERS],
    vehicleCatalogueID[MAX_PLAYERS],
    vehicleCatalogueColor[MAX_PLAYERS],
    // vehiclePlayerID[MAX_PLAYERS][10 char],
    vehicleWindowStatus[MAX_VEHICLES][4],
    vehicleDoorStatus[MAX_VEHICLES][4],
    vehicleBootStatus[MAX_VEHICLES],
    vehicleBonnetStatus[MAX_VEHICLES],
    vehiclePlayerID[MAX_PLAYERS][3],
    vehicleCarDoors[MAX_PLAYERS][4],
    vehicleCarWindows[MAX_PLAYERS][4],
    vehicleCarBonnet[MAX_PLAYERS],
    vehicleCarBoot[MAX_PLAYERS],
    vehicleSelectedCMD[MAX_PLAYERS];

static const vehicleCarList[][][] =
{
    // vehicleid        name              price
    {400,           "Landstalker",       70000},
    {401,           "Bravura",           45000},
    {402,           "Buffalo",           170000},
    {404,           "Perenniel",         60000},
    {405,           "Sentinel",          55000},
    {410,           "Manana",            30000},
    {411,           "Infernus",          3200000},
    {412,           "Voodoo",            100000},
    {415,           "Cheetah",           1200000},
    {419,           "Esperanto",         130000},
    {421,           "Washington",        70000},
    {422,           "Bobcat",            110000},
    {426,           "Premier",           80000},
    {429,           "Banshee",           1600000},
    {436,           "Previon",           50000},
    {439,           "Stallion",          90000},
    {442,           "Romero",            110000},
    {445,           "Admiral",           75000},
    {451,           "Turismo",           2800000},
    {458,           "Solair",            250000},
    {466,           "Glendale",          120000},
    {467,           "Oceanic",           115000},
    {474,           "Hermes",            105000},
    {475,           "Sabre",             1700000},
    {477,           "ZR-350",            100000},
    {478,           "Walton",            95000},
    {479,           "Regina",            750000},
    {480,           "Comet",             120000},
    {491,           "Virgo",             320000},
    {492,           "Greenwood",         260000},
    {496,           "Blista",            130000},
    {500,           "Mesa",              105000},
    {504,           "Bloodring",         210000},
    {505,           "Rancher",           950000},
    {506,           "Super",             2200000},
    {507,           "Elegant",           205000},
    {516,           "Nebula",            80000},
    {517,           "Majestic",          110000},
    {518,           "Buccaneer",         235000},
    {526,           "Fortune",           100000},
    {527,           "Cadrona",           125000},
    {529,           "Willard",           120000},
    {533,           "Feltzer",           260000},
    {534,           "Remington",         1650000},
    {535,           "Slamvan",           450000},
    {536,           "Blade",             350000},
    {540,           "Vincent",           140000},
    {541,           "Bullet",            2850000},
    {542,           "Clover",            125000},
    {543,           "Sadler",            430000},
    {545,           "Hustler",           750000},
    {546,           "Intruder",          245000},
    {547,           "Primo",             230000},
    {549,           "Tampa",             315000},
    {550,           "Sunrise",           270000},
    {551,           "Merit",             255000},
    {554,           "Yosemite",          620000},
    {555,           "Windsor",           520000},
    {558,           "Uranus",            630000},
    {559,           "Jester",            1105000},
    {560,           "Sultan",            2750000},
    {561,           "Stratum",           635000},
    {562,           "Elegy",             990000},
    {565,           "Flash",             810000},
    {566,           "Tahoma",            430000},
    {567,           "Savanna",           870000},
    {575,           "Broadway",          210000},
    {576,           "Tornado",           315000},
    {579,           "Huntley",           2350000},
    {580,           "Stafford",          830000},
    {585,           "Emperor",           170000},
    {587,           "Euros",             845000},
    {589,           "Club",              420000},
    {600,           "Picador",           175000},
    {602,           "Alpha",             620000},
    {603,           "Phoenix",           920000}
};

static const Float:vehicleSpawnPos[][] =
{
    {1767.4423, -1710.7500, 12.9980, 58.7620},
    {1766.6871, -1705.2449, 12.9979, 59.7773},
    {1767.6594, -1701.3063, 12.9989, 59.3259},
    {1767.5006, -1696.9180, 12.9983, 59.8605},
    {1767.1031, -1691.9310, 12.9979, 57.3695},
    {1766.9424, -1687.1683, 12.9983, 60.8563},
    {1758.9104, -1688.3905, 12.9981, 121.6640},
    {1758.8431, -1692.4064, 12.9981, 120.9781},
    {1759.5986, -1696.6498, 12.9984, 116.6251},
    {1758.7528, -1701.0427, 12.9978, 121.0070},
    {1759.2776, -1705.8418, 12.9974, 117.7861},
    {1759.6179, -1710.6254, 12.9984, 112.1243}
};

forward Vehicle_Load(vehicleid, const name[], const value[]);
public Vehicle_Load(vehicleid, const name[], const value[])
{
    INI_Int("vehicleModel", VehicleData[vehicleid][vehicleModel]);
    INI_Int("vehicleLocked", VehicleData[vehicleid][vehicleLocked]);
    INI_Int("vehicleModelID", VehicleData[vehicleid][vehicleModelID]);
    INI_String("vehicleOwner", VehicleData[vehicleid][vehicleOwner]);
    INI_Int("vehicleOwned", VehicleData[vehicleid][vehicleOwned]);
    INI_Float("vehiclePosX", VehicleData[vehicleid][vehiclePosX]);
    INI_Float("vehiclePosY", VehicleData[vehicleid][vehiclePosY]);
    INI_Float("vehiclePosZ", VehicleData[vehicleid][vehiclePosZ]);
    INI_Float("vehiclePosA", VehicleData[vehicleid][vehiclePosA]);
    INI_Int("vehicleColor1", VehicleData[vehicleid][vehicleColor][0]);
    INI_Int("vehicleColor2", VehicleData[vehicleid][vehicleColor][1]);
    return 1;
}

stock Vehicle_GetModel(vehicleid) return VehicleData[vehicleid][vehicleModel];
stock Vehicle_Save(vehicleid)
{
    new atmFile[60];
    format(atmFile, sizeof(atmFile), VEHICLES_PATH, vehicleid);
    new INI:File = INI_Open(atmFile);
    INI_SetTag(File,"data");
    INI_WriteInt(File, "vehicleModel", VehicleData[vehicleid][vehicleModel]);
    INI_WriteInt(File, "vehicleLocked", VehicleData[vehicleid][vehicleLocked]);
    INI_WriteInt(File, "vehicleModelID", VehicleData[vehicleid][vehicleModelID]);
    INI_WriteString(File, "vehicleOwner", VehicleData[vehicleid][vehicleOwner]);
    INI_WriteInt(File, "vehicleOwned", VehicleData[vehicleid][vehicleOwned]);
    INI_WriteFloat(File, "vehiclePosX", VehicleData[vehicleid][vehiclePosX]);
    INI_WriteFloat(File, "vehiclePosY", VehicleData[vehicleid][vehiclePosY]);
    INI_WriteFloat(File, "vehiclePosZ", VehicleData[vehicleid][vehiclePosZ]);
    INI_WriteFloat(File, "vehiclePosA", VehicleData[vehicleid][vehiclePosA]);
    INI_WriteInt(File, "vehicleColor1", VehicleData[vehicleid][vehicleColor][0]);
    INI_WriteInt(File, "vehicleColor2", VehicleData[vehicleid][vehicleColor][1]);
    INI_Close(File);
    return 1;
}

// stock Selection_ListCars(const playerid)
// {
//     static tmpString[128];
//     // format(tmpString, sizeof(tmpString), "%s\n%s", tmpString, Vehicle_GetModelName(Vehicle_GetPlayerModelID(playerid, i)));

//     if (Account_)

//     Dialog_Show(playerid, "DIALOG_VEHICLESELECT", DIALOG_STYLE_LIST,
//         ""MAIN_COLOR"gta-world - "WHITE"VOZILO",
//         tmpString, ""MAIN_COLOR"Odaberi", "Izlaz"
//     );
//     return 1;
// }

hook OnGameModeInit()
{
    for(new i; i < MAX_VEHICLES; i++)
    {
        new atmFile[50], tmpString[512];
        format(atmFile, sizeof(atmFile), VEHICLES_PATH, i);
        if(fexist(atmFile))
        {
            INI_ParseFile(atmFile, "Vehicle_Load", .bExtra = true, .extra = i);
            
            format(tmpString, sizeof(tmpString), "Vlasnik vozila: "WHITE"%s", VehicleData[i][vehicleOwner]);
            VehicleData[i][vehicleModel] = CreateVehicle(VehicleData[i][vehicleModelID],
                VehicleData[i][vehiclePosX], VehicleData[i][vehiclePosY], VehicleData[i][vehiclePosZ], VehicleData[i][vehiclePosA],
                VehicleData[i][vehicleColor][0], VehicleData[i][vehicleColor][1], (60 * 60)
            );
            
            VehicleData[i][vehicleLabel] = CreateDynamic3DTextLabel(tmpString, MAIN_COLOR_HEX,
                VehicleData[i][vehiclePosX], VehicleData[i][vehiclePosY], VehicleData[i][vehiclePosZ] + 1.00, 60.00,
                .attachedvehicle = VehicleData[i][vehicleModel]
            );

            Vehicle_SetColor(VehicleData[i][vehicleModel], VehicleData[i][vehicleColor][0], VehicleData[i][vehicleColor][1]);

            VehicleData[i][vehicleCreated] = 1;

            Vehicle_SetFuel(VehicleData[i][vehicleModel], 50);
            Vehicle_SetColor(VehicleData[i][vehicleModel], VehicleData[i][vehicleColor][0], VehicleData[i][vehicleColor][1]);
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerConnect(playerid)
{
    vehicleWindowStatus[playerid][0] =
    vehicleWindowStatus[playerid][1] =
    vehicleWindowStatus[playerid][2] =
    vehicleWindowStatus[playerid][3] = 0;
    // vehicleDoorStatus[playerid][0] =
    // vehicleDoorStatus[playerid][1] =
    // vehicleDoorStatus[playerid][2] =
    // vehicleDoorStatus[playerid][3] = 0;
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        if (Vehicle_Valid(GetPlayerVehicleID(playerid)))
        {
            new vehid = Vehicle_ReturnID(playerid);
            if (strcmp(VehicleData[vehid][vehicleOwner], ReturnPlayerName(playerid), false) && VehicleData[vehid][vehicleLocked])
            {
                UI_ShowInfoMessage(playerid, 3000, "To vozilo je ~r~zakljucano~w~!");
                return ClearAnimations(playerid);
            }

            if (!strcmp(VehicleData[vehid][vehicleOwner], ReturnPlayerName(playerid), false) && VehicleData[vehid][vehicleLocked])
            {
                UI_ShowInfoMessage(playerid, 3000, "Usli ste u ~g~vase ~w~vozilo!");
                return 1;
            }

            if (!strcmp(VehicleData[vehid][vehicleOwner], "Niko", false))
            {
                UI_ShowInfoMessage(playerid, 3000, "To vozilo je na prodaju, da kupite - /kupivozilo.");
                return 1;
            }
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (newkeys & KEY_NO)
    {
        if (IsPlayerInRangeOfPoint(playerid, 2.0, 1788.1265, -1693.5515, 13.4305))
            Vehicle_CreateCOSUI(playerid, true);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
    if (playertextid == vehicleCOSUI[playerid][13])
    {
        vehicleCatalogueID[playerid] = 0;
        Vehicle_CreateCOSUI(playerid, false);
    }

    else if (playertextid == vehicleCOSUI[playerid][14])
    {
        vehicleCatalogueColor[playerid] = 3; // red
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][15])
    {
        vehicleCatalogueColor[playerid] = 194; // yellow
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][16])
    {
        vehicleCatalogueColor[playerid] = 222; // orange
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][17])
    {
        vehicleCatalogueColor[playerid] = 243; // green
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][18])
    {
        vehicleCatalogueColor[playerid] = 0; // black
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][19])
    {
        vehicleCatalogueColor[playerid] = 152; // blue
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);
    }

    else if (playertextid == vehicleCOSUI[playerid][10])
    {
        if (vehicleCatalogueID[playerid] == (sizeof(vehicleCarList) - 1))
            return SendErrorMsg(playerid, "Nemamo vise vozila u ponudi!");

        vehicleCatalogueColor[playerid] = 1;
        vehicleCatalogueID[playerid]++;

        PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][11], vehicleCarList[vehicleCatalogueID[playerid]][0][0]);
        PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][12], vehicleCarList[vehicleCatalogueID[playerid]][0][0]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);

        va_PlayerTextDrawSetString(playerid, vehicleCOSUI[playerid][30], "%s", vehicleCarList[vehicleCatalogueID[playerid]][1][0]);
        va_PlayerTextDrawSetString(playerid, vehicleCOSUI[playerid][31], "$%d", vehicleCarList[vehicleCatalogueID[playerid]][2][0]);
    }

    else if (playertextid == vehicleCOSUI[playerid][9])
    {
        if (vehicleCatalogueID[playerid] == 0)
            return SendErrorMsg(playerid, "Na prvoj ste stranici!");

        vehicleCatalogueColor[playerid] = 1;
        vehicleCatalogueID[playerid]--;

        PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][11], vehicleCarList[vehicleCatalogueID[playerid]][0][0]);
        PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][12], vehicleCarList[vehicleCatalogueID[playerid]][0][0]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][11]);
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][12]);

        va_PlayerTextDrawSetString(playerid, vehicleCOSUI[playerid][30], "%s", vehicleCarList[vehicleCatalogueID[playerid]][1][0]);
        va_PlayerTextDrawSetString(playerid, vehicleCOSUI[playerid][31], "$%d", vehicleCarList[vehicleCatalogueID[playerid]][2][0]);
    }

    else if (playertextid == vehicleCOSUI[playerid][21])
    {
        if (Account_GetMoney(playerid) < vehicleCarList[vehicleCatalogueID[playerid]][2][0])
            return SendErrorMsg(playerid, "Nemate dovoljno novca!");

        Dialog_Show(playerid, "DIALOG_VEHCONFIRMBUY", DIALOG_STYLE_MSGBOX,
            ""MAIN_COLOR"GENERATIONZ - "WHITE"KUPOVINA VOZILA",
            ""WHITE"Da li ste sigurni da zelite da kupite \""MAIN_COLOR"%s"WHITE"\"?",
            ""MAIN_COLOR"Kupi", "Izlaz", vehicleCarList[vehicleCatalogueID[playerid]][1][0]
        );
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock Account_SetCar(const playerid, const index, const value)
{
    switch (index)
    {
        case 1: PlayerData[playerid][pCar1] = value;
        case 2: PlayerData[playerid][pCar2] = value;
    }
    return 1;
}

stock Account_GetCar(const playerid, const index)
{
    switch (index)
    {
        case 1: return PlayerData[playerid][pCar1];
        case 2: return PlayerData[playerid][pCar2];
        default: return 0;
    }
    return 0;
}
stock Vehicle_ViewingCatalogue(const playerid) return vehicleViewingCatalogue[playerid];
stock Vehicle_SetViewingCatalogue(const playerid, const value) return vehicleViewingCatalogue[playerid] = value;
stock Vehicle_CreateCOSUI(const playerid, bool:status)
{
    if (!status)
    {
        for (new i = 0; i < 32; i++)
        {
            PlayerTextDrawDestroy(playerid, vehicleCOSUI[playerid][i]);
            vehicleCOSUI[playerid][i] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
        }

        CancelSelectTextDraw(playerid);
        Vehicle_SetViewingCatalogue(playerid, 0);
        return 1;
    }

    vehicleCOSUI[playerid][0] = CreatePlayerTextDraw(playerid, -14.000000, -18.599990, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][0], 748.000000, 139.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][0], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][0], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][0], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][0], 0);

    vehicleCOSUI[playerid][1] = CreatePlayerTextDraw(playerid, -19.500000, 331.088989, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][1], 748.000000, 139.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][1], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][1], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][1], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][1], 0);

    vehicleCOSUI[playerid][2] = CreatePlayerTextDraw(playerid, -7.000000, 119.533294, "box");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][2], 781.000000, 214.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][2], 1);
    PlayerTextDrawBoxColor(playerid, vehicleCOSUI[playerid][2], 80);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][2], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][2], 0);

    vehicleCOSUI[playerid][3] = CreatePlayerTextDraw(playerid, -7.000000, 119.533294, "box");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][3], 781.000000, 214.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][3], 1);
    PlayerTextDrawBoxColor(playerid, vehicleCOSUI[playerid][3], 80);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][3], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][3], 0);

    vehicleCOSUI[playerid][4] = CreatePlayerTextDraw(playerid, 178.500000, 141.955871, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][4], 287.000000, 155.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][4], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][4], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][4], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][4], 0);

    vehicleCOSUI[playerid][5] = CreatePlayerTextDraw(playerid, 178.399993, 143.655975, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][5], 287.180175, 152.079406);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][5], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][5], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][5], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][5], 0);

    vehicleCOSUI[playerid][6] = CreatePlayerTextDraw(playerid, 321.900146, 144.299896, "SALON VOZILA - KATALOG");
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][6], 0.176000, 0.623111);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][6], 0.000000, 260.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][6], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][6], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][6], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][6], 1);

    vehicleCOSUI[playerid][7] = CreatePlayerTextDraw(playerid, 363.000000, 156.244415, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][7], 98.000000, 97.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][7], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][7], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][7], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][7], 0);

    vehicleCOSUI[playerid][8] = CreatePlayerTextDraw(playerid, 363.000000, 254.911193, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][8], 97.969993, 35.150142);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][8], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][8], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][8], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][8], 0);

    vehicleCOSUI[playerid][9] = CreatePlayerTextDraw(playerid, 376.000000, 261.399993, "LD_BEAT:LEFT");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][9], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][9], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][9], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][9], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][9], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][9], true);

    vehicleCOSUI[playerid][10] = CreatePlayerTextDraw(playerid, 428.303192, 261.399993, "LD_BEAT:RIGHT");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][10], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][10], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][10], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][10], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][10], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][10], true);

    vehicleCOSUI[playerid][11] = CreatePlayerTextDraw(playerid, 362.500000, 134.466644, "");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][11], 79.000000, 85.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][11], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][11], 0x00000000);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][11], 5);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][11], 0);
    PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][11], 400);
    PlayerTextDrawSetPreviewRot(playerid, vehicleCOSUI[playerid][11], -10.000000, 0.000000, -25.000000, 1.000000);
    PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][11], 1, 1);

    vehicleCOSUI[playerid][12] = CreatePlayerTextDraw(playerid, 381.500000, 180.511108, "");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][12], 79.000000, 85.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][12], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][12], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][12], 0x00000000);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][12], 5);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][12], 0);
    PlayerTextDrawSetPreviewModel(playerid, vehicleCOSUI[playerid][12], 400);
    PlayerTextDrawSetPreviewRot(playerid, vehicleCOSUI[playerid][12], -10.000000, 0.000000, -140.000000, 1.000000);
    PlayerTextDrawSetPreviewVehCol(playerid, vehicleCOSUI[playerid][12], 1, 1);

    vehicleCOSUI[playerid][13] = CreatePlayerTextDraw(playerid, 451.100036, 138.844650, "ZATVORI");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][13], 8.00, 20.00);
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][13], 0.196000, 0.691555);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][13], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][13], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][13], 0);
    PlayerTextDrawSetOutline(playerid, vehicleCOSUI[playerid][13], 1);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][13], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][13], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][13], 1);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][13], true);

    vehicleCOSUI[playerid][14] = CreatePlayerTextDraw(playerid, 335.000000, 156.244430, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][14], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][14], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][14], -16776961);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][14], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][14], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][14], true);

    vehicleCOSUI[playerid][15] = CreatePlayerTextDraw(playerid, 335.000000, 225.669845, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][15], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][15], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][15], -65281);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][15], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][15], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][15], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][15], true);

    vehicleCOSUI[playerid][16] = CreatePlayerTextDraw(playerid, 335.000000, 190.567703, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][16], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][16], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][16], -5963521);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][16], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][16], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][16], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][16], true);

    vehicleCOSUI[playerid][17] = CreatePlayerTextDraw(playerid, 301.697967, 225.669845, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][17], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][17], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][17], 8388863);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][17], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][17], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][17], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][17], true);

    vehicleCOSUI[playerid][18] = CreatePlayerTextDraw(playerid, 301.697967, 190.667709, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][18], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][18], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][18], 286331391);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][18], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][18], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][18], true);

    vehicleCOSUI[playerid][19] = CreatePlayerTextDraw(playerid, 301.697967, 156.365615, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][19], 26.000000, 27.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][19], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][19], 7393535);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][19], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][19], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][19], 0);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][19], true);

    vehicleCOSUI[playerid][20] = CreatePlayerTextDraw(playerid, 302.000000, 254.555572, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][20], 59.390102, 35.519912);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][20], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][20], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][20], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][20], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][20], 0);

    vehicleCOSUI[playerid][21] = CreatePlayerTextDraw(playerid, 331.000000, 265.288940, "KUPI");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][21], 8.00, 20.00);
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][21], 0.359999, 1.376000);
    // PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][21], 0.000000, -3.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][21], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][21], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][21], 0);
    PlayerTextDrawSetOutline(playerid, vehicleCOSUI[playerid][21], 1);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][21], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][21], 2);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][21], 1);
    PlayerTextDrawSetSelectable(playerid, vehicleCOSUI[playerid][21], true);

    vehicleCOSUI[playerid][22] = CreatePlayerTextDraw(playerid, 330.599945, 155.622222, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][22], 0.790000, 103.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][22], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][22], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][22], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][22], 0);

    vehicleCOSUI[playerid][23] = CreatePlayerTextDraw(playerid, 301.799926, 221.000000, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][23], 65.000000, 1.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][23], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][23], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][23], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][23], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][23], 0);

    vehicleCOSUI[playerid][24] = CreatePlayerTextDraw(playerid, 301.999908, 186.099884, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][24], 65.000000, 1.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][24], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][24], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][24], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][24], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][24], 0);

    vehicleCOSUI[playerid][25] = CreatePlayerTextDraw(playerid, 191.500000, 164.488830, "PRICE");
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][25], 0.138499, 0.697777);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][25], 272.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][25], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][25], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][25], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][25], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][25], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][25], 1);

    vehicleCOSUI[playerid][26] = CreatePlayerTextDraw(playerid, 269.104736, 164.388824, "VEHICLE");
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][26], 0.138499, 0.697777);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][26], 272.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][26], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][26], -1);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][26], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][26], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][26], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][26], 1);

    vehicleCOSUI[playerid][27] = CreatePlayerTextDraw(playerid, 240.600036, 225.489562, "Kada kupite vozilo, cekace vas ispred naseg salona, tacnije na parkingu. Dobicete odgovarajuce kljuceve i mozete uci u vozilo.");
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][27], 0.142499, 0.952888);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][27], 0.000000, 93.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][27], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][27], -1);
    PlayerTextDrawUseBox(playerid, vehicleCOSUI[playerid][27], 1);
    PlayerTextDrawBoxColor(playerid, vehicleCOSUI[playerid][27], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][27], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][27], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][27], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][27], 1);

    vehicleCOSUI[playerid][28] = CreatePlayerTextDraw(playerid, 180.700012, 171.377807, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][28], 46.000000, 13.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][28], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][28], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][28], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][28], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][28], 0);

    vehicleCOSUI[playerid][29] = CreatePlayerTextDraw(playerid, 253.400207, 171.377807, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][29], 46.000000, 13.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][29], 1);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][29], 796937471);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][29], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][29], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][29], 0);

    vehicleCOSUI[playerid][30] = CreatePlayerTextDraw(playerid, 276.404754, 174.666595, "LANDSTALKER");
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][30], 0.138499, 0.697777);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][30], 0.000000, 103.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][30], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][30], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][30], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][30], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][30], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][30], 1);

    vehicleCOSUI[playerid][31] = va_CreatePlayerTextDraw(playerid, 202.904754, 174.644409, "$%d", vehicleCarList[0][2][0]);
    PlayerTextDrawLetterSize(playerid, vehicleCOSUI[playerid][31], 0.138499, 0.697777);
    PlayerTextDrawTextSize(playerid, vehicleCOSUI[playerid][31], 0.000000, 103.000000);
    PlayerTextDrawAlignment(playerid, vehicleCOSUI[playerid][31], 2);
    PlayerTextDrawColor(playerid, vehicleCOSUI[playerid][31], 255);
    PlayerTextDrawSetShadow(playerid, vehicleCOSUI[playerid][31], 0);
    PlayerTextDrawBackgroundColor(playerid, vehicleCOSUI[playerid][31], 255);
    PlayerTextDrawFont(playerid, vehicleCOSUI[playerid][31], 1);
    PlayerTextDrawSetProportional(playerid, vehicleCOSUI[playerid][31], 1);

    for (new i = 0; i < 32; i++)
        PlayerTextDrawShow(playerid, vehicleCOSUI[playerid][i]);

    SelectTextDraw(playerid, 0xFF0000AA);
    Vehicle_SetViewingCatalogue(playerid, 1);
    
    for (new j = 0; j < 40; j++)
        SendClientMessage(playerid, -1, " ");

    SendInfoMsg(playerid, "Ukoliko vam ostanu textdrawovi i ne mozete da ih sklonite, kucajte /cardealershipui!");
    return 1;
}

stock Vehicle_Create(const vehicleid, const modelid, const owner[], Float:x, Float:y, Float:z, Float:a, const color1, const color2, const locked = 0)
{
    strcopy(VehicleData[vehicleid][vehicleOwner], owner);

    VehicleData[vehicleid][vehicleModelID] = modelid;
    VehicleData[vehicleid][vehicleCreated] = 1;
    VehicleData[vehicleid][vehiclePosX] = x;
    VehicleData[vehicleid][vehiclePosY] = y;
    VehicleData[vehicleid][vehiclePosZ] = z;
    VehicleData[vehicleid][vehiclePosA] = a;
    VehicleData[vehicleid][vehicleColor][0] = color1;
    VehicleData[vehicleid][vehicleColor][1] = color2;
    VehicleData[vehicleid][vehicleLocked] = locked;

    new tmpString[64];
    format(tmpString, sizeof(tmpString), "Vlasnik vozila: "WHITE"%s", owner);

    VehicleData[vehicleid][vehicleModel] = CreateVehicle(modelid, x, y, z, a, color1, color2, 0);
    VehicleData[vehicleid][vehicleLabel] = CreateDynamic3DTextLabel(tmpString, MAIN_COLOR_HEX, x, y, z, 60.0, .attachedvehicle = VehicleData[vehicleid][vehicleModel]);

    Vehicle_SetFuel(VehicleData[vehicleid][vehicleModel], 50);
    Vehicle_SetColor(VehicleData[vehicleid][vehicleModel], color1, color2);

    Vehicle_Save(vehicleid);
    return 1;
}

stock Vehicle_GetModelName(const modelid)
{
    new tmpString[64];
    switch (modelid)
    {
        case 400: { tmpString = "Landstalker"; } case 603: { tmpString = "Phoenix"; }
        case 401: { tmpString = "Bravura"; } case 402: { tmpString = "Buffalo"; }
        case 404: { tmpString = "Perennial"; } case 405: { tmpString = "Sentinel"; }
        case 410: { tmpString = "Manana"; } case 411: { tmpString = "Infernus"; }
        case 412: { tmpString = "Voodoo"; } case 415: { tmpString = "Cheetah"; }
        case 419: { tmpString = "Esperanto"; } case 421: { tmpString = "Washington"; }
        case 422: { tmpString = "Bobcat"; } case 426: { tmpString = "Premier"; }
        case 429: { tmpString = "Banshee"; } case 436: { tmpString = "Previon"; }
        case 439: { tmpString = "Stallion"; } case 442: { tmpString = "Romero"; }
        case 445: { tmpString = "Admiral"; } case 451: { tmpString = "Turismo"; }
        case 458: { tmpString = "Solair"; } case 466: { tmpString = "Glendale"; }
        case 474: { tmpString = "Hermes"; } case 475: { tmpString = "Sabre"; }
        case 477: { tmpString = "ZR-350"; } case 478: { tmpString = "Walton"; }
        case 479: { tmpString = "Regina"; } case 480: { tmpString = "Comet"; }
        case 491: { tmpString = "Virgo"; } case 492: { tmpString = "Greenwood"; }
        case 496: { tmpString = "Blista Compact"; } case 500: { tmpString = "Mesa"; }
        case 504: { tmpString = "Bloodring Banger"; } case 505: { tmpString = "Rancher Lure"; }
        case 506: { tmpString = "Super GT"; } case 507: { tmpString = "Elegant"; }
        case 516: { tmpString = "Nebula"; } case 517: { tmpString = "Majestic"; }
        case 518: { tmpString = "Buccaneer"; } case 526: { tmpString = "Fortune"; }
        case 527: { tmpString = "Cadrona"; } case 529: { tmpString = "Willard"; }
        case 533: { tmpString = "Feltzer"; } case 534: { tmpString = "Remington"; }
        case 535: { tmpString = "Slamvan"; } case 536: { tmpString = "Blade"; }
        case 540: { tmpString = "Vincent"; } case 541: { tmpString = "Bullet"; }
        case 542: { tmpString = "Clover"; } case 543: { tmpString = "Sadler"; }
        case 545: { tmpString = "Hustler"; } case 546: { tmpString = "Intruder"; }
        case 467: { tmpString = "Oceanic"; } case 547: { tmpString = "Primo"; }
        case 549: { tmpString = "Tampa"; } case 550: { tmpString = "Sunrise"; }
        case 551: { tmpString = "Merit"; } case 554: { tmpString = "Yosemite"; }
        case 555: { tmpString = "Windsor"; } case 558: { tmpString = "Uranus"; }
        case 559: { tmpString = "Jester"; } case 560: { tmpString = "Sultan"; }
        case 561: { tmpString = "Stratum"; } case 562: { tmpString = "Elegy"; }
        case 565: { tmpString = "Flash"; } case 566: { tmpString = "Tahoma"; }
        case 567: { tmpString = "Savanna"; } case 575: { tmpString = "Broadway"; }
        case 576: { tmpString = "Tornado"; } case 579: { tmpString = "Huntley"; }
        case 580: { tmpString = "Stafford"; } case 585: { tmpString = "Emperor"; }
        case 587: { tmpString = "Euros"; } case 589: { tmpString = "Club"; }
        case 600: { tmpString = "Picador"; } case 602: { tmpString = "Alpha"; }
        default: { tmpString = "Unknown"; }
    }
    return tmpString;
}

stock Vehicle_GetNextID(const len)
{
    new id = -1;
    for (new loop = 0, provjera = -1, Data_[64] = "\0"; loop != len; ++loop)
    {
        provjera = loop + 1;
        format(Data_, (sizeof Data_), VEHICLES_PATH, provjera);
        if (!fexist(Data_))
        {
            id = provjera;
            break;
        } 
    }
    return id;
}

stock Vehicle_GetType(const modelid)
{
    static model_type[16];
    switch (modelid)
    {
        case 448, 461, 462, 463, 468, 521, 522, 581, 586: { model_type = "Motor"; }
        case 460, 476, 511, 512, 513, 519, 520, 553, 577, 592, 593: { model_type = "Avion"; }
        case 417, 425, 447, 469, 487, 488, 497, 548, 563: { model_type = "Helikopter"; }
        case 481, 509, 510: { model_type = "Biciklo"; }
        // If the vehicle type is none of the above
        default: { model_type = "Automobil"; }
    }
    return model_type;
}

stock Vehicle_GetNearest(const playerid)
{
    for (new i = 0; i < MAX_VEHICLES; i++)
        if (IsPlayerInRangeOfPoint(playerid, 5.0, VehicleData[i][vehiclePosX], VehicleData[i][vehiclePosY], VehicleData[i][vehiclePosZ]))
            return i;
    return MAX_VEHICLES;
}

// If player is in any MAX_VEHICLES vehicle
stock Vehicle_Valid(const vehicleid)
{
    for (new i = 0; i < MAX_VEHICLES; i++)
        if (vehicleid == VehicleData[i][vehicleModel])
            return 1;
    return 0;
}

stock Vehicle_ReturnID(const playerid)
{
    for (new i = 0; i < MAX_VEHICLES; i++)
        if (IsPlayerInVehicle(playerid, VehicleData[i][vehicleModel]))
            return i;
    return -1;
}

stock Vehicle_SetSelected(const playerid, const value) return vehicleSelectedCMD[playerid] = value;
stock Vehicle_UpdateCarStatus(const playerid)
{
    new tmpString[10][32];

    strcopy(tmpString[0], Vehicle_GetDoorStatus(vehicleSelectedCMD[playerid], 0) == 1 ? ""LIGHTGREEN"Otvorena" : ""DARKRED"Zatvorena");
    strcopy(tmpString[1], Vehicle_GetDoorStatus(vehicleSelectedCMD[playerid], 1) == 1 ? ""LIGHTGREEN"Otvorena" : ""DARKRED"Zatvorena");
    strcopy(tmpString[2], Vehicle_GetDoorStatus(vehicleSelectedCMD[playerid], 2) == 1 ? ""LIGHTGREEN"Otvorena" : ""DARKRED"Zatvorena");
    strcopy(tmpString[3], Vehicle_GetDoorStatus(vehicleSelectedCMD[playerid], 3) == 1 ? ""LIGHTGREEN"Otvorena" : ""DARKRED"Zatvorena");
    strcopy(tmpString[4], Vehicle_GetWindowStatus(vehicleSelectedCMD[playerid], 0) == 1 ? ""LIGHTGREEN"Otvoren" : ""DARKRED"Zatvoren");
    strcopy(tmpString[5], Vehicle_GetWindowStatus(vehicleSelectedCMD[playerid], 1) == 1 ? ""LIGHTGREEN"Otvoren" : ""DARKRED"Zatvoren");
    strcopy(tmpString[6], Vehicle_GetWindowStatus(vehicleSelectedCMD[playerid], 2) == 1 ? ""LIGHTGREEN"Otvoren" : ""DARKRED"Zatvoren");
    strcopy(tmpString[7], Vehicle_GetWindowStatus(vehicleSelectedCMD[playerid], 3) == 1 ? ""LIGHTGREEN"Otvoren" : ""DARKRED"Zatvoren");
    strcopy(tmpString[8], Vehicle_GetBonnetStatus(vehicleSelectedCMD[playerid]) == 1 ? ""LIGHTGREEN"Otvorena" : ""DARKRED"Zatvorena");
    strcopy(tmpString[9], Vehicle_GetBootStatus(vehicleSelectedCMD[playerid]) == 1 ? ""LIGHTGREEN"Otvoren" : ""DARKRED"Zatvoren");

    Dialog_Show(playerid, "DIALOG_CONTROLCAR", DIALOG_STYLE_TABLIST_HEADERS,
        D_CAPTION,
        ""WHITE"Opcija\t"WHITE"Status\n\
        Lociraj vozilo\t-\n\
        Leva prednja vrata\t%s\n\
        Desna prednja vrata\t%s\n\
        Leva zadnja vrata\t%s\n\
        Desna zadnja vrata\t%s\n\
        Levi prednji prozor\t%s\n\
        Desni prednji prozor\t%s\n\
        Levi zadnji prozor\t%s\n\
        Desni zadnji prozor\t%s\n\
        Hauba\t%s\n\
        Gepek\t%s", ""MAIN_COLOR"Odaberi", "Izlaz",
        tmpString[0], tmpString[1], tmpString[2], tmpString[3],
        tmpString[4], tmpString[5], tmpString[6], tmpString[7],
        tmpString[8], tmpString[9]
    );
    return 1;
}

stock Vehicle_ReturnModel(const vehicleid) return VehicleData[vehicleid][vehicleModelID];
stock Vehicle_GetPlayerModelID(const playerid, const index) return vehiclePlayerID[playerid][index];
stock Vehicle_SetPlayerModelID(const playerid, const index, const value) return vehiclePlayerID[playerid][index] = value;

stock Vehicle_GetWindowStatus(const vehicleid, const index) return vehicleWindowStatus[vehicleid][index];
stock Vehicle_SetWindowStatus(const playervehid, const vehicleid, const index, const status)
{
    static driver, passenger, backleft, backright;
    GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, backright);

    switch (index)
    {
        case 0: SetVehicleParamsCarWindows(vehicleid, status, passenger, backleft, backright);
        case 1: SetVehicleParamsCarWindows(vehicleid, driver, status, backleft, backright);
        case 2: SetVehicleParamsCarWindows(vehicleid, driver, passenger, status, backright);
        case 3: SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, status);
        case 4: SetVehicleParamsCarWindows(vehicleid, status, status, status, status);
    }
    return vehicleWindowStatus[playervehid][index] = status;
}

stock Vehicle_GetDoorStatus(const vehicleid, const index) return vehicleDoorStatus[vehicleid][index];
stock Vehicle_SetDoorStatus(const playervehid, const vehicleid, const index, const status)
{
    new driver, passenger, backleft, backright;
    GetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright);

    switch (index)
    {
        case 0: SetVehicleParamsCarDoors(vehicleid, status, passenger, backleft, backright);
        case 1: SetVehicleParamsCarDoors(vehicleid, driver, status, backleft, backright);
        case 2: SetVehicleParamsCarDoors(vehicleid, driver, passenger, status, backright);
        case 3: SetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, status);
        case 4: SetVehicleParamsCarDoors(vehicleid, status, status, status, status);
    }
    return vehicleDoorStatus[playervehid][index] = status;
}

stock Vehicle_GetBootStatus(const vehicleid) return vehicleBootStatus[vehicleid];
stock Vehicle_SetBootStatus(const playervehid, const vehicleid, const status)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, Vehicle_GetBonnetStatus(vehicleid), status, objective);
    return vehicleBootStatus[playervehid] = status;
}

stock Vehicle_GetBonnetStatus(const vehicleid) return vehicleBonnetStatus[vehicleid];
stock Vehicle_SetBonnetStatus(const playervehid, const vehicleid, const status)
{
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, status, Vehicle_GetBootStatus(vehicleid), objective);
    return vehicleBonnetStatus[playervehid] = status;
}

Dialog: DIALOG_VEHCONFIRMBUY(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    if (Account_GetCar(playerid, 1) && Account_GetCar(playerid, 2))
        return SendErrorMsg(playerid, "Popunjen vam je slot sa vozilima (maksimalno 2 auta)!");

    SendInfoMsgF(playerid, "Uspesno ste kupili %s.", vehicleCarList[vehicleCatalogueID[playerid]][1][0]);
    new
        vehicleid = Vehicle_GetNextID(MAX_VEHICLES),
        rand = random(sizeof(vehicleSpawnPos));

    Vehicle_Create(
        vehicleid, vehicleCarList[vehicleCatalogueID[playerid]][0][0], ReturnPlayerName(playerid),
        vehicleSpawnPos[rand][0], vehicleSpawnPos[rand][1], vehicleSpawnPos[rand][2], vehicleSpawnPos[rand][3],
        vehicleCatalogueColor[playerid], vehicleCatalogueColor[playerid]
    );

    if (!Account_GetCar(playerid, 1))
        Account_SetCar(playerid, 1, vehicleid);

    else if (!Account_GetCar(playerid, 2))
        Account_SetCar(playerid, 2, vehicleid);

    Account_SetMoney(playerid, Account_GetMoney(playerid) - vehicleCarList[vehicleCatalogueID[playerid]][2][0]);
    GivePlayerMoney(playerid, -vehicleCarList[vehicleCatalogueID[playerid]][2][0]);
    va_GameTextForPlayer(playerid, "~r~-$%d", 3000, 3, vehicleCarList[vehicleCatalogueID[playerid]][2][0]);
    Vehicle_CreateCOSUI(playerid, false);

    // printf("===============\n\
    //     1:%d\n2:%d\n\
    //     ================",
    //     Account_GetCar(playerid, 1), Account_GetCar(playerid, 2)
    // );
    Account_SavePlayer(playerid);
    return 1;
}

Dialog: DIALOG_CONTROLCAR(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    switch (listitem)
    {
        case 1..4:
        {
            // if (Vehicle_ReturnModel(GetPlayerVehicleID(playerid)) != vehicleSelectedCMD[playerid])
            // SendInfoMsgF(playerid, "v:%d", vehicleSelectedCMD[playerid]);
            // SendInfoMsgF(playerid, "model ret: %d", VehicleData[1][vehicleModel]);
            if (!IsPlayerInVehicle(playerid, VehicleData[vehicleSelectedCMD[playerid]][vehicleModel]))
                return SendErrorMsg(playerid, "Niste u odabranom vozilu!");

            vehicleCarDoors[playerid][listitem - 1] = !vehicleCarDoors[playerid][listitem - 1];
            Vehicle_SetDoorStatus(vehicleSelectedCMD[playerid], GetPlayerVehicleID(playerid), listitem - 1, vehicleCarDoors[playerid][listitem - 1]);
            Vehicle_UpdateCarStatus(playerid);
        }

        case 5..8:
        {
            if (!IsPlayerInVehicle(playerid, VehicleData[vehicleSelectedCMD[playerid]][vehicleModel]))
                return SendErrorMsg(playerid, "Niste u odabranom vozilu!");

            vehicleCarWindows[playerid][listitem - 5] = !vehicleCarWindows[playerid][listitem - 5];
            Vehicle_SetWindowStatus(vehicleSelectedCMD[playerid], GetPlayerVehicleID(playerid), listitem - 5, vehicleCarWindows[playerid][listitem - 5]);
            Vehicle_UpdateCarStatus(playerid);
        }

        case 9:
        {
            if (!IsPlayerInVehicle(playerid, VehicleData[vehicleSelectedCMD[playerid]][vehicleModel]))
                return SendErrorMsg(playerid, "Niste u odabranom vozilu!");
            
            if (Vehicle_GetBootStatus(vehicleSelectedCMD[playerid]))
                return SendErrorMsg(playerid, "Prvo morate zatvoriti gepek!");

            vehicleCarBonnet[playerid] = !vehicleCarBonnet[playerid];
            Vehicle_SetBonnetStatus(vehicleSelectedCMD[playerid], GetPlayerVehicleID(playerid), vehicleCarBonnet[playerid]);
            Vehicle_UpdateCarStatus(playerid);
        }

        case 10:
        {
            if (!IsPlayerInVehicle(playerid, VehicleData[vehicleSelectedCMD[playerid]][vehicleModel]))
                return SendErrorMsg(playerid, "Niste u odabranom vozilu!");

            if (Vehicle_GetBonnetStatus(vehicleSelectedCMD[playerid]))
                return SendErrorMsg(playerid, "Prvo morate zatvoriti haubu!");

            vehicleCarBoot[playerid] = !vehicleCarBoot[playerid];
            Vehicle_SetBootStatus(vehicleSelectedCMD[playerid], GetPlayerVehicleID(playerid), vehicleCarBoot[playerid]);
            Vehicle_UpdateCarStatus(playerid);
        }
    }
    return 1;
}