#if defined _INC_ui_ingame_inc
    #endinput
#endif
#define _INC_ui_ingame_inc

#include <YSI_Coding\y_hooks>

static
    PlayerText:uiTextDrawIG[MAX_PLAYERS][39] = {PlayerText: INVALID_PLAYER_TEXT_DRAW,...},
    PlayerText:uiLoadingTextDraw[MAX_PLAYERS] = {PlayerText: INVALID_PLAYER_TEXT_DRAW,...},
    PlayerText:uiLoginTextDraw[MAX_PLAYERS][24] = {PlayerText: INVALID_PLAYER_TEXT_DRAW,...},
    PlayerText:uiInfoTextDraw[MAX_PLAYERS] = {PlayerText: INVALID_PLAYER_TEXT_DRAW,...},
    PlayerBar:uiLoadingProgressBar[MAX_PLAYERS] = {PlayerBar: INVALID_PLAYER_BAR_ID,...},
    bool:uiTextDrawIGStatus[MAX_PLAYERS] = false,
    bool:uiTextDrawSpeedo[MAX_PLAYERS] = false,
    bool:uiLoadingCreated[MAX_PLAYERS] = false,
    bool:uiLoginTextDrawStatus[MAX_PLAYERS] = false,
    uiLoadingTimer[MAX_PLAYERS][2],
    uiInfoTimer[MAX_PLAYERS],
    uiLoadingDelay[MAX_PLAYERS],
    uiInfoDelay[MAX_PLAYERS],
    bool:uiInfoTextDrawCreated[MAX_PLAYERS],
    vehicleEngine[MAX_PLAYERS],
    vehicleLights[MAX_PLAYERS],
    vehicleColor[MAX_VEHICLES][2],
    vehicleFuel[MAX_VEHICLES];

new const randomMessages[][] =
{
    "Ako vam nesto nije jasno, pitajte staff team na /askq.",
    "Ukoliko ste pronasli bug na serveru, prijavite ga na /report.",
    "Srecne praznike zeli vam Mystique staff team!",
    "Hvala vam sto igrate na nasem serveru.",
    "Zelis postati clan staff teama? Javi se vlasniku/adminu zaduzenom za staff team!",
    "Sakupljajte sate igre, sto vise sati igre, vece su nagrade!",
    "Svakog vikenda staff team dodeljuje nagrade svim igracima!"
};

new const modelNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxvillde", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};

forward UI_HideLoadingUI(const playerid);
public UI_HideLoadingUI(const playerid)
{
    DestroyPlayerProgressBar(playerid, uiLoadingProgressBar[playerid]);
    PlayerTextDrawDestroy(playerid, uiLoadingTextDraw[playerid]);
    uiLoadingTextDraw[playerid] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
    uiLoadingProgressBar[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
    uiLoadingCreated[playerid] = false;
    uiLoadingDelay[playerid] = 0;

    KillTimer(uiLoadingTimer[playerid][0]);
    KillTimer(uiLoadingTimer[playerid][1]);
    return 1;
}

forward UI_UpdateLoadingUI(const playerid);
public UI_UpdateLoadingUI(const playerid)
{
    new Float:value = GetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid]);
    value = floatround(value);
    if (value != 100)
        SetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid], value + (floatround(100 / (uiLoadingDelay[playerid] / 1000))));
    else
        SetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid], 0.0);
    return 1;
}

// TIMER__ UI_HIDELOADINGUI[uiLoadingDelay[playerid] + 500](playerid)
// {
//     DestroyPlayerProgressBar(playerid, uiLoadingProgressBar[playerid]);
//     PlayerTextDrawDestroy(playerid, uiLoadingTextDraw[playerid]);
//     uiLoadingTextDraw[playerid] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
//     uiLoadingProgressBar[playerid] = PlayerBar:INVALID_PLAYER_BAR_ID;
//     uiLoadingCreated[playerid] = false;
//     uiLoadingDelay[playerid] = 0;

//     stop uiLoadingTimer[playerid][0];
//     stop uiLoadingTimer[playerid][1];
// }

// TIMER__ UI_UPDATELOADINGUI[1000](playerid)
// {
//     new Float:value = GetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid]);
//     value = floatround(value);
//     if (value != 100)
//         SetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid], value + (floatround(100 / (uiLoadingDelay[playerid] / 1000))));
//     else
//         SetPlayerProgressBarValue(playerid, uiLoadingProgressBar[playerid], 0.0);
//     return 1;
// }

