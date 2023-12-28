#if defined _INC_admin_commands_inc
    #endinput
#endif
#define _INC_admin_commands_inc

#include <YSI_Coding\y_hooks>

static adminVehicle[MAX_PLAYERS] = -1,
    createdAdminVehicle[MAX_PLAYERS],
    Text3D: adminVehicleLabel[MAX_PLAYERS],
    playerDeveloper[MAX_PLAYERS],
    adminJetpack[MAX_PLAYERS],
    gDriftMode;

hook OnPlayerDisconnect(playerid, reason)
{
    createdAdminVehicle[playerid] = 0;
    if (adminVehicle[playerid] != -1)
        DestroyVehicle(adminVehicle[playerid]);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if (Rank_GetPlayerAdminLevel(playerid) == Rank_Owner())
    {
        if (IsPlayerInAnyVehicle(playerid))
            SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ);
        SetPlayerPos(playerid, fX, fY, fZ);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

forward Timer_KickPlayer(const playerid);
public Timer_KickPlayer(const playerid)
{
    Kick(playerid);
    return 1;
}

CMD:setadmin(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner() && !IsPlayerAdmin(playerid))
        return Rank_InsufficientMsg(playerid);

    static targetid, level;
    if (sscanf(params, "ii", targetid, level))
        return SendSyntaxMsg(playerid, "/setadmin [targetid] [level(0-3)]");

    Rank_SetAdminLevel(targetid, playerid, level);
    return 1;
}

CMD:wtf(const playerid, const params[])
{
    SendInfoMsgF(playerid, "admin:%d", Rank_GetPlayerAdminLevel(playerid));
    SendInfoMsgF(playerid, "vip:%d", Rank_IsPlayerVIP(playerid));
    return 1;
}

CMD:ah(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    new
        tmpString[2480],
        Alloc:str_alloc = malloc(sizeof(tmpString) + 1);

    if (Rank_GetPlayerAdminLevel(playerid) >= Rank_Junior())
    {
        strcat(tmpString, ""YELLOW"===================================[ADMIN KOMANDE]===================================\n\n", sizeof(tmpString));
        strcat(tmpString,
            ""YELLOW"Junior Admin: "WHITE"/veh /kill /cc /kick /vrespawn /gethere /goto\n\
            "YELLOW"Junior Admin: "WHITE"/jetpack /pm /a /slap\n\n", sizeof(tmpString)
        );
    }

    if (Rank_GetPlayerAdminLevel(playerid) >= Rank_Senior())
    {
        strcat(tmpString,
            ""YELLOW"Senior Admin: "WHITE"/veh /kill /cc /kick /vrespawn /gethere /goto /slap /portkuca /portkiosk\n\
           "YELLOW"Senior Admin: "WHITE"/jetpack /pm /a /pos /playmusic /setskin /time /weather /portatm\n\
           "YELLOW"Senior Admin: "WHITE"/ip\n\n", sizeof(tmpString)
        );
    }

    if (Rank_GetPlayerAdminLevel(playerid) >= Rank_Owner())
    {
        strcat(tmpString,
            ""YELLOW"Owner & Developer: "WHITE"/setadmin /veh /kill /cc /kick /vrespawn /gethere /goto /time /weather\n\
           "YELLOW"Owner & Developer: "WHITE"/jetpack /pm /a /pos /playmusic /setskin /bolnica /bankaint /spawn\n\
           "YELLOW"Owner & Developer: "WHITE"/setvip /portkuca /portkiosk /setstats /givegun /setorg /setorgrank\n\
           "YELLOW"Owner & Developer: "WHITE"/kreirajkucu /obrisikucu /kreirajvozilo /loadingmsg /angvel /setdeveloper\n\
           "YELLOW"Owner & Developer: "WHITE"/kreirajrent /drift /kreirajkiosk /obrisikiosk /izmenikiosk\n\
           "YELLOW"Owner & Developer: "WHITE"/infomsg /houseext /splitname /getdob /kreirajgps /kreirajport\n\
           "YELLOW"Owner & Developer: "WHITE"/kreirajatm /obrisiatm /izmeniatm /portatm /kreirajimovinu\n", sizeof(tmpString)
        );
    }
    
    if (Rank_GetPlayerAdminLevel(playerid) >= Rank_Junior())
    {
        strcat(tmpString, ""YELLOW"=====================================================================================\n\n", sizeof(tmpString));
    }

    msets(str_alloc, 0, tmpString);
    Dialog_Show(playerid, "DIALOG_ADMINHELP", DIALOG_STYLE_MSGBOX, ""YELLOW"Admin Komande", mget(str_alloc, 0), ""YELLOW"Zatvori", "");
    free(str_alloc);
    return 1;
}

CMD:slap(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);
 
    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/slap [targetid]");
 
    new Float:x, Float:y, Float:z;
    
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(targetid, x, y, z + 1.00);
 
    SendCustomMsgF(playerid, X11_RED, "[SLAP]: "WHITE"Osamarili ste igraca "RED"%s"WHITE".");
    SendCustomMsgF(targetid, X11_RED, "[SLAP]: "WHITE"Admin "RED"%s "WHITE"vas je osamario.");
    SendCustomMsgToAllF(X11_RED, "[SLAP]: "WHITE"Admin %s "WHITE"je osamario "RED"%s"WHITE"!", ReturnPlayerName(playerid), ReturnPlayerName(targetid));
    return 1;
}

