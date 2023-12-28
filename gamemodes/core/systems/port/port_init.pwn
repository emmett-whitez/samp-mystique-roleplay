#if defined _INC_port_init_inc
	#endinput
#endif
#define _INC_port_init_inc

#include <YSI_Coding\y_hooks>

const MAX_PORTS = 20;
#define PORT_PATH "/Ports/%d.ini"

enum e_PORT_DATA
{
    portCreated,
    portName[32],
    Float:portX,
    Float:portY,
    Float:portZ
};

new
    PortData[MAX_PORTS][e_PORT_DATA],
    portStoreString[YSI_MAX_STRING];

forward Port_Load(portid, const name[], const value[]);
public Port_Load(portid, const name[], const value[])
{
    INI_String("portName", PortData[portid][portName]);
    INI_Float("portX", PortData[portid][portX]);
    INI_Float("portY", PortData[portid][portY]);
    INI_Float("portZ", PortData[portid][portZ]);
    return 1;
}

hook OnGameModeInit()
{
    for(new i; i < MAX_PORTS; i++)
    {
        new rentFile[50];
        format(rentFile, sizeof(rentFile), PORT_PATH, i);
        if(fexist(rentFile))
        {
            INI_ParseFile(rentFile, "Port_Load", .bExtra = true, .extra = i);
            PortData[i][portCreated] = 1;
        }
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock Port_GetMaxPorts() return MAX_PORTS;
stock Port_Create(const portid, const portname[], Float:portx, Float:porty, Float:portz)
{
    PortData[portid][portX] = portx;
    PortData[portid][portY] = porty;
    PortData[portid][portZ] = portz;
    PortData[portid][portCreated] = 1;

    strcopy(PortData[portid][portName], portname);
    format(portStoreString, sizeof(portStoreString), "%s[%d]. %s\n", portStoreString, portid + 1, PortData[portid][portName]);
    Port_Save(portid);
    return 1;
}

stock Port_ShowMenu(const playerid)
{
    new tmpString[512];
    strcopy(portStoreString, "");
    strcopy(tmpString, "");

    for (new i = 0; i < MAX_PORTS; i++)
    {
        new portFile[60];
        format(portFile, sizeof(portFile), PORT_PATH, i);
        if (fexist(portFile))
        {
            if (!i)
            {
                format(tmpString, sizeof(tmpString), "[%d]. %s", i, PortData[i][portName]);
                strcat(portStoreString, tmpString);
            }

            else
            {
                format(tmpString, sizeof(tmpString), "\n[%d]. %s", i, PortData[i][portName]);
                strcat(portStoreString, tmpString);
            }
        }
    }
    Dialog_Show(playerid, "DIALOG_PORTMENU", DIALOG_STYLE_LIST, "Port - Lokacije", portStoreString, "Odaberi", "Izlaz");
    return 1;
}

stock Port_GetNextID()
{
    for (new i = 0; i < MAX_PORTS; i++)
        if (!PortData[i][portCreated])
            return i;
    return MAX_PORTS;
}

stock Port_GetNearby(const playerid)
{
    for (new i = 0; i < MAX_PORTS; ++i)
        if (IsPlayerInRangeOfPoint(playerid, 2.0, PortData[i][portX], PortData[i][portY], PortData[i][portZ]))
            return i;
    return MAX_PORTS;
}

stock Port_Save(portid)
{
    new portFile[60];
    format(portFile, sizeof(portFile), PORT_PATH, portid);
    new INI:File = INI_Open(portFile);
    INI_SetTag(File, "data");
    INI_WriteString(File, "portName", PortData[portid][portName]);
    INI_WriteFloat(File, "portX", PortData[portid][portX]);
    INI_WriteFloat(File, "portY", PortData[portid][portY]);
    INI_WriteFloat(File, "portZ", PortData[portid][portZ]);
    INI_Close(File);
    return 1;
}

Dialog:DIALOG_PORTMENU(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    SendInfoMsgF(playerid, "Teleportovali ste se do "ORANGE"%s"WHITE".", PortData[listitem][portName]);

    if (IsPlayerInAnyVehicle(playerid))
        SetVehiclePos(GetPlayerVehicleID(playerid), PortData[listitem][portX], PortData[listitem][portY], PortData[listitem][portZ]); 
    else
        Streamer_UpdateEx(playerid, PortData[listitem][portX], PortData[listitem][portY], PortData[listitem][portZ], .compensatedtime = 2000);

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}