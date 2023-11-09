#if defined _INC_port_init_inc
	#endinput
#endif
#define _INC_port_init_inc

#include <YSI_Coding\y_hooks>

const MAX_PORTS = 20;

static
    portID[MAX_PORTS],
    portCreated[MAX_PORTS],
    portName[MAX_PORTS][32],
    Float:portX[MAX_PORTS],
    Float:portY[MAX_PORTS],
    Float:portZ[MAX_PORTS],
    portStoreString[YSI_MAX_STRING],
    portTotal;

hook OnGameModeInit()
{
    mysql_tquery(MySQL_GetHandle(), "SELECT * FROM ports", "Port_Load");
    return Y_HOOKS_CONTINUE_RETURN_1;
}

forward Port_Load();
public Port_Load()
{
    if (!cache_num_rows())
        return 0;

    static rows;
    cache_get_row_count(rows);

    for (new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "port_id", portID[i]);
        cache_get_value_name(i, "port_name", portName[i]);
        cache_get_value_name_float(i, "port_x", portX[i]);
        cache_get_value_name_float(i, "port_y", portY[i]);
        cache_get_value_name_float(i, "port_z", portZ[i]);

        format(portStoreString, sizeof(portStoreString), "%s[%d]. %s\n", portStoreString, portID[i], portName[i]);
        portCreated[i] = 1;
        portTotal++;
    }

    printf("[PORT]: Ucitano %d portova.", portTotal);
    return 1;
}

stock Port_GetMaxPorts() return MAX_PORTS;
stock Port_Create(const portid, const portname[], Float:portx, Float:porty, Float:portz)
{
    portID[portid] = portid;
    portX[portid] = portx;
    portY[portid] = porty;
    portZ[portid] = portz;
    portCreated[portid] = 1;

    strcopy(portName[portid], portname);
    format(portStoreString, sizeof(portStoreString), "%s[%d]. %s\n", portStoreString, portID[portid] + 1, portName[portid]);

    new String:str_query_insert = str_format(
        "INSERT INTO ports (port_id, port_name, port_x, port_y, port_z) VALUES ('%d', '%e', '%f', '%f', '%f')",
        portid + 1, portName[portid], portX[portid], portY[portid], portZ[portid]
    );
    mysql_tquery_s(MySQL_GetHandle(), str_query_insert);
    return 1;
}

stock Port_ShowMenu(const playerid)
{
    Dialog_Show(playerid, "DIALOG_PORTMENU", DIALOG_STYLE_LIST, "Port - Lokacije", portStoreString, "Odaberi", "Izlaz");
    return 1;
}

stock Port_GetNextID()
{
    for (new i = 0; i < MAX_PORTS; i++)
        if (!portCreated[i])
            return i;
    return MAX_PORTS;
}

stock Port_GetNearby(const playerid)
{
    for (new i = 0; i < MAX_PORTS; ++i)
        if (IsPlayerInRangeOfPoint(playerid, 2.0, portX[i], portY[i], portZ[i]))
            return i;
    return MAX_PORTS;
}

Dialog:DIALOG_PORTMENU(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return 1;

    task_await(
        MySQL_QueryS(
            str_format("SELECT * FROM ports WHERE port_id = '%d'", listitem + 1)
        )
    );

    if (cache_num_rows())
    {
        SendInfoMsgF(playerid, "Teleportovali ste se do "ORANGE"%s"WHITE".", portName[listitem]);

        if (IsPlayerInAnyVehicle(playerid))
        	SetVehiclePos(GetPlayerVehicleID(playerid), portX[listitem], portY[listitem], portZ[listitem]);	
        else
        	Streamer_UpdateEx(playerid, portX[listitem], portY[listitem], portZ[listitem], .compensatedtime = 2000);

       	SetPlayerInterior(playerid, 0);
       	SetPlayerVirtualWorld(playerid, 0);
    }
    return 1;
}