CMD:ip(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);
 
    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/ip [targetid]");
 
    new ip[24];
    GetPlayerIp(targetid, ip, sizeof(ip));
    SendCustomMsgF(playerid, X11_RED, "* IP Adresa igraca "WHITE"%s: "RED"%s", ReturnPlayerName(targetid), ip);
    return 1;
}

// Command(name: pos, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:pos(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static Float: x, Float: y, Float: z;
    if (sscanf(params, "fff", x, y, z))
        return SendSyntaxMsg(playerid, "/pos [x] [y] [z]");

    Streamer_UpdateEx(playerid, x, y, z, .compensatedtime = 2000);
    return 1;
}

// Command(name: kill, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:kill(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/kill [targetid]");

    // if (!IsPlayerConnected(strval(params)))
    //     return SendErrorMsg(playerid, "Taj korisnik nije prijavljen!");

    SetPlayerHealth(strval(params), 0.0);
    SendServerMsgF(strval(params), "%s Vas je ubio.", ReturnPlayerName(playerid));
    SendServerMsgF(playerid, "Ubili ste %s.", ReturnPlayerName(strval(params)));

    // wlTimer[strval(params)] = SetTimerEx("Timer_RemoveWLBug", 2000, false, "d", strval(params));
    return 1;
}

// Command(name: cc, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:cc(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static lines;
    if (sscanf(params, "i", lines))
        return SendSyntaxMsg(playerid, "/cc [lines]");

    if (!(10 <= lines <= 60))
        return SendErrorMsg(playerid, "Ne mozete ispod 10 linija i iznad 60 linija!");

    foreach (new i: Player)
        Player_ClearChat(i, playerid, lines);
    return 1;
}

// Command(name: setstats, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:setstats(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        option[12],
        value;

    SendClientMessage(playerid, X11_GRAY, "*** Stats opcije ***");
    SendClientMessage(playerid, X11_GRAY, "[score][money][skin][spawn][bankcard][gold][hours][job][orgid][orgrank]");
    SendClientMessage(playerid, X11_GRAY, "[marijuana][wl][jailtime][mobile][mobilenum][mobilecredit][mobilepower]");

    if (sscanf(params, "rs[12]i", targetid, option, value))
        return SendSyntaxMsg(playerid, "/setstats [targetid] [option] [value]");

    if (!strcmp(option, "score", false))
    {
        if (!(1 <= value <= 1000))
            return SendErrorMsg(playerid, "Ne mozete postaviti level ispod 1 i iznad 1000!");

        Account_SetScore(targetid, value);
        SetPlayerScore(targetid, value);
        UI_UpdateInfoTD(targetid);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio level %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili level %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "money", false))
    {
        if (!(1 <= value <= 999999999))
            return SendErrorMsg(playerid, "Ne mozete postaviti novac ispod $1 i iznad $999.999.999!");

        Account_SetMoney(targetid, value);
        ResetPlayerMoney(targetid);
        GivePlayerMoney(targetid, value);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio novac na $%d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili novac na $%d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "skin", false))
    {
        if (!(1 <= value <= 311))
            return SendErrorMsg(playerid, "Ne mozete postaviti skin ispod 1 i iznad 311!");

        Account_SetSkin(targetid, value);
        SetPlayerSkin(targetid, value);
        UI_UpdateInfoTD(playerid);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio skin %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili skin %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "spawn", false))
    {
        if (!(1 <= value <= 3))
            return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 1 i iznad 3!");

        Account_SetSpawn(targetid, value);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio spawn na %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili spawn na %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "bankcard", false))
    {
        if (value > 1)
            return SendErrorMsg(playerid, "Ne mozete postaviti bankovni racun ispod 0 i iznad 1!");

        Account_SetBankCard(targetid, value);
        UI_UpdateInfoTD(playerid);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio status bankovnog racuna na %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili status bankovnog racuna na %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "gold", false))
    {
        if (value > 9999)
            return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 9999!");

        Account_SetGold(targetid, value);
        UI_UpdateInfoTD(playerid);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio zlato na %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili zlato na %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "hours", false))
    {
        if (value > 9999999)
            return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 9999999!");

        Account_SetHours(targetid, value);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio sate igre na %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili sate igre na %d. *", ReturnPlayerName(targetid), value);
    }

    else if (!strcmp(option, "job", false))
    {
        if (value > 4)
            return SendErrorMsg(playerid, "Ne mozete postaviti spawn ispod 0 i iznad 4!");

        Account_SetJob(targetid, value);

        SendCustomMsgF(targetid, X11_GRAY, "* %s Vam je postavio posao na %d. *", ReturnPlayerName(playerid), value);
        SendCustomMsgF(targetid, X11_GRAY, "* Igracu %s ste postavili posao na %d. *", ReturnPlayerName(targetid), value);
    }
    
    else
        return SendErrorMsg(playerid, "Pogresna opcija!");
    return 1;
}

