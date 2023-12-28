#if defined _INC_house_init_inc
    #endinput
#endif
#define _INC_house_init_inc

#include <YSI_Coding\y_hooks>

const MAX_HOUSES = 200;
#define HOUSE_PATH "Houses/%d.ini"

enum e_HOUSE_DATA
{
    houseCreated,
    housePickup,
    houseMapIcon,
    housePrice,
    houseVW,
    houseLocked,
    houseOwned,
    Text3D:houseLabel,
    houseOwner[MAX_PLAYER_NAME],
    houseDesc[MAX_REASON_LENGTH],
    Float: houseExtX,
    Float: houseExtY,
    Float: houseExtZ,
    Float: houseIntX,
    Float: houseIntY,
    Float: houseIntZ
};

new HouseData[MAX_HOUSES][e_HOUSE_DATA];

#define House_GetOwner(%0) HouseData[%0][houseOwner]
#define House_GetDescription(%0) HouseData[%0][houseDesc]

forward House_Load(houseid, const name[], const value[]);
public House_Load(houseid, const name[], const value[])
{
    INI_Int("houseOwned", HouseData[houseid][houseOwned]);
    INI_Int("housePrice", HouseData[houseid][housePrice]);
    INI_Int("houseVW", HouseData[houseid][houseVW]);
    INI_Int("houseLocked", HouseData[houseid][houseLocked]);
    INI_String("houseOwner", HouseData[houseid][houseOwner]);
    INI_String("houseDesc", HouseData[houseid][houseDesc]);
    INI_Float("houseExtX", HouseData[houseid][houseExtX]);
    INI_Float("houseExtY", HouseData[houseid][houseExtY]);
    INI_Float("houseExtZ", HouseData[houseid][houseExtZ]);
    INI_Float("houseIntX", HouseData[houseid][houseIntX]);
    INI_Float("houseIntY", HouseData[houseid][houseIntY]);
    INI_Float("houseIntZ", HouseData[houseid][houseIntZ]);
    return 1;
}

public Float: House_GetPos(const houseid, const index)
{
    static Float:ret = -1.00;
    switch (index)
    {
        case 0: ret = HouseData[houseid][houseExtX];
        case 1: ret = HouseData[houseid][houseExtY];
        case 2: ret = HouseData[houseid][houseExtZ];
    }
    return ret;
}

public Float: House_GetIntPos(const houseid, const index)
{
    static Float:ret = -1.00;
    switch (index)
    {
        case 0: ret = HouseData[houseid][houseIntX];
        case 1: ret = HouseData[houseid][houseIntY];
        case 2: ret = HouseData[houseid][houseIntZ];
    }
    return ret;
}