forward UI_InfoTimer(const playerid);
public UI_InfoTimer(const playerid)
{
    UI_DestroyInfoMessage(playerid);
    return 1;
}

stock UI_ShowLoadingTextDraw(const playerid, const string:message[], const delay, va_args<>)
{
    if (uiLoadingCreated[playerid])
        return 0;

    uiLoadingProgressBar[playerid] = CreatePlayerProgressBar(playerid,
        272.000000, 272.000000, 95.500000, 9.200000,
        MAIN_COLOR_HEX, 100.0000, BAR_DIRECTION_RIGHT
    );

    uiLoadingTextDraw[playerid] = va_CreatePlayerTextDraw(playerid, 317.100036, 262.177825, va_return(message, 2));
    PlayerTextDrawLetterSize(playerid,                  uiLoadingTextDraw[playerid], 0.196500, 0.766222);
    PlayerTextDrawTextSize(playerid,                    uiLoadingTextDraw[playerid], 0.000000, 392.000000);
    PlayerTextDrawAlignment(playerid,                   uiLoadingTextDraw[playerid], 2);
    PlayerTextDrawColor(playerid,                       uiLoadingTextDraw[playerid], -1);
    PlayerTextDrawSetShadow(playerid,                   uiLoadingTextDraw[playerid], 0);
    PlayerTextDrawSetOutline(playerid,                  uiLoadingTextDraw[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid,             uiLoadingTextDraw[playerid], 255);
    PlayerTextDrawFont(playerid,                        uiLoadingTextDraw[playerid], 1);
    PlayerTextDrawSetProportional(playerid,             uiLoadingTextDraw[playerid], 1);

    ShowPlayerProgressBar(playerid, uiLoadingProgressBar[playerid]);
    PlayerTextDrawShow(playerid, uiLoadingTextDraw[playerid]);

    uiLoadingCreated[playerid] = true;
    uiLoadingDelay[playerid] = delay;
    // uiLoadingTimer[playerid][0] = defer UI_HIDELOADINGUI(playerid);
    // uiLoadingTimer[playerid][1] = repeat UI_UPDATELOADINGUI(playerid);
    uiLoadingTimer[playerid][0] = SetTimerEx("UI_HideLoadingUI", uiLoadingDelay[playerid] + 500, false, "d", playerid);
    uiLoadingTimer[playerid][0] = SetTimerEx("UI_UpdateLoadingUI", 1000, true, "d", playerid);
    return 1;
}

stock UI_GetPlayerIGTD(const playerid) return uiTextDrawIGStatus[playerid];
stock UI_GetPlayerSpeedoTD(const playerid) return uiTextDrawSpeedo[playerid];
stock UI_SetPlayerIGTD(const playerid)
{
    new const bool: status = !UI_GetPlayerIGTD(playerid);
    if (!status)
    {
        for (new i = 0; i <= 20; i++)
        {
            PlayerTextDrawDestroy(playerid, uiTextDrawIG[playerid][i]);
            uiTextDrawIG[playerid][i] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
        }
        return 1;
    }

    uiTextDrawIG[playerid][0] = CreatePlayerTextDraw(playerid, 590.900512, 4.722169, "00:00~n~01/01/2024");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][0], 0.290499, 1.139554);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][0], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][0], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][0], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][0], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][0], 1);

    uiTextDrawIG[playerid][1] = CreatePlayerTextDraw(playerid, 494.599975, 106.877807, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][1], 117.000000, 67.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][1], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][1], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][1], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][1], 0);

    uiTextDrawIG[playerid][2] = CreatePlayerTextDraw(playerid, 494.599975, 106.877807, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][2], 117.000000, 67.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][2], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][2], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][2], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][2], 0);

    uiTextDrawIG[playerid][3] = CreatePlayerTextDraw(playerid, 496.599884, 108.955543, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][3], 113.350074, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][3], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][3], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][3], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][3], 0);

    uiTextDrawIG[playerid][4] = CreatePlayerTextDraw(playerid, 496.599884, 121.555351, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][4], 113.350074, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][4], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][4], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][4], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][4], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][4], 0);

    uiTextDrawIG[playerid][5] = CreatePlayerTextDraw(playerid, 496.599884, 134.855667, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][5], 113.350074, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][5], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][5], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][5], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][5], 0);

    uiTextDrawIG[playerid][6] = CreatePlayerTextDraw(playerid, 496.599884, 147.756454, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][6], 113.350074, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][6], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][6], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][6], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][6], 0);

    uiTextDrawIG[playerid][7] = CreatePlayerTextDraw(playerid, 496.599884, 160.557235, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][7], 113.350074, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][7], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][7], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][7], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][7], 0);

    uiTextDrawIG[playerid][8] = CreatePlayerTextDraw(playerid, 499.200042, 111.477745, "BANKA");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][8], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][8], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][8], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][8], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][8], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][8], 1);

    uiTextDrawIG[playerid][9] = CreatePlayerTextDraw(playerid, 499.200042, 124.277549, "ZLATO");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][9], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][9], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][9], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][9], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][9], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][9], 1);

    uiTextDrawIG[playerid][10] = CreatePlayerTextDraw(playerid, 499.200042, 137.378067, "LEVEL");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][10], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][10], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][10], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][10], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][10], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][10], 1);

    uiTextDrawIG[playerid][11] = CreatePlayerTextDraw(playerid, 499.200042, 150.278854, "EXP");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][11], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][11], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][11], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][11], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][11], 1);

    uiTextDrawIG[playerid][12] = CreatePlayerTextDraw(playerid, 499.200042, 163.179641, "Ime");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][12], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][12], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][12], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][12], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][12], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][12], 1);

    uiTextDrawIG[playerid][13] = va_CreatePlayerTextDraw(playerid, 607.899780, 110.935157, "~g~$~w~%d", Account_GetBankMoney(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][13], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][13], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][13], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][13], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][13], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][13], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][13], 1);

    uiTextDrawIG[playerid][14] = va_CreatePlayerTextDraw(playerid, 607.899780, 123.834960, "%d~y~G", Account_GetGold(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][14], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][14], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][14], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][14], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][14], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][14], 1);

    uiTextDrawIG[playerid][15] = va_CreatePlayerTextDraw(playerid, 607.899780, 136.935440, "%d", Account_GetScore(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][15], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][15], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][15], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][15], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][15], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][15], 1);

    uiTextDrawIG[playerid][16] = va_CreatePlayerTextDraw(playerid, 607.899780, 149.936233, "%d/~r~%d", Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][16], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][16], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][16], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][16], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][16], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][16], 1);

    uiTextDrawIG[playerid][17] = va_CreatePlayerTextDraw(playerid, 607.899780, 163.437057, "~r~%s", ReturnPlayerName(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][17], 0.184498, 0.654222);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][17], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][17], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][17], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][17], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][17], 1);

    uiTextDrawIG[playerid][18] = CreatePlayerTextDraw(playerid, 5.000000, 435.622192, "LD_CHAT:THUMBUP");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][18], 8.000000, 8.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][18], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][18], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][18], 0);

    uiTextDrawIG[playerid][19] = CreatePlayerTextDraw(playerid, 17.100002, 435.877838, "DUPLI_RESPEKTI");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][19], 0.165999, 0.778666);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][19], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][19], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][19], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][19], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][19], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][19], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][19], 1);

    // showing 11 textdraws (no speedometer)
    for (new i = 0; i <= 19; i++)
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][i]);
    return 1;
}