// Command(name: kick, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:kick(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static targetid, reason[MAX_REASON_LENGTH];
    if (sscanf(params, "rs["#MAX_REASON_LENGTH"]", targetid, reason))
        return SendSyntaxMsg(playerid, "/kick [targetid] [reason]");

    if (targetid == _:playerid)
        return SendErrorMsg(playerid, "Ne mozete kikovati sebe!");

    if (Rank_GetPlayerAdminLevel(targetid))
        return SendErrorMsg(playerid, "Ne mozete kikovati administratora!");

    SendCustomMsgF(targetid, X11_RED, "(Kick): "WHITE"Kikovani ste od strane %s zbog "RED"%s"WHITE".", ReturnPlayerName(playerid), reason);
    SendCustomMsgF(playerid, X11_RED, "(Kick): "WHITE"Kikovali ste %s zbog "RED"%s"WHITE".", ReturnPlayerName(targetid), reason);
    SetTimerEx("Timer_KickPlayer", 1000, false, "d", targetid);
    return 1;
}

// Command(name: vrespawn, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:vrespawn(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    if (!IsPlayerInAnyVehicle(playerid))
        return SendErrorMsg(playerid, "Morate biti u vozilu!");

    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
    SendInfoMsg(playerid, "Respawnovali ste vozilo.");
    return 1;
}

// Command(name: pm, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:pm(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        message[MAX_REASON_LENGTH];

    if (sscanf(params, "rs["#MAX_REASON_LENGTH"]", targetid, message))
        return SendSyntaxMsg(playerid, "/pm [targetid] [message]");

    SendCustomMsgF(playerid, X11_CYAN, "#PM: "WHITE"Poslali ste poruku "CYAN"%s "WHITE"koja glasi: "CYAN"%s", ReturnPlayerName(targetid), message);
    SendCustomMsgF(targetid, X11_CYAN, "#PM: "WHITE"Poruka od "CYAN"%s "WHITE"koja glasi: "CYAN"%s", ReturnPlayerName(playerid), message);
    return 1;
}

// Command(name: playmusic, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:playmusic(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static url[64];
    if (sscanf(params, "s[64]", url))
        return SendSyntaxMsg(playerid, "/playmusic [url]");

    if (strfind(url, "http", false))
        return SendErrorMsg(playerid, "Nevazeci URL!");

    foreach (new i: Player)
    {
        PlayAudioStreamForPlayer(i, url);
        SendCustomMsgF(i, X11_LIGHTGREEN, "#Music: "WHITE"%s je pustio pesmu!", ReturnPlayerName(playerid));
    }
    return 1;
}

// Command(name: a, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:a(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static text[128];
    if (sscanf(params, "s[128]", text))
        return SendSyntaxMsg(playerid, "/a [text]");

    Rank_AdminMessage(X11_YELLOW, "[A-CHAT]: "LIGHTGRAY"[%s"LIGHTGRAY"] %s(%d): "WHITE"%s",
        Rank_GetAdminName(Rank_GetPlayerAdminLevel(playerid)), ReturnPlayerName(playerid), playerid, text
    );
    return 1;
}

// Command(name: givegun, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:givegun(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        weaponid,
        ammo;

    if (sscanf(params, "rii", targetid, weaponid, ammo))
        return SendSyntaxMsg(playerid, "/givegun [targetid] [weaponid] [ammo]");

    if (Rank_GetPlayerAdminLevel(playerid) != Rank_Owner())
    {
        switch (weaponid)
        {
            case 9: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 15: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 16: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 17: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 18: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 26: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 35: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 36: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 37: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 38: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 39: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
            case 40: return SendErrorMsg(playerid, "Ne mozete dati to oruzije!");
        }
    }

    if (!(1 <= ammo <= 999))
        return SendErrorMsg(playerid, "Ne mozete municiju ispod 1 i iznad 999!");

    GivePlayerWeapon(targetid, weaponid, ammo);
    SendCustomMsgF(playerid, X11_GRAY, "#Weapon: "WHITE"Dali ste oruzije %d igracu %s (ammo: %d)", weaponid, ReturnPlayerName(targetid), ammo);
    SendCustomMsgF(targetid, X11_GRAY, "#Weapon: "WHITE"Dobili ste oruzije %d od %s (ammo: %d)", weaponid, ReturnPlayerName(playerid), ammo);
    return 1;
}

// Command(name: portkuca, rank: Rank_Moderator(), args: playerid, const string: params[])
// CMD:portkuca(const playerid, const params[])
// {
//     if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
//         return Rank_InsufficientMsg(playerid);

//     static houseid;
//     if (sscanf(params, "i", houseid))
//         return SendSyntaxMsg(playerid, "/portkuca [id]");

//     if (!House_Goto(playerid, houseid))
//         return SendErrorMsg(playerid, "Pogresan ID!");

//     House_Goto(playerid, houseid);
//     return 1;
// }

// Command(name: portkiosk, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:portkiosk(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static kioskid;
    if (sscanf(params, "i", kioskid))
        return SendSyntaxMsg(playerid, "/portkiosk [id]");

    if (!Kiosk_Goto(playerid, kioskid))
        return SendErrorMsg(playerid, "Pogresan ID!");
    Kiosk_Goto(playerid, kioskid);
    return 1;
}

// Command(name: portkiosk, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:portatm(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static atmid;
    if (sscanf(params, "i", atmid))
        return SendSyntaxMsg(playerid, "/portatm [id]");

    if (!Atm_Goto(playerid, atmid))
        return SendErrorMsg(playerid, "Pogresan ID!");
    Atm_Goto(playerid, atmid);
    return 1;
}

// Command(name: goto, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:goto(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/goto [targetid]");

    if (!IsPlayerConnected(targetid))
        return 0;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    
    if (IsPlayerInAnyVehicle(playerid))
        SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);

    SetPlayerPos(playerid, x, y, z);
    SendCustomMsgF(targetid, X11_RED, "#GOTO: "WHITE"%s se teleportovao do Vas!", ReturnPlayerName(playerid));
    SendCustomMsgF(playerid, X11_RED, "#GOTO: Teleportovali ste se do "WHITE"%s!", ReturnPlayerName(targetid));
    return 1;
}

