#if defined _INC_rent_init_inc
    #endinput
#endif
#define _INC_rent_init_inc

#include <YSI_Coding\y_hooks>

#if defined MAX_RENT_PICKUPS
    #undef MAX_RENT_PICKUPS
#endif

const MAX_RENT_PICKUPS = 50;
#define RENT_PATH "/Rents/%d.ini"

enum e_RENT_DATA
{
    rentPickup,
    rentCreated,
    Text3D:rentPickupLabel,
    Float:rentX,
    Float:rentY,
    Float:rentZ
};

static
    RentData[MAX_RENT_PICKUPS][e_RENT_DATA],
    Text3D:rentVehicleLabel[MAX_PLAYERS],
    rentVehicle[MAX_PLAYERS],
    rentTime[MAX_PLAYERS],
    rentSelected[MAX_PLAYERS],
    rentOwner[MAX_PLAYERS][MAX_PLAYER_NAME],
    Timer:rentTimer[MAX_PLAYERS];

static const rentVehicleList[][][] =
{
    // vehicle name     id      price
    {"Landstalker",     400,    250},
    {"Sentinel",        405,    200},
    {"Admiral",         445,    230},
    {"Faggio",          462,    70},
    {"Quad",            471,    100}
};

forward Rent_Load(rentid, const name[], const value[]);
public Rent_Load(rentid, const name[], const value[])
{
    INI_Float("rentX", RentData[rentid][rentX]);
    INI_Float("rentY", RentData[rentid][rentY]);
    INI_Float("rentZ", RentData[rentid][rentZ]);
    return 1;
}