stock UI_GetLoginTextDrawStatus(const playerid) return uiLoginTextDrawStatus[playerid];
stock UI_CreateLoginTextDraw(const playerid)
{
    new const bool: status = !UI_GetLoginTextDrawStatus(playerid);
    if (!status)
    {
        for (new i = 0; i < 24; i++)
        {
            PlayerTextDrawDestroy(playerid, uiLoginTextDraw[playerid][i]);
            uiLoginTextDraw[playerid][i] = PlayerText:INVALID_PLAYER_TEXT_DRAW;
        }
        uiLoginTextDrawStatus[playerid] = false;
        return 1;
    }

    uiLoginTextDraw[playerid][0] = CreatePlayerTextDraw(playerid, -7.500000, -10.511126, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][0], 755.000000, 146.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][0], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][0], 128);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][0], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][0], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][0], 0);

    uiLoginTextDraw[playerid][1] = CreatePlayerTextDraw(playerid, -7.500000, -10.511126, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][1], 755.000000, 146.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][1], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][1], 128);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][1], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][1], 0);

    uiLoginTextDraw[playerid][2] = CreatePlayerTextDraw(playerid, -14.000000, 304.333343, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][2], 755.000000, 146.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][2], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][2], 128);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][2], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][2], 0);

    uiLoginTextDraw[playerid][3] = CreatePlayerTextDraw(playerid, -14.000000, 304.333343, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][3], 755.000000, 146.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][3], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][3], 128);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][3], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][3], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][3], 0);

    uiLoginTextDraw[playerid][4] = CreatePlayerTextDraw(playerid, 281.500000, 28.844436, "MYSTIQUE");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][4], 0.617500, 2.390221);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][4], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][4], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][4], 3);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][4], 1);

    uiLoginTextDraw[playerid][5] = CreatePlayerTextDraw(playerid, 340.899414, 36.400020, "]");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][5], 0.931000, 3.659554);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][5], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][5], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][5], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][5], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][5], 1);

    uiLoginTextDraw[playerid][6] = CreatePlayerTextDraw(playerid, 386.899414, 31.422237, "DOBRODOSLI");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][6], 0.184000, 0.909332);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][6], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][6], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][6], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][6], 1);

    uiLoginTextDraw[playerid][7] = CreatePlayerTextDraw(playerid, 286.000000, 390.200103, "LD_BEAT:CHIT");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][7], 61.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][7], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][7], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][7], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][7], 0);

    uiLoginTextDraw[playerid][8] = CreatePlayerTextDraw(playerid, 239.597167, 395.700439, "LD_BEAT:CHIT");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][8], 61.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][8], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][8], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][8], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][8], 0);

    uiLoginTextDraw[playerid][9] = CreatePlayerTextDraw(playerid, 332.702850, 396.000457, "LD_BEAT:CHIT");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][9], 61.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][9], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][9], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][9], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][9], 0);

    uiLoginTextDraw[playerid][10] = CreatePlayerTextDraw(playerid, 236.000000, 357.222259, "");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][10], 65.000000, 54.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][10], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][10], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][10], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][10], 0x00000000);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][10], 5);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][10], 0);
    PlayerTextDrawSetPreviewModel(playerid, uiLoginTextDraw[playerid][10], 294);
    PlayerTextDrawSetPreviewRot(playerid, uiLoginTextDraw[playerid][10], 0.000000, 0.000000, 0.000000, 1.000000);

    uiLoginTextDraw[playerid][11] = CreatePlayerTextDraw(playerid, 328.500000, 357.844482, "");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][11], 65.000000, 54.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][11], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][11], 0x00000000);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][11], 5);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][11], 0);
    PlayerTextDrawSetPreviewModel(playerid, uiLoginTextDraw[playerid][11], 294);
    PlayerTextDrawSetPreviewRot(playerid, uiLoginTextDraw[playerid][11], 0.000000, 0.000000, 0.000000, 1.000000);

    uiLoginTextDraw[playerid][12] = CreatePlayerTextDraw(playerid, 282.500000, 351.622253, "");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][12], 65.000000, 54.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][12], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][12], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][12], 0x00000000);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][12], 5);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][12], 0);
    PlayerTextDrawSetPreviewModel(playerid, uiLoginTextDraw[playerid][12], 217);
    PlayerTextDrawSetPreviewRot(playerid, uiLoginTextDraw[playerid][12], 0.000000, 0.000000, 0.000000, 1.000000);

    uiLoginTextDraw[playerid][13] = CreatePlayerTextDraw(playerid, 315.500000, 338.088897, "DEVELOPER~N~EMMETT");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][13], 0.128499, 0.604444);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][13], 0.000000, 167.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][13], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][13], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][13], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][13], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][13], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][13], 1);

    uiLoginTextDraw[playerid][14] = CreatePlayerTextDraw(playerid, 268.000000, 344.933349, "MAPPER~N~NIKO");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][14], 0.128499, 0.604444);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][14], 0.000000, 167.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][14], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][14], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][14], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][14], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][14], 1);

    uiLoginTextDraw[playerid][15] = CreatePlayerTextDraw(playerid, 361.600006, 344.588958, "VLASNIK~n~EMMETT");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][15], 0.128499, 0.604444);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][15], 0.000000, 167.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][15], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][15], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][15], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][15], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][15], 1);

    uiLoginTextDraw[playerid][16] = CreatePlayerTextDraw(playerid, 29.500000, 335.444427, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][16], 171.000000, 90.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][16], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][16], 153);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][16], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][16], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][16], 0);

    uiLoginTextDraw[playerid][17] = CreatePlayerTextDraw(playerid, 29.500000, 335.444427, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][17], 171.000000, 2.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][17], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][17], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][17], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][17], 4);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][17], 0);

    uiLoginTextDraw[playerid][18] = CreatePlayerTextDraw(playerid, 114.500000, 338.088928, "_______INFORMACIJE");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][18], 0.154999, 0.635555);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][18], 0.000000, 10.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][18], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][18], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][18], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][18], 1);

    uiLoginTextDraw[playerid][19] = CreatePlayerTextDraw(playerid, 53.599891, 357.145050, "PRE SVEGA HVALA STO IGRATE NA NASEM SERVERU. OVAJ SERVER JE OSNOVAN 2023. GODINE SA CILJEM DA IZMENIMO SA:MP SCENU");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][19], 0.154999, 0.635555);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][19], 174.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][19], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][19], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][19], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][19], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][19], 1);

    uiLoginTextDraw[playerid][20] = CreatePlayerTextDraw(playerid, 53.799903, 380.945800, "I POBOLJSAMO JE. JER, DANAS JE MALI BROJ DOBRIH I USPESNIH SERVERA, POLAKO SVE PROPADA I MI SMO TU DA POKUSAMO DA PROMENIMO TO..");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][20], 0.154999, 0.635555);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][20], 173.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][20], 1);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][20], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][20], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][20], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][20], 1);

    uiLoginTextDraw[playerid][21] = CreatePlayerTextDraw(playerid, 603.500000, 308.844451, "UZIVAJTE~N~U_IGRI");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][21], 0.351499, 1.382222);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][21], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][21], -229098497);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][21], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][21], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][21], 3);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][21], 1);

    uiLoginTextDraw[playerid][22] = CreatePlayerTextDraw(playerid, 318.500000, 131.721954, "UNESITE_TACNU_LOZINKU");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][22], 0.144499, 0.598222);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][22], 2);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][22], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][22], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][22], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][22], 1);

    uiLoginTextDraw[playerid][23] = CreatePlayerTextDraw(playerid, 636.500000, 429.555664, "Ukoliko imate nekih problema sa prijavom ili slicno~n~prijavite vlasniku na mail adresu:~n~iam.deksy]gmail.com");
    PlayerTextDrawLetterSize(playerid, uiLoginTextDraw[playerid][23], 0.130499, 0.598222);
    PlayerTextDrawTextSize(playerid, uiLoginTextDraw[playerid][23], 679.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiLoginTextDraw[playerid][23], 3);
    PlayerTextDrawColor(playerid, uiLoginTextDraw[playerid][23], -1);
    PlayerTextDrawSetShadow(playerid, uiLoginTextDraw[playerid][23], 0);
    PlayerTextDrawBackgroundColor(playerid, uiLoginTextDraw[playerid][23], 255);
    PlayerTextDrawFont(playerid, uiLoginTextDraw[playerid][23], 2);
    PlayerTextDrawSetProportional(playerid, uiLoginTextDraw[playerid][23], 1);

    for (new i = 0; i < 24; i++)
        PlayerTextDrawShow(playerid, uiLoginTextDraw[playerid][i]);

    uiLoginTextDrawStatus[playerid] = true;
    return 1;
}

