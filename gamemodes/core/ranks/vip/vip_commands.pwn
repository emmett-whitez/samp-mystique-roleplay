/*
VIP KOMANDE:
/g /port /vipgoto /fv /mask /bank /vipmenu
*/

// Command(name: g, rank: Rank_VIP(), args: playerid, const string: params[])
// {
//     if (isnull(params))
//         return SendSyntaxMsg(playerid, "/g [text]");

//     if (strlen(params) > 128)
//         return SendErrorMsg(playerid, "Predugacak tekst!");

//     Rank_VIPMessage(X11_LIMEGREEN, "[G-CHAT]: "LIGHTGRAY"[%s"LIGHTGRAY"] %s(%d): "WHITE"%s",
//         Rank_GetNameByID(Rank_GetID(playerid)),
//         ReturnPlayerName(playerid), playerid, params
//     );
//     return 1;
// }

CMD:viph(const playerid, const params[])
{
    // This command doesn't need to check if player is a vip
    // because if someone wants to buy a vip they can see what vip can do.
    Dialog_Show(playerid, "DIALOG_PLAYERHELP", DIALOG_STYLE_MSGBOX,
        ""GREEN"gta-world - "WHITE"VIP Komande",
        ""GREEN"=========================[VIP KOMANDE]=========================\n\n\
        "GREEN"Komande: "WHITE"/vipgoto /nitro /port /banka /namecolor /vipskin\n\
        "GREEN"===============================================================",
        ""GREEN"Zatvori"
    );
    return 1;
}

CMD:nitro(const playerid, const params[])
{
    if (!Rank_IsPlayerVIP(playerid) && Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    if (!IsPlayerInAnyVehicle(playerid))
        return SendErrorMsg(playerid, "Morate biti u vozilu!");

    if (!strcmp(Vehicle_GetType(GetVehicleModel(GetPlayerVehicleID(playerid))), "Motor", false) ||
        !strcmp(Vehicle_GetType(GetVehicleModel(GetPlayerVehicleID(playerid))), "Helikopter", false) ||
        !strcmp(Vehicle_GetType(GetVehicleModel(GetPlayerVehicleID(playerid))), "Biciklo", false) ||
        !strcmp(Vehicle_GetType(GetVehicleModel(GetPlayerVehicleID(playerid))), "Avion", false)
    ) return SendErrorMsg(playerid, "Ne mozete u tom vozilu dodati nitro!");

    AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
    SendInfoMsg(playerid, "Uspesno ste dodali nitro u vozilo!");
    return 1;
}