hook OnGameModeInit()
{
    for(new i; i < MAX_HOUSES; i++)
    {
        new hFile[50], tmpString[512];
        format(hFile, sizeof(hFile), HOUSE_PATH, i);
        if(fexist(hFile))
        {
            INI_ParseFile(hFile, "House_Load", .bExtra = true, .extra = i);

            if (HouseData[i][houseOwned])
            {
                format(tmpString, sizeof(tmpString), "[KUCA - %d]\nVlasnik: %s\nOpis: %s\nCena: $%d", i, HouseData[i][houseOwner], HouseData[i][houseDesc], HouseData[i][housePrice]);
                HouseData[i][houseMapIcon] = CreateDynamicMapIcon(HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ], 32, 1);
            }

            else
            {
                format(tmpString, sizeof(tmpString), "[KUCA - %d]\nOva kuca je na prodaju!\nVlasnik: %s\nOpis: %s\nCena: $%d\nDa kupite kucu kucajte /kupikucu!", i, HouseData[i][houseOwner], HouseData[i][houseDesc], HouseData[i][housePrice]);
                HouseData[i][houseMapIcon] = CreateDynamicMapIcon(HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ], 31, 1);
            }

            HouseData[i][houseCreated] = 1;
            HouseData[i][houseLabel] = CreateDynamic3DTextLabel(tmpString, X11_GREEN, HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ], 30.0);
            HouseData[i][housePickup] = CreateDynamicPickup(1272, 1, HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ]);
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (PRESSED(KEY_SECONDARY_ATTACK))
    {
        for (new i = 0; i < MAX_HOUSES; i++)
        {
            if (IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ]))
            {
                if (Account_GetHouse(playerid) == i || !House_IsLocked(i))
                {
                    SetPlayerVirtualWorld(playerid, HouseData[i][houseVW]);
                    Streamer_UpdateEx(playerid, HouseData[i][houseIntX], HouseData[i][houseIntY], HouseData[i][houseIntZ], HouseData[i][houseVW], .compensatedtime = 2000);
                }
                else
                    return GameTextForPlayer(playerid, "~r~KUCA JE ZAKLJUCANA!", 3000, 3);
            }
        
            if (IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[i][houseIntX], HouseData[i][houseIntY], HouseData[i][houseIntZ]) && GetPlayerVirtualWorld(playerid) == HouseData[i][houseVW])
            {
                SetPlayerVirtualWorld(playerid, 0);
                Streamer_UpdateEx(playerid, HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ], 0, .compensatedtime = 2000);
                return 1;
            }
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock House_GetMaxHouses() return MAX_HOUSES;
// stock House_GetOwner(const houseid) return HouseData[houseid][houseOwner];
stock House_GetPrice(const houseid) return HouseData[houseid][housePrice];
stock House_IsLocked(const houseid) return HouseData[houseid][houseLocked];
stock House_HasOwner(const houseid) return HouseData[houseid][houseOwned];
stock House_GetVW(const houseid) return HouseData[houseid][houseVW];
stock House_Create(const playerid, const houseid, const price, Float: x, Float: y, Float: z)
{
    strcopy(HouseData[houseid][houseOwner], "Niko");
    strcopy(HouseData[houseid][houseDesc], "Na prodaju");

    HouseData[houseid][housePrice] = price;
    HouseData[houseid][houseCreated] =
    HouseData[houseid][houseLocked] = 1;
    HouseData[houseid][houseOwned] = 0;
    HouseData[houseid][houseVW] = houseid;
    HouseData[houseid][houseExtX] = x;
    HouseData[houseid][houseExtY] = y;
    HouseData[houseid][houseExtZ] = z;
    HouseData[houseid][houseIntX] = -277.4879;
    HouseData[houseid][houseIntY] = 1584.5845;
    HouseData[houseid][houseIntZ] = 462.7619;

    static tmpString[128];
    format(tmpString, sizeof(tmpString), "[KUCA - %d]\nOva kuca je na prodaju!\nVlasnik: %s\nOpis: %s\nCena: $%d\nDa kupite kucu kucajte /kupikucu!",
        houseid, HouseData[houseid][houseOwner], HouseData[houseid][houseDesc], HouseData[houseid][housePrice]
    );

    HouseData[houseid][houseLabel] = CreateDynamic3DTextLabel(tmpString, X11_GREEN, HouseData[houseid][houseExtX], HouseData[houseid][houseExtY], HouseData[houseid][houseExtZ], 30.00);
    HouseData[houseid][housePickup] = CreateDynamicPickup(1272, 1, HouseData[houseid][houseExtX], HouseData[houseid][houseExtY], HouseData[houseid][houseExtZ]);
    HouseData[houseid][houseMapIcon] = CreateDynamicMapIcon(HouseData[houseid][houseExtX], HouseData[houseid][houseExtY], HouseData[houseid][houseExtZ], 31, 1);

    SendServerMsgF(playerid, "Kreirali ste kucu! ID Kuce: %d", houseid);
    House_Save(houseid);
    return 1;
}

stock House_Destroy(const playerid, const houseid)
{
    HouseData[houseid][houseCreated] = 0;

    DestroyDynamicPickup(HouseData[houseid][housePickup]);
    DestroyDynamicMapIcon(HouseData[houseid][houseMapIcon]);
    DestroyDynamic3DTextLabel(HouseData[houseid][houseLabel]);
    SendServerMsgF(playerid, "Obrisali ste kucu! ID Kuce: %d", houseid);
    return 1;
}

stock House_Buy(const playerid, const houseid)
{
    SendCustomMsgF(playerid, MAIN_COLOR_HEX, "(Kuca): "WHITE"Uspesno ste kupili kucu za $%d!", House_GetPrice(houseid));
    HouseData[houseid][houseOwned] = 1;
    strcopy(HouseData[houseid][houseOwner], ReturnPlayerName(playerid));
    strcopy(HouseData[houseid][houseDesc], "Nema opisa");

    new tmpString[50 + MAX_PLAYER_NAME];
    format(tmpString, sizeof(tmpString), "[KUCA - %d]\nVlasnik: %s\nOpis: %s\nCena: $%d",
        houseid, ReturnPlayerName(playerid), HouseData[houseid][houseDesc], House_GetPrice(houseid)
    );
    UpdateDynamic3DTextLabelText(HouseData[houseid][houseLabel], X11_GREEN, tmpString);

    DestroyDynamicMapIcon(HouseData[houseid][houseMapIcon]);
    HouseData[houseid][houseMapIcon] = CreateDynamicMapIcon(HouseData[houseid][houseExtX], HouseData[houseid][houseExtY], HouseData[houseid][houseExtZ], 32, 1);
    House_Save(houseid);
    Account_SavePlayer(playerid);
    return 1;
}