// Command(name: gethere, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:gethere(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/gethere [targetid]");

    if (!IsPlayerConnected(strval(params)))
        return 0;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    if (IsPlayerInAnyVehicle(targetid))
        SetVehiclePos(GetPlayerVehicleID(targetid), x, y, z);

    SetPlayerPos(targetid, x, y, z);
    SendCustomMsgF(targetid, X11_RED, "#GET-HERE: "WHITE"%s Vas je teleportovao do sebe!", ReturnPlayerName(playerid));
    SendCustomMsgF(playerid, X11_RED, "#GET-HERE: Teleportovali ste "WHITE"%s do sebe!", ReturnPlayerName(targetid));
    return 1;
}

// Command(name: setorg, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:setorg(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        orgid;

    if (sscanf(params, "ri", targetid, orgid))
        return SendSyntaxMsg(playerid, "/setorg [targetid] [orgid (/orglist)]");

    if (!(0 <= orgid <= 7))
        return SendErrorMsg(playerid, "Nepostojeca organizacija, (/orglist)!");

    if (!orgid && !Org_GetID(targetid))
        return SendErrorMsg(playerid, "Taj igrac nije u organizaciji!");

    if (!orgid && Org_GetID(targetid))
    {
        SendCustomMsgF(targetid, X11_RED, "(Organizacija): "WHITE"%s Vas je izbacio iz organizacije.", ReturnPlayerName(playerid));
        SendCustomMsgF(playerid, X11_RED, "(Organizacija): "WHITE"Igraca %s ste izbacili iz organizacije.", ReturnPlayerName(targetid));
        Org_SetID(targetid, 0);
        Org_SetRank(targetid, 0);
        Account_SetSkin(targetid, 1);
        return 1;
    }

    if (Org_GetID(targetid) == orgid)
        return SendErrorMsg(playerid, "Taj igrac je vec u toj organizaciji!");

    Org_SetID(targetid, orgid);
    SendCustomMsgF(targetid, X11_LIGHTGREEN, "(Organizacija): "WHITE"%s Vas je ubacio u organizaciju '"LIGHTGREEN"%s"WHITE"'.", ReturnPlayerName(playerid), Org_GetNameByID(orgid));
    SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Organizacija): "WHITE"Ubacili ste %s u organizaciju '"LIGHTGREEN"%s"WHITE"'.", ReturnPlayerName(targetid), Org_GetNameByID(orgid));
    return 1;
}

// Command(name: setorgrank, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:setorgrank(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        rankid;

    if (sscanf(params, "ri", targetid, rankid))
        return SendSyntaxMsg(playerid, "/setorgrank [targetid] [rank (1-5)]");

    if (!Org_GetID(targetid))
        return SendErrorMsg(playerid, "Taj igrac nije u organizaciji!");

    if (!(1 <= rankid <= 5))
        return SendErrorMsg(playerid, "Nepostojeci rank, (1-5)!");

    if (rankid == Org_GetRank(targetid))
        return SendErrorMsg(playerid, "Taj igrac je vec taj rank!");

    Org_SetRank(targetid, rankid);
    SendCustomMsgF(targetid, X11_LIGHTGREEN, "(Organizacija): "WHITE"%s Vam je postavio '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(playerid), rankid);
    SendCustomMsgF(playerid, X11_LIGHTGREEN, "(Organizacija): "WHITE"Igracu %s ste postavili '"LIGHTGREEN"%d"WHITE"' rank.", ReturnPlayerName(targetid), rankid);
    return 1;
}

// Command(name: org, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:org(const playerid, const params[])
{
    SendInfoMsgF(playerid, "org: %d | rank: %d", Org_GetID(playerid), Org_GetRank(playerid));
    return 1;
}

// Command(name: setskin, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:setskin(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static
        targetid,
        skinid;

    if (sscanf(params, "ri", targetid, skinid))
        return SendSyntaxMsg(playerid, "/setskin [targetid] [skinid]");

    if (!(1 <= skinid <= 299))
        return SendErrorMsg(playerid, "Ne mozete skin id ispod 1 i iznad 299!");

    Account_SetSkin(targetid, skinid);
    SendCustomMsgF(playerid, X11_CYAN, "#Skin: "WHITE"Postavili ste igracu %s skin id %d.", ReturnPlayerName(targetid), skinid);
    SendCustomMsgF(targetid, X11_CYAN, "#Skin: "WHITE"%s Vam je postavio skin id %d.", ReturnPlayerName(playerid), skinid);
    return 1;
}

// Command(name: port, rank: Rank_Moderator(), args: playerid, const string: params[])
CMD:port(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    Port_ShowMenu(playerid);
    return 1;
}