stock UI_UpdateInfoTD(const playerid)
{
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][17], "~r~%s", ReturnPlayerName(playerid));
    
    if (!Account_GetBankCard(playerid))
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][13], "~r~Nemate racun"); 
    else va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][13], "~g~$~w~%d", Account_GetBankMoney(playerid));
    
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][14], "%d~y~G", Account_GetGold(playerid));
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][15], "%d", GetPlayerScore(playerid));
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][16], "%d/~r~%d", Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
    return 1;
}

stock UI_SetSpeedometer(const playerid, bool:status)
{
    if (!status)
    {
        for (new i = 20; i <= 37; i++)
        {
            PlayerTextDrawDestroy(playerid, uiTextDrawIG[playerid][i]);
            uiTextDrawIG[playerid][i] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
        }
        return 1;
    }

    // speedometer
    uiTextDrawIG[playerid][20] = CreatePlayerTextDraw(playerid, 493.799987, 350.377868, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][20], 139.000000, 89.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][20], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][20], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][20], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][20], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][20], 0);

    uiTextDrawIG[playerid][21] = CreatePlayerTextDraw(playerid, 493.799987, 350.377868, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][21], 139.000000, 89.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][21], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][21], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][21], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][21], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][21], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][21], 0);

    uiTextDrawIG[playerid][22] = CreatePlayerTextDraw(playerid, 495.400085, 352.778015, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][22], 135.740142, 11.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][22], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][22], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][22], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][22], 0);

    uiTextDrawIG[playerid][23] = va_CreatePlayerTextDraw(playerid, 562.499511, 354.144470, "~b~%s", GetVehicleName(GetPlayerVehicleID(playerid)));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][23], 0.153500, 0.784888);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][23], 0.000000, 136.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][23], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][23], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][23], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][23], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][23], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][23], 1);

    uiTextDrawIG[playerid][24] = CreatePlayerTextDraw(playerid, 498.400115, 424.778045, "299KM/H");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][24], 0.165000, 0.915555);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][24], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][24], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][24], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][24], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][24], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][24], 1);

    uiTextDrawIG[playerid][25] = CreatePlayerTextDraw(playerid, 609.194641, 423.288879, "___"); // handbrake
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][25], 0.222999, 1.108443);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][25], 660.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][25], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][25], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][25], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][25], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][25], 1);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][25], 1);

    uiTextDrawIG[playerid][26] = CreatePlayerTextDraw(playerid, 495.500000, 365.466766, "LD_SPAC:WHITE");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][26], 136.000000, 12.140026);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][26], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][26], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][26], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][26], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][26], 0);

    uiTextDrawIG[playerid][27] = CreatePlayerTextDraw(playerid, 495.500000, 379.167602, "LD_SPAC:WHITE");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][27], 136.000000, 12.140026);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][27], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][27], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][27], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][27], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][27], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][27], 0);

    uiTextDrawIG[playerid][28] = CreatePlayerTextDraw(playerid, 495.500000, 392.868438, "LD_SPAC:WHITE");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][28], 136.000000, 12.140026);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][28], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][28], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][28], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][28], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][28], 0);

    uiTextDrawIG[playerid][29] = CreatePlayerTextDraw(playerid, 495.500000, 406.469268, "LD_SPAC:WHITE");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][29], 136.000000, 12.140026);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][29], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][29], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][29], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][29], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][29], 0);

    uiTextDrawIG[playerid][30] = CreatePlayerTextDraw(playerid, 498.000000, 367.855590, "MOTOR");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][30], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][30], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][30], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][30], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][30], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][30], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][30], 1);

    uiTextDrawIG[playerid][31] = CreatePlayerTextDraw(playerid, 498.000000, 381.456420, "GORIVO");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][31], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][31], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][31], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][31], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][31], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][31], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][31], 1);

    uiTextDrawIG[playerid][32] = CreatePlayerTextDraw(playerid, 498.000000, 394.957244, "SVETLA");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][32], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][32], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][32], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][32], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][32], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][32], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][32], 1);

    uiTextDrawIG[playerid][33] = CreatePlayerTextDraw(playerid, 498.000000, 408.958099, "POJAS");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][33], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][33], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][33], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][33], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][33], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][33], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][33], 1);

    uiTextDrawIG[playerid][34] = va_CreatePlayerTextDraw(playerid, 628.000000, 367.269165, "%s", (Vehicle_GetEngine(playerid) == 1 ? "~g~UPALJEN" : "~r~UGASEN"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][34], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][34], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][34], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][34], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][34], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][34], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][34], 1);

    uiTextDrawIG[playerid][35] = va_CreatePlayerTextDraw(playerid, 628.699829, 381.170013, "~y~%dL", Vehicle_GetFuel(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][35], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][35], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][35], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][35], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][35], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][35], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][35], 1);

    uiTextDrawIG[playerid][36] = va_CreatePlayerTextDraw(playerid, 628.699829, 394.670837, "%s", (Vehicle_GetLights(playerid) == 1 ? "~g~UPALJENA" : "~r~UGASENA"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][36], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][36], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][36], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][36], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][36], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][36], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][36], 1);

    uiTextDrawIG[playerid][37] = va_CreatePlayerTextDraw(playerid, 628.699829, 408.671691, "%s", (Player_GetSeatbelt(playerid) == 1 ? "~g~VEZAN" : "~r~ODVEZAN"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][37], 0.160999, 0.728887);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][37], 3);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][37], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][37], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][37], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][37], 2);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][37], 1);

    for (new i = 20; i <= 37; i++)
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][i]);
    return 1;
}