stock House_SetDescription(const houseid, const string: desc[])
{
    strcopy(HouseData[houseid][houseDesc], desc);
    House_Save(houseid);

    new fmt[50 + MAX_PLAYER_NAME];
    format(fmt, sizeof(fmt), "[KUCA - %d]\nVlasnik: %s\nOpis: %s\nCena: $%d",
        houseid, House_GetOwner(houseid), HouseData[houseid][houseDesc], House_GetPrice(houseid)
    );
    UpdateDynamic3DTextLabelText(HouseData[houseid][houseLabel], X11_GREEN, fmt);
    return 1;
}

stock House_SetLocked(const houseid, const value)
{
    HouseData[houseid][houseLocked] = value;
    House_Save(houseid);
    return 1;
}

stock House_Goto(const playerid, const houseid)
{
    if (!houseid || houseid < 0)
        return 0;

    Streamer_UpdateEx(playerid, HouseData[houseid][houseExtX], HouseData[houseid][houseExtY] + 2.00, HouseData[houseid][houseExtZ], .compensatedtime = 2000);
    if (IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, HouseData[houseid][houseExtX] + 2.00, HouseData[houseid][houseExtY], HouseData[houseid][houseExtZ]);
        PutPlayerInVehicle(playerid, vehicleid, 0);
    }
    return 1;
}

stock House_GetNextID(const len)
{
    new id = -1;
    for (new loop = 0, provjera = -1, Data_[64] = "\0"; loop != len; ++loop)
    {
        provjera = loop + 1;
        format(Data_, (sizeof Data_), HOUSE_PATH, provjera);
        if (!fexist(Data_))
        {
            id = provjera;
            break;
        } 
    }
    return id;
}

stock House_GetNearby(const playerid)
{
    for (new i = 0; i < MAX_HOUSES; ++i)
        if (IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[i][houseExtX], HouseData[i][houseExtY], HouseData[i][houseExtZ]))
            return i;
    return MAX_HOUSES;
}

stock House_GetNearbyInt(const playerid)
{
    for (new i = 0; i < MAX_HOUSES; ++i)
        if (IsPlayerInRangeOfPoint(playerid, 2.0, HouseData[i][houseIntX], HouseData[i][houseIntY], HouseData[i][houseIntZ]))
            return i;
    return MAX_HOUSES;
}

stock House_OpenMenu(const playerid)
{
    if (Account_GetHouse(playerid) == -1)
        return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Nemate kucu!");

    new houseid = House_GetNearby(playerid);
    if (houseid == House_GetMaxHouses())
        return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti blizu kuce!");

    if (strcmp(ReturnPlayerName(playerid), House_GetOwner(houseid)))
        return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti kod svoje kuce!");

    static tmpString[32];
    strcopy(tmpString, (!House_IsLocked(houseid) ? (""DARKRED"Zakljucaj") : (""LIGHTGREEN"Otkljucaj")));

    Dialog_Show(playerid, "DIALOG_HOUSEMENU", DIALOG_STYLE_LIST,
        ""MAIN_COLOR"gta-world - "WHITE"Kuca",
        "Promeni opis kuce\n%s kucu\nProdaj kucu",
        ""MAIN_COLOR"Potvrdi", "Izlaz", tmpString
    );
    return 1;
}

stock House_Save(houseid)
{
    new hFile[128];
    format(hFile, sizeof(hFile), HOUSE_PATH, houseid);
    new INI:File = INI_Open(hFile);
    INI_SetTag(File,"data");
    INI_WriteInt(File, "houseOwned", HouseData[houseid][houseOwned]);
    INI_WriteInt(File, "housePrice", HouseData[houseid][housePrice]);
    INI_WriteInt(File, "houseVW", HouseData[houseid][houseVW]);
    INI_WriteInt(File, "houseLocked", HouseData[houseid][houseLocked]);
    INI_WriteString(File, "houseOwner", HouseData[houseid][houseOwner]);
    INI_WriteString(File, "houseDesc", HouseData[houseid][houseDesc]);
    INI_WriteFloat(File, "houseExtX", HouseData[houseid][houseExtX]);
    INI_WriteFloat(File, "houseExtY", HouseData[houseid][houseExtY]);
    INI_WriteFloat(File, "houseExtZ", HouseData[houseid][houseExtZ]);
    INI_WriteFloat(File, "houseIntX", HouseData[houseid][houseIntX]);
    INI_WriteFloat(File, "houseIntY", HouseData[houseid][houseIntY]);
    INI_WriteFloat(File, "houseIntZ", HouseData[houseid][houseIntZ]);
    INI_Close(File);
    return 1;
}