// Command(name: veh, rank: Rank_Administrator() && Rank_Moderator(), args: playerid, const string: params[])
CMD:veh(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    if (createdAdminVehicle[playerid])
    {
        DestroyVehicle(adminVehicle[playerid]);
        GameTextForPlayer(playerid, "~r~Vozilo unisteno!", 3000, 3);
        DestroyDynamic3DTextLabel(adminVehicleLabel[playerid]);
        createdAdminVehicle[playerid] = !createdAdminVehicle[playerid];

        if (Player_GetSeatbelt(playerid))
            Vehicle_SetSeatbelt(playerid);

        if (Vehicle_GetEngine(playerid))
            Vehicle_SetEngine(playerid);

        if (Vehicle_GetLights(playerid))
            Vehicle_SetLights(playerid);
        return 1;
    }
    
    static vehid, color1, color2, Float: x, Float: y, Float: z, Float: a;
    if (sscanf(params, "iii", vehid, color1, color2))
        return SendSyntaxMsg(playerid, "/veh [vehid] [color1] [color2]");

    if (!(400 <= vehid <= 611))
        return SendErrorMsg(playerid, "Pogresan ID vozila (400-611)!");

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    adminVehicle[playerid] = CreateVehicle(vehid, x, y, z, a, color1, color2, 0);
    PutPlayerInVehicle(playerid, adminVehicle[playerid], 0);
    va_GameTextForPlayer(playerid, "~y~Vozilo ID: %d", 3000, 3, vehid);
    Vehicle_SetColor(GetPlayerVehicleID(playerid), color1, color2);
    Vehicle_SetFuel(adminVehicle[playerid], 50);

    static tmpString[64];
    format(tmpString, sizeof(tmpString), ""YELLOW"[ VLASNIK: "WHITE"%s "YELLOW"]", ReturnPlayerName(playerid));
    adminVehicleLabel[playerid] = CreateDynamic3DTextLabel(tmpString, -1, 0.0, 0.0, 0.0, 30.00, .attachedvehicle = adminVehicle[playerid]);
    createdAdminVehicle[playerid] = !createdAdminVehicle[playerid];
    return 1;
}

// Command(name: bolnica, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:bolnica(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    Streamer_UpdateEx(playerid, 1165.7496, -1339.2876, 13.5935, .compensatedtime = 2000);
    return 1;
}

// Command(name: bankaint, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:bankaint(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    Streamer_UpdateEx(playerid, 1376.723510, -21.226245, 1004.034240, .compensatedtime = 2000);
    return 1;
}

// Command(name: time, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:time(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static time;
    if (sscanf(params, "i", time))
        return SendSyntaxMsg(playerid, "/time [0-24]");

    if (!(0 <= time <= 24))
        return SendErrorMsg(playerid, "Odaberite vreme izmedju 0 i 24!");

    SetWorldTime(time);
    Rank_AdminMessage(X11_ORANGE, "* %s je podesio sate na %d.", ReturnPlayerName(playerid), strval(params));
    return 1;
}

// Command(name: weather, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:weather(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Senior())
        return Rank_InsufficientMsg(playerid);

    static weather;
    if (sscanf(params, "i", weather))
        return SendSyntaxMsg(playerid, "/weather [0-20]");

    if (!(0 <= weather <= 20))
        return SendErrorMsg(playerid, "Odaberite vreme izmedju 0 i 20!");

    SetWorldTime(weather);
    Rank_AdminMessage(X11_ORANGE, "* %s je podesio vreme na %d.", ReturnPlayerName(playerid), strval(params));
    return 1;
}

// Command(name: spawn, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:spawn(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    SetPlayerPos(playerid, 1591.921,-2334.499,13.152);
    return 1;
}

/*Command(name: testwe, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    Winter_SetStatusAll(playerid);
    return 1;
}

Command(name: kreirajjelku, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    new Float: x, Float: y, Float: z,
        xmasid = Xmas_GetNextTreeID();

    if (xmasid == Xmas_GetMaxTrees())
        return SendCustomMsgF(playerid, X11_RED, "(Jelka!): "WHITE"Kreiran je maksimalan broj jelki!");

    GetPlayerPos(playerid, x, y, z);
    Xmas_CreateTree(xmasid, x, y, z);

    new String: str_query_insert = str_format(
        "INSERT INTO xmastree (xmas_id, xmas_x, xmas_y, xmas_z) VALUES ('%d', '%f', '%f', '%f')",
        xmasid + 1, x, y, z 
    );
    mysql_tquery_s(MySQL_GetHandle(), str_query_insert);
    return 1;
}

Command(name: obrisijelku, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    new xmasid = Xmas_GetNearbyID(playerid);
    if (xmasid == Xmas_GetMaxTrees())
        return SendErrorMsg(playerid, "Morate biti blizu jelke!");

    Xmas_DestroyTree(xmasid);
    SendCustomMsgF(playerid, X11_RED, "(Jelka): "WHITE"Obrisali ste jelku "RED"%d"WHITE".", xmasid);

    new String: str_query_delete = str_format("DELETE FROM xmastree WHERE xmas_id = '%d'", xmasid + 1);
    mysql_tquery_s(MySQL_GetHandle(), str_query_delete);
    return 1;
}

Command(name: portjelka, rank: Rank_Administrator() && Rank_Moderator(), args: playerid, const string: params[])
{
    if (isnull(params) && !IsNumeric(params))
        return SendSyntaxMsg(playerid, "/portjelka [id]");

    if (!Xmas_GotoTree(playerid, strval(params)))
        return SendErrorMsg(playerid, "Pogresan ID!");
    Xmas_GotoTree(playerid, strval(params));
    return 1;
}*/

// Command(name: kreirajkucu, rank: Rank_Administrator(), args: playerid, const string: params[])
// CMD:kreirajkucu(const playerid, const params[])
// {
//     if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
//         return Rank_InsufficientMsg(playerid);

//     new Float:x, Float:y, Float:z,
//         houseid = House_GetNextID(House_GetMaxHouses());

//     if (houseid == House_GetMaxHouses())
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Kreiran je maksimalan broj kuca!");