stock UI_DestroyInfoMessage(const playerid)
{
    if (!uiInfoTextDrawCreated[playerid])
        return 0;

    PlayerTextDrawDestroy(playerid, uiInfoTextDraw[playerid]);
    uiInfoTextDraw[playerid] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
    uiInfoDelay[playerid] = 0;
    uiInfoTextDrawCreated[playerid] = false;
    KillTimer(uiInfoTimer[playerid]);
    return 1;
}

stock UI_ShowInfoMessage(const playerid, const delay, const string: message[], va_args<>)
{
    if (uiInfoTextDrawCreated[playerid])
        return 0;

    uiInfoTextDraw[playerid] = CreatePlayerTextDraw(playerid, 316.600067, 302.390167, va_return(message, va_start<3>));
    PlayerTextDrawLetterSize(playerid, uiInfoTextDraw[playerid], 0.252499, 1.164443);
    PlayerTextDrawTextSize(playerid, uiInfoTextDraw[playerid], 0.000000, 972.000000);
    PlayerTextDrawAlignment(playerid, uiInfoTextDraw[playerid], 2);
    PlayerTextDrawColor(playerid, uiInfoTextDraw[playerid], -1);
    PlayerTextDrawSetShadow(playerid, uiInfoTextDraw[playerid], 0);
    PlayerTextDrawSetOutline(playerid, uiInfoTextDraw[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, uiInfoTextDraw[playerid], 255);
    PlayerTextDrawFont(playerid, uiInfoTextDraw[playerid], 1);
    PlayerTextDrawSetProportional(playerid, uiInfoTextDraw[playerid], 1);

    uiInfoTextDrawCreated[playerid] = true;
    uiInfoDelay[playerid] = delay;
    uiInfoTimer[playerid] = SetTimerEx("UI_InfoTimer", uiInfoDelay[playerid], false, "d", playerid);
    return PlayerTextDrawShow(playerid, uiInfoTextDraw[playerid]);
}

stock Vehicle_GetColor(const vehicleid, const color/* 0/1 */) return vehicleColor[vehicleid][color];
stock Vehicle_SetColor(const vehicleid, const color1, const color2)
{
    vehicleColor[vehicleid][0] = color1;
    vehicleColor[vehicleid][1] = color2;
    ChangeVehicleColor(vehicleid, Vehicle_GetColor(vehicleid, 0), Vehicle_GetColor(vehicleid, 1));
    return 1;
}

stock GetVehicleSpeed(const vehicleid)
{
    static Float: pos_y,
        Float: pos_x,
        Float: pos_z,

        Float: veh_speed;

    GetVehicleVelocity(vehicleid, pos_x, pos_y, pos_z);
    // veh_speed = (floatsqroot((pos_x * pos_x) + (pos_y * pos_y) + (pos_z * pos_z)) * 180);
    veh_speed = VectorSize(pos_x, pos_y, pos_z) * 180;
    
    return floatround(veh_speed, floatround_round);
}

stock GetVehicleName(const vehicleid)
{
    new modelid = GetVehicleModel(vehicleid),
        name[32];
 
    if(400 <= modelid <= 611)
        strcat(name, modelNames[modelid - 400]);
    else
        name = "Unknown";
    return name;
}

stock Vehicle_GetEngine(const playerid) return vehicleEngine[playerid];
stock Vehicle_GetLights(const playerid) return vehicleLights[playerid];
stock Vehicle_GetFuel(const playerid) return vehicleFuel[GetPlayerVehicleID(playerid)];

stock Vehicle_SetEngine(const playerid)
{
    new const status = !Vehicle_GetEngine(playerid);
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);

    if (!status)
    {
        SetVehicleParamsEx(GetPlayerVehicleID(playerid), 0, lights, alarm, doors, bonnet, boot, objective);
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][34], "~r~UGASEN");
        vehicleEngine[playerid] = 0;
        return 1;
    }

    SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][34], "~g~UPALJEN");
    vehicleEngine[playerid] = 1;
    return 1;
}