hook OnGameModeInit()
{
    for(new i; i < MAX_RENT_PICKUPS; i++)
    {
        new rentFile[50];
        format(rentFile, sizeof(rentFile), RENT_PATH, i);
        if(fexist(rentFile))
        {
            INI_ParseFile(rentFile, "Rent_Load", .bExtra = true, .extra = i);
            RentData[i][rentPickup] = CreateDynamicPickup(19606, 1, RentData[i][rentX], RentData[i][rentY], RentData[i][rentZ] - 0.5);
            RentData[i][rentPickupLabel] = CreateDynamic3DTextLabel(""CYAN"RENT VOZILA\n"WHITE"Da iznajmite vozilo stisnite "CYAN"'N'", -1, RentData[i][rentX], RentData[i][rentY], RentData[i][rentZ], 30.00);
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (PRESSED(KEY_NO))
    {
        new rentid = Rent_GetNearby(playerid);
        if (rentid == MAX_RENT_PICKUPS)
            return 0;

        if (!rentTime[playerid])
            Rent_ShowDialog(playerid);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        foreach (new i: Player)
        {
            if (IsPlayerInVehicle(playerid, rentVehicle[i]))
                if (strcmp(rentOwner[i], ReturnPlayerName(playerid), false))
                {
                    SendCustomMsgF(playerid, X11_RED, "RENT: "WHITE"To nije vase iznajmljeno vozilo!");
                    return ClearAnimations(playerid);
                }
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock Rent_GetMaxPickups() return MAX_RENT_PICKUPS;
stock Rent_GetPlayerTime(const playerid) return rentTime[playerid];
stock Rent_Create(const rentid, Float:x, Float:y, Float:z)
{
    RentData[rentid][rentX] = x;
    RentData[rentid][rentY] = y;
    RentData[rentid][rentZ] = z;
    RentData[rentid][rentCreated] = 1;

    RentData[rentid][rentPickup] = CreateDynamicPickup(19606, 1, x, y, z - 0.5);
    RentData[rentid][rentPickupLabel] = CreateDynamic3DTextLabel(""CYAN"RENT VOZILA\n"WHITE"Da iznajmite vozilo stisnite "CYAN"'N'", -1, x, y, z, 30.00);

    Rent_Save(rentid);
    return 1;
}

stock Rent_Save(rentid)
{
    new rentFile[60];
    format(rentFile, sizeof(rentFile), RENT_PATH, rentid);
    new INI:File = INI_Open(rentFile);
    INI_SetTag(File,"data");
    INI_WriteFloat(File, "rentX", RentData[rentid][rentX]);
    INI_WriteFloat(File, "rentY", RentData[rentid][rentY]);
    INI_WriteFloat(File, "rentZ", RentData[rentid][rentZ]);
    INI_Close(File);
    return 1;
}

stock Rent_GetNextID(const len)
{
    new id = -1;
    for (new loop = 0, provjera = -1, Data_[64] = "\0"; loop != len; ++loop)
    {
        provjera = loop + 1;
        format(Data_, (sizeof Data_), RENT_PATH, provjera);
        if (!fexist(Data_))
        {
            id = provjera;
            break;
        } 
    }
    return id;
}

stock Rent_GetNearby(const playerid)
{
    for (new i = 0; i < MAX_RENT_PICKUPS; i++)
        if (IsPlayerInRangeOfPoint(playerid, 2.0, RentData[i][rentX], RentData[i][rentY], RentData[i][rentZ]))
            return i;
    return MAX_RENT_PICKUPS;
}

stock Rent_ShowDialog(const playerid)
    return Dialog_Show(playerid, "DIALOG_RENTSELECT", DIALOG_STYLE_TABLIST_HEADERS,
            D_CAPTION,
            ""WHITE"Vozilo\t"WHITE"cena/1min\n\
            %s\t"DARKGREEN"$"WHITE"%d\n\
            %s\t"DARKGREEN"$"WHITE"%d\n\
            %s\t"DARKGREEN"$"WHITE"%d\n\
            %s\t"DARKGREEN"$"WHITE"%d\n\
            %s\t"DARKGREEN"$"WHITE"%d",
            ""CYAN"Odaberi", "Izlaz",
            rentVehicleList[0][0], rentVehicleList[0][2],
            rentVehicleList[1][0], rentVehicleList[1][2],
            rentVehicleList[2][0], rentVehicleList[2][2],
            rentVehicleList[3][0], rentVehicleList[3][2],
            rentVehicleList[4][0], rentVehicleList[4][2]
        );

stock Rent_Destroy(const playerid)
{
    DestroyVehicle(rentVehicle[playerid]);
    DestroyDynamic3DTextLabel(rentVehicleLabel[playerid]);
    stop rentTimer[playerid];
    rentTime[playerid] = 0;
    return 1;
}

TIMER__ RENT_DecreaseTime[60000](playerid)
{
    rentTime[playerid]--;
    if (!rentTime[playerid])
    {
        SendCustomMsgF(playerid, X11_CYAN, "RENT: "WHITE"Isteklo je vreme renta!");
        Rent_Destroy(playerid);
    }
}

Dialog: DIALOG_RENTSELECT(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    rentSelected[playerid] = listitem + 1;
    Dialog_Show(playerid, "DIALOG_RENTTIME", DIALOG_STYLE_INPUT,
        D_CAPTION,
        ""WHITE"Unesite na koliko minuta zelite iznajmiti vozilo:",
        ""CYAN"Unesi", "Izlaz"
    );
    return 1;
}

Dialog: DIALOG_RENTTIME(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Rent_ShowDialog(playerid);

    if (!(1 <= strval(inputtext) <= 30))
    {
        SendErrorMsg(playerid, "Ne mozete ispod 1 minuta i iznad 30 minuta!");
        return Rent_ShowDialog(playerid);
    }

    rentTime[playerid] = strval(inputtext);
    rentTimer[playerid] = repeat RENT_DecreaseTime(playerid);
    new rentPrice = (rentVehicleList[rentSelected[playerid] - 1][2][0] * rentTime[playerid]);

    strcopy(rentOwner[playerid], ReturnPlayerName(playerid));
    GivePlayerMoney(playerid, -rentPrice);
    Account_SetMoney(playerid, Account_GetMoney(playerid) - rentPrice);
    va_GameTextForPlayer(playerid, "~r~-$%d", 3000, 3, rentPrice);

    new Float:x, Float:y, Float:z, Float:a, tmpString[MAX_REASON_LENGTH];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    format(tmpString, sizeof(tmpString), ""CYAN"RENT VOZILO\n"CYAN"- "WHITE"%s "CYAN"-", ReturnPlayerName(playerid));
    rentVehicle[playerid] = CreateVehicle(rentVehicleList[rentSelected[playerid] - 1][1][0], x, y, z, a, 130, 130, 60 * 60);
    rentVehicleLabel[playerid] = CreateDynamic3DTextLabel(tmpString, -1, x + 5.00, y, z, 30.00, .attachedvehicle = rentVehicle[playerid]);
    
    SendCustomMsgF(playerid, X11_CYAN, "RENT: "WHITE"Uspesno ste iznajmili vozilo na %d minuta!", rentTime[playerid]);

    PutPlayerInVehicle(playerid, rentVehicle[playerid], 0);
    Vehicle_SetColor(rentVehicle[playerid], 130, 130);
    Vehicle_SetFuel(rentVehicle[playerid], 50);
    return 1;
}