//     static price;
//     if (sscanf(params, "i", price))
//         return SendSyntaxMsg(playerid, "/kreirajkucu [price]");

//     GetPlayerPos(playerid, x, y, z);
//     House_Create(playerid, houseid, price, x, y, z);

//     // new str_query_insert[256];
//     // mysql_format(MySQL_GetHandle(), str_query_insert, sizeof(str_query_insert),
//     //     "INSERT INTO houses (house_id, house_owner, house_vw, house_extx, house_exty, house_extz, house_desc, house_price) \
//     //     VALUES ('%d', 'Niko', '%d', '%f', '%f', '%f', 'Na prodaju', '%d')", (houseid + 1), (houseid + 1), x, y, z, price
//     // );
//     // mysql_query(MySQL_GetHandle(), str_query_insert);
//     return 1;
// }

// // Command(name: obrisikucu, rank: Rank_Administrator(), args: playerid, const string: params[])
// CMD:obrisikucu(const playerid, const params[])
// {
//     if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
//         return Rank_InsufficientMsg(playerid);

//     new houseid = House_GetNearby(playerid);
//     if (houseid == House_GetMaxHouses())
//         return SendCustomMsgF(playerid, X11_RED, "(Kuca!): "WHITE"Morate biti blizu neke kuce!");

//     House_Destroy(playerid, houseid);

//     // new str_query_delete[64];
//     // mysql_format(MySQL_GetHandle(), str_query_delete, sizeof(str_query_delete), "DELETE FROM houses WHERE house_id = '%d'", (houseid + 1));
//     // mysql_query(MySQL_GetHandle(), str_query_delete);
//     return 1;
// }

// Command(name: kreirajvozilo, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:kreirajvozilo(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new vehicleid = Vehicle_GetNextID(MAX_VEHICLES),
        modelid,
        Float:x, Float:y, Float:z, Float:a,
        color1, color2,
        locked;

    if (sscanf(params, "iiii", modelid, color1, color2, locked))
        return SendSyntaxMsg(playerid, "/kreirajvozilo [modelid] [color1] [color2] [locked(0-1)]");

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    Vehicle_Create(vehicleid, modelid, "Niko", x, y, z, a, color1, color2, locked);
    SendCustomMsgF(playerid, MAIN_COLOR_HEX, "(Vozilo): "WHITE"Kreirali ste vozilo!");
    return 1;
}

// Command(name: loadingmsg, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:loadingmsg(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    static delay, msg[MAX_REASON_LENGTH];
    if (sscanf(params, "s["#MAX_REASON_LENGTH"]i", msg, delay))
        return SendSyntaxMsg(playerid, "/loadingmsg [text] [delay(s)]");

    UI_ShowLoadingTextDraw(playerid, msg, (delay * 1000));
    return 1;
}

// Command(name: angvel, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:angvel(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    static pos[2],
        Float:value;

    if (sscanf(params, "s[2]f", pos, value))
        return SendSyntaxMsg(playerid, "/angvel [x|y|z] [value]");

    if (!strcmp(pos, "x", false))
        SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), value, 0.0, 0.0);
    else if (!strcmp(pos, "y", false))
        SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), 0.0, value, 0.0);
    else if (!strcmp(pos, "z", false))
        SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, value);
    return 1;
}

// Command(name: setdeveloper, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:setdeveloper(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!IsPlayerAdmin(playerid))
        return SendErrorMsg(playerid, "Samo RCON Administrator!");

    static targetid;
    if (sscanf(params, "r", targetid))
        return SendSyntaxMsg(playerid, "/setdeveloper [targetid]");

    if (!IsPlayerConnected(targetid))
        return 0;

    playerDeveloper[targetid] = !playerDeveloper[targetid];
    return 1;
}

/*Command(name: kreirajklupu, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    new Float:x, Float:y, Float:z,
        benchid = Bench_GetNextID();

    if (benchid == Bench_GetMaxBenches())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Klupa!): "WHITE"Kreiran je maksimalan broj klupa!");

    GetPlayerPos(playerid, x, y, z);
    Bench_Create(benchid, x, y, z);
    Bench_SetCurrentID(playerid, benchid);
    EditDynamicObject(playerid, Bench_ReturnObject(benchid));

    new String: str_query_insert = str_format(
        "INSERT INTO benches (bench_id, bench_x, bench_y, bench_z, bench_rotx, bench_roty, bench_rotz) \
        VALUES ('%d', '%f', '%f', '%f', '0.0', '0.0', '0.0')",
        (benchid + 1), x, y, z
    );
    mysql_tquery_s(MySQL_GetHandle(), str_query_insert);
    return 1;
}

Command(name: obrisiklupu, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    new benchid = Bench_GetNearby(playerid);
    if (benchid == Bench_GetMaxBenches())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Klupa!): "WHITE"Morate biti blizu neke klupe!");

    Bench_Destroy(benchid);
    SendCustomMsgF(playerid, X11_YELLOW, "(Klupa): "WHITE"Obrisali ste klupu %d.", benchid);
    new String: str_query_delete = str_format("DELETE FROM benches WHERE bench_id = '%d'", (benchid + 1));
    mysql_tquery_s(MySQL_GetHandle(), str_query_delete);
    return 1;
}

Command(name: portklupa, rank: Rank_Administrator() && Rank_Moderator(), args: playerid, const string: params[])
{
    if (isnull(params) && !IsNumeric(params))
        return SendSyntaxMsg(playerid, "/portklupa [id]");

    if (!Bench_Goto(playerid, strval(params)))
        return SendErrorMsg(playerid, "Pogresan ID!");
    Bench_Goto(playerid, strval(params));
    return 1;
}

Command(name: izmeniklupu, rank: Rank_Administrator(), args: playerid, const string: params[])
{
    new benchid = Bench_GetNearby(playerid);
    if (benchid == Bench_GetMaxBenches())
        return SendCustomMsgF(playerid, X11_RED, "(Klupa!): "WHITE"Morate biti blizu neke klupe!");

    Bench_SetCurrentID(playerid, benchid);
    Bench_SetEditingMode(playerid, true);
    EditDynamicObject(playerid, Bench_ReturnObject(benchid));
    return 1;
}*/