stock Vehicle_SetLights(const playerid)
{
    new const status = !Vehicle_GetLights(playerid);
    static engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);

    if (!status)
    {
        SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 0, alarm, doors, bonnet, boot, objective);
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][36], "~r~UGASENA");
        vehicleLights[playerid] = 0;
        return 1;
    }

    SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 1, alarm, doors, bonnet, boot, objective);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][36], "~g~UPALJENA");
    vehicleLights[playerid] = 1;
    return 1;
}

stock Vehicle_SetSeatbelt(const playerid)
{
    new const status = !Player_GetSeatbelt(playerid);
    if (!status)
    {
        Player_SetSeatbelt(playerid, false);
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][37], "~r~ODVEZAN");
        SendServerMsg(playerid, "Odvezali ste pojas.");
        return 1;
    }

    Player_SetSeatbelt(playerid, true);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][37], "~g~VEZAN");
    SendServerMsg(playerid, "Zavezali ste pojas.");
    return 1;
}

stock Vehicle_SetFuel(const vehicleid, const value)
{
    vehicleFuel[vehicleid] = value;
    return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    vehicleEngine[playerid] = 0;
    vehicleLights[playerid] = 0;

    if (Player_GetSeatbelt(playerid))
        Vehicle_SetSeatbelt(playerid);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    UI_SetSpeedometer(playerid, (newstate == PLAYER_STATE_DRIVER ? (true) : (false)));

    if (newstate == PLAYER_STATE_ONFOOT && oldstate != PLAYER_STATE_PASSENGER)
    {
        if (Player_GetSeatbelt(playerid))
            Vehicle_SetSeatbelt(playerid);

        if (Vehicle_GetEngine(playerid))
            Vehicle_SetEngine(playerid);

        if (Vehicle_GetLights(playerid))
            Vehicle_SetLights(playerid);
    }

    if (GetPlayerState(playerid) != PLAYER_STATE_PASSENGER)
    {
        Vehicle_SetEngine(playerid);
        Vehicle_SetLights(playerid);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
    if (GetPlayerState(playerid) != PLAYER_STATE_PASSENGER)
    {
        if (Player_GetSeatbelt(playerid))
            Vehicle_SetSeatbelt(playerid);

        if (Vehicle_GetEngine(playerid))
            Vehicle_SetEngine(playerid);

        if (Vehicle_GetLights(playerid))
            Vehicle_SetLights(playerid);
    }
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (IsPlayerInAnyVehicle(playerid) && PRESSED(KEY_AIM))
    {
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][25], "~r~( P )");
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][25]);
    }

    else if (IsPlayerInAnyVehicle(playerid) && RELEASED(KEY_AIM))
    {
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][25], "___");
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][25]);
    }

    else if (IsPlayerInAnyVehicle(playerid) && PRESSED(KEY_SUBMISSION) && Vehicle_GetFuel(playerid))
        Vehicle_SetEngine(playerid);
    else if (IsPlayerInAnyVehicle(playerid) && PRESSED(KEY_NO))
        Vehicle_SetLights(playerid);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

