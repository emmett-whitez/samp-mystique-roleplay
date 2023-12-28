#if defined _INC_gps_init_inc
    #endinput
#endif
#define _INC_gps_init_inc

#include <YSI_Coding\y_hooks>

const MAX_GPS = 20;
#define GPS_PATH "/Gps/%d.ini"

enum e_GPS_DATA
{
    gpsCreated,
    gpsName[32],
    Float:gpsX,
    Float:gpsY,
    Float:gpsZ
};

static
    GpsData[MAX_GPS][e_GPS_DATA],
    gpsStoreString[YSI_MAX_STRING],
    gpsCheckpoint[MAX_PLAYERS],
    Float:gpsCheckpointX[MAX_PLAYERS],
    Float:gpsCheckpointY[MAX_PLAYERS],
    Float:gpsCheckpointZ[MAX_PLAYERS],
    gpsTimer[MAX_PLAYERS];

forward GPS_ShowDistance(const playerid);
public GPS_ShowDistance(const playerid)
{
    new Float:gpsDistance = GetPlayerDistanceFromPoint(playerid, gpsCheckpointX[playerid], gpsCheckpointY[playerid], gpsCheckpointZ[playerid]);
    UI_ShowInfoMessage(playerid, 1000, "Preostalo ~y~%0.2fm ~w~do lokacije.", gpsDistance);
}

forward GPS_Load(gpsid, const name[], const value[]);
public GPS_Load(gpsid, const name[], const value[])
{
    INI_String("gpsName", GpsData[gpsid][gpsName]);
    INI_Float("gpsX", GpsData[gpsid][gpsX]);
    INI_Float("gpsY", GpsData[gpsid][gpsY]);
    INI_Float("gpsZ", GpsData[gpsid][gpsZ]);
    return 1;
}

hook OnGameModeInit()
{
    for(new i; i < MAX_GPS; i++)
    {
        new gpsFile[50];
        format(gpsFile, sizeof(gpsFile), GPS_PATH, i);
        if(fexist(gpsFile))
        {
            INI_ParseFile(gpsFile, "GPS_Load", .bExtra = true, .extra = i);
            GpsData[i][gpsCreated] = 1;
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
    if (gpsCheckpoint[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        GameTextForPlayer(playerid, "Stigli ste na odrediste!", 1000, 1);
        KillTimer(gpsTimer[playerid]);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock GPS_Create(const gpsid, const gpsname[], Float:gpsx, Float:gpsy, Float:gpsz)
{
    GpsData[gpsid][gpsX] = gpsx;
    GpsData[gpsid][gpsY] = gpsy;
    GpsData[gpsid][gpsZ] = gpsz;
    GpsData[gpsid][gpsCreated] = 1;

    strcopy(GpsData[gpsid][gpsName], gpsname);
    format(gpsStoreString, sizeof(gpsStoreString), "%s[%d]. %s\n", gpsStoreString, gpsid + 1, GpsData[gpsid][gpsName]);

    GPS_Save(gpsid);
    return 1;
}

stock GPS_Save(gpsid)
{
    new gpsFile[60];
    format(gpsFile, sizeof(gpsFile), GPS_PATH, gpsid);
    new INI:File = INI_Open(gpsFile);
    INI_SetTag(File, "data");
    INI_WriteString(File, "gpsName", GpsData[gpsid][gpsName]);
    INI_WriteFloat(File, "gpsX", GpsData[gpsid][gpsX]);
    INI_WriteFloat(File, "gpsY", GpsData[gpsid][gpsY]);
    INI_WriteFloat(File, "gpsZ", GpsData[gpsid][gpsZ]);
    INI_Close(File);
    return 1;
}

stock GPS_ShowMenu(const playerid)
{
    new tmpString[512];
    strcopy(gpsStoreString, "");
    strcopy(tmpString, "");

    for (new i = 0; i < MAX_GPS; i++)
    {
        new gpsFile[60];
        format(gpsFile, sizeof(gpsFile), GPS_PATH, i);
        if (fexist(gpsFile))
        {
            if (!i)
            {
                format(tmpString, sizeof(tmpString), "[%d]. %s", i, GpsData[i][gpsName]);
                strcat(gpsStoreString, tmpString);
            }

            else
            {
                format(tmpString, sizeof(tmpString), "\n[%d]. %s", i, GpsData[i][gpsName]);
                strcat(gpsStoreString, tmpString);
            }
        }
    }
    Dialog_Show(playerid, "DIALOG_GPSMENU", DIALOG_STYLE_LIST, "GPS - Lokacije", gpsStoreString, "Odaberi", "Izlaz");
    return 1;
}

stock GPS_Disable(const playerid)
{
    DisablePlayerCheckpoint(playerid);
    KillTimer(gpsTimer[playerid]);
    return 1;
}

stock GPS_GetNextID()
{
    for (new i = 0; i < MAX_GPS; i++)
        if (!GpsData[i][gpsCreated])
            return i;
    return MAX_GPS;
}

Dialog:DIALOG_GPSMENU(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    SendInfoMsgF(playerid, "Lokacija "ORANGE"%s "WHITE"je oznacena na mapi.", GpsData[listitem][gpsName]);
    SetPlayerCheckpoint(playerid, GpsData[listitem][gpsX], GpsData[listitem][gpsY], GpsData[listitem][gpsZ], 3.00);

    gpsCheckpointX[playerid] = GpsData[listitem][gpsX];
    gpsCheckpointY[playerid] = GpsData[listitem][gpsY];
    gpsCheckpointZ[playerid] = GpsData[listitem][gpsZ];
    gpsTimer[playerid] = SetTimerEx("GPS_ShowDistance", 1000, true, "d", playerid);
    gpsCheckpoint[playerid] = 1;
    return 1;
}