// Command(name: jetpack, rank: Rank_Administrator() && Rank_Moderator(), args: playerid, const string: params[])
CMD:jetpack(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Junior())
        return Rank_InsufficientMsg(playerid);

    adminJetpack[playerid] = !adminJetpack[playerid];
    if (!adminJetpack[playerid])
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        GameTextForPlayer(playerid, "~r~SKINULI STE JETPACK!", 3000, 3);
        return 1;
    }

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
    GameTextForPlayer(playerid, "~g~UZELi STE JETPACK!", 3000, 3);
    return 1;
}

// Command(name: kreirajrent, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:kreirajrent(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new rentid = Rent_GetNextID(Rent_GetMaxPickups()),
        Float:x, Float:y, Float:z;

    GetPlayerPos(playerid, x, y, z);
    Rent_Create(rentid, x, y, z);

    // new str_query_insert[128];
    // mysql_format(MySQL_GetHandle(), str_query_insert, sizeof(str_query_insert),
    //     "INSERT INTO rents (rent_id, rent_x, rent_y, rent_z) VALUES ('%d', '%f', '%f', '%f')",
    //     (rentid + 1), x, y, z
    // );
    // mysql_query(MySQL_GetHandle(), str_query_insert);
    return 1;
}

// Command(name: drift, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:drift(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    gDriftMode = !gDriftMode;
    SetGravity(!gDriftMode ? 0.008 : 0.006);
    return 1;
}

// Command(name: hungerall, rank: Rank_Administrator(), args: playerid, const string: params[])
// {
//  static Float:value;
//  if (sscanf(params, "f", value))
//      return SendSyntaxMsg(playerid, "/hungerall [value]");

//  if (!(0.00 <= value <= 100.00))
//      return SendErrorMsg(playerid, "Ne mozete ispod 0.00 i iznad 100.00!");

//  foreach (new i: Player)
//  {
//      Hunger_SetValue(i, value);
//      SendCustomMsgF(i, X11_ORANGE, "#Hunger: "WHITE"Administrator %s je postavio svima glad na "ORANGE"%.2f"WHITE"!", ReturnPlayerName(playerid), value);
//  }
//  return 1;
// }

// Command(name: thirstall, rank: Rank_Administrator(), args: playerid, const string: params[])
// {
//  static Float:value;
//  if (sscanf(params, "f", value))
//      return SendSyntaxMsg(playerid, "/thirstall [value]");

//  if (!(0.00 <= value <= 100.00))
//      return SendErrorMsg(playerid, "Ne mozete ispod 0.00 i iznad 100.00!");

//  foreach (new i: Player)
//  {
//      Thirst_SetValue(i, value);
//      SendCustomMsgF(i, X11_ORANGE, "#Thirst: "WHITE"Administrator %s je postavio svima zedj na "ORANGE"%.2f"WHITE"!", ReturnPlayerName(playerid), value);
//  }
//  return 1;
// }

// Command(name: kreirajkiosk, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:kreirajkiosk(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new Float:x, Float:y, Float:z,
        kioskid = Kiosk_GetNextID(Kiosk_GetMaxIDs());

    if (kioskid == Kiosk_GetMaxIDs())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Kiosk!): "WHITE"Kreiran je maksimalan broj kioska!");

    GetPlayerPos(playerid, x, y, z);
    Kiosk_Create(kioskid, x, y, z);
    Kiosk_CurrentID(playerid, kioskid);
    EditDynamicObject(playerid, Kiosk_ReturnObject(kioskid));
    return 1;
}

// Command(name: obrisikiosk, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:obrisikiosk(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new kioskid = Kiosk_GetNearby(playerid);
    if (kioskid == Kiosk_GetMaxIDs())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Kiosk!): "WHITE"Morate biti blizu nekog kioska!");

    Kiosk_Destroy(kioskid);
    SendCustomMsgF(playerid, X11_YELLOW, "(Kiosk): "WHITE"Obrisali ste kiosk %d.", kioskid);
    return 1;
}

// Command(name: izmenikiosk, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:izmenikiosk(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new kioskid = Kiosk_GetNearby(playerid);
    if (kioskid <= 0)
        return SendCustomMsgF(playerid, X11_RED, "(Kiosk!): "WHITE"Morate biti blizu nekog kioska!");

    Kiosk_SetEditingMode(playerid, true);
    EditDynamicObject(playerid, Kiosk_ReturnObject(kioskid));
    return 1;
}

CMD:kreirajatm(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new Float:x, Float:y, Float:z,
        atmid = Atm_GetNextID(Atm_GetMaxIDs());

    if (atmid == Atm_GetMaxIDs())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Bankomat!): "WHITE"Kreiran je maksimalan broj bankomata!");

    GetPlayerPos(playerid, x, y, z);
    Atm_Create(atmid, x, y, z);
    Atm_CurrentID(playerid, atmid);
    EditDynamicObject(playerid, Atm_ReturnObject(atmid));
    return 1;
}