PTASK__ Speedo_UpdateVehStatus[400](playerid)
{
    if (IsPlayerInAnyVehicle(playerid))
        va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][24], "%dkm/h", GetVehicleSpeed(GetPlayerVehicleID(playerid)));
}

PTASK__ Speedo_UpdateFuel[120000](playerid)
{
    if (IsPlayerInAnyVehicle(playerid))
    {
        if (!Vehicle_GetFuel(playerid))
            return 0;

        Vehicle_SetFuel(playerid, Vehicle_GetFuel(playerid) - 1);
        if (!Vehicle_GetFuel(playerid) && Vehicle_GetEngine(playerid))
            Vehicle_SetEngine(playerid);

        va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][35], "~y~%dL", Vehicle_GetFuel(playerid));
    }
    return 1;
}

// PTASK__ UI_UpdateRandomMsg[5000](playerid)
// {
//     PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][10], randomMessages[random(sizeof(randomMessages))]);
// }

static __hour, __min, __sec, __day, __month, __year;
PTASK__ UI_UpdateTimeDate[1000](playerid)
{
    gettime(__hour, __min, __sec);
    getdate(__year, __month, __day);
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][0], "%02d:%02d:%02d~n~%02d/%02d/%d", __hour, __min, __sec, __day, __month, __year);
}

PTASK__ UI_SendRandomMsg[60000](playerid)
{
    SendCustomMsgF(playerid, MAIN_COLOR_HEX, "[HELP]: "GRAY"%s", randomMessages[random(sizeof(randomMessages))]);
}