CMD:obrisiatm(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new atmid = Atm_GetNearby(playerid);
    if (atmid == Atm_GetMaxIDs())
        return SendCustomMsgF(playerid, X11_YELLOW, "(Bankomat!): "WHITE"Morate biti blizu nekog bankomata!");

    Atm_Destroy(atmid);
    SendCustomMsgF(playerid, X11_YELLOW, "(Bankomat): "WHITE"Obrisali ste bankomat %d.", atmid);
    return 1;
}

CMD:izmeniatm(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    new atmid = Atm_GetNearby(playerid);
    if (atmid <= 0)
        return SendCustomMsgF(playerid, X11_RED, "(Bankomat!): "WHITE"Morate biti blizu nekog bankomata!");

    Atm_SetEditingMode(playerid, true);
    EditDynamicObject(playerid, Atm_ReturnObject(atmid));
    return 1;
}

// Command(name: infomsg, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:infomsg(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    UI_ShowInfoMessage(playerid, 2000, "Tvoje ime je %s", ReturnPlayerName(playerid));
    return 1;
}

// Command(name: houseext, rank: Rank_Administrator(), args: playerid, const string: params[])
// CMD:houseext(const playerid, const params[])
// {
//     if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
//         return Rank_InsufficientMsg(playerid);

//     if (!playerDeveloper[playerid])
//         return SendErrorMsg(playerid, "Samo developer!");

//     static houseid;
//     if (sscanf(params, "i", houseid))
//         return SendSyntaxMsg(playerid, "/houseext [houseid]");

//     new i = houseid;
//     SetPlayerPos(playerid, House_GetPos(i, 0), House_GetPos(i, 1), House_GetPos(i, 2));
//     return 1;
// }

// Command(name: splitname, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:splitname(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    if (!playerDeveloper[playerid])
        return SendErrorMsg(playerid, "Samo developer!");

    static
        targetid,
        part;

    if (sscanf(params, "ri", targetid, part))
        return SendSyntaxMsg(playerid, "/splitname [targetid] [part(1-name|2-lastname)]");

    SendInfoMsgF(playerid, "%s", Player_SplitName(targetid, part == 1 ? "name" : part == 2 ? "lastname" : ""));
    return 1;
}

// Command(name: getdob, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:getdob(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    SendInfoMsgF(playerid, "%s", Account_GetDOB(playerid));
    return 1;
}

// Command(name: kreirajgps, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:kreirajgps(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static gpsname[16];
    if (sscanf(params, "s[16]", gpsname))
        return SendSyntaxMsg(playerid, "/kreirajgps [ime lokacije]");

    new
        gpsid = GPS_GetNextID(),
        Float:x, Float:y, Float:z;

    GetPlayerPos(playerid, x, y, z);
    GPS_Create(gpsid, gpsname, x, y, z);
    SendInfoMsg(playerid, "Uspesno ste kreirali GPS.");
    return 1;
}

// Command(name: testwl, rank: Rank_Administrator(), args: playerid, const string: params[])
// {
//  if (!playerDeveloper[playerid])
//      return SendErrorMsg(playerid, "Samo developer!");

//  if (isnull(params) || !IsNumeric(params))
//      return SendSyntaxMsg(playerid, "/testwl [value]");
    
//  WantedLevel_Set(playerid, strval(params));
//  return 1;
// }

// Command(name: kreirajport, rank: Rank_Administrator(), args: playerid, const string: params[])
CMD:kreirajport(const playerid, const params[])
{
    if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
        return Rank_InsufficientMsg(playerid);

    static portname[16];
    if (sscanf(params, "s[16]", portname))
        return SendSyntaxMsg(playerid, "/kreirajport [ime lokacije]");

    new
        portid = Port_GetNextID(),
        Float:x, Float:y, Float:z;

    if (portid == Port_GetMaxPorts())
        return SendCustomMsgF(playerid, X11_RED, "(Port!): "WHITE"Kreiran je maksimalan broj portova!");

    GetPlayerPos(playerid, x, y, z);
    Port_Create(portid, portname, x, y, z);
    SendInfoMsg(playerid, "Uspesno ste kreirali port.");
    return 1;
}

// Command(name: setjailtime, rank: Rank_Administrator(), args: playerid, const string: params[])
// {
//  if (isnull(params) || !IsNumeric(params))
//      return SendSyntaxMsg(playerid, "/testjail [time]");

//  Account_SetJailTime(playerid, strval(params));
//  return 1;
// }

// Command(name: getjailtime, rank: Rank_Administrator(), args: playerid, const string: params[])
// {
//  SendInfoMsgF(playerid, "Jail time: %d", Account_GetJailTime(playerid));
//  return 1;
// }

// Command(name: testwl, rank: Rank_Administrator(), args: playerid, const string: params[])
// CMD:testwl(const playerid, const params[])
// {
//     if (Rank_GetPlayerAdminLevel(playerid) < Rank_Owner())
//         return Rank_InsufficientMsg(playerid);

//     static wl;
//     if (sscanf(params, "i", wl))
//         return SendSyntaxMsg(playerid, "/testwl [level]");

//     WantedLevel_Set(playerid, (GetPlayerWantedLevel(playerid) + wl));
//     SendInfoMsgF(playerid, "Wanted: %d", GetPlayerWantedLevel(playerid));
//     return 1;
// }