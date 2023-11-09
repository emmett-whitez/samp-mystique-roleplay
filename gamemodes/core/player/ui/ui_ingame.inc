#if defined _INC_ui_ingame_inc
    #endinput
#endif
#define _INC_ui_ingame_inc

#include <YSI_Coding\y_hooks>

static
    PlayerText:uiTextDrawIG[MAX_PLAYERS][25] = {PlayerText: INVALID_PLAYER_TEXT_DRAW,...},
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
    "Srecne praznike zeli vam gta-world staff team!",
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
        for (new i = 0; i <= 11; i++)
        {
            PlayerTextDrawDestroy(playerid, uiTextDrawIG[playerid][24]);
            PlayerTextDrawDestroy(playerid, uiTextDrawIG[playerid][i]);
            uiTextDrawIG[playerid][24] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
            uiTextDrawIG[playerid][i] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
        }
        return 1;
    }

    uiTextDrawIG[playerid][0] = CreatePlayerTextDraw(playerid, 589.501953, 5.750017, "gta~w~world");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][0], 0.348000, 1.413333);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][0], 0.000000, 190.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][0], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][0], -229098497);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][0], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][0], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][0], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][0], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][0], 1);

    uiTextDrawIG[playerid][1] = CreatePlayerTextDraw(playerid, 133.399230, 349.115936, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][1], 103.000000, 72.979995);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][1], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][1], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][1], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][1], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][1], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][1], 0);

    uiTextDrawIG[playerid][2] = CreatePlayerTextDraw(playerid, 133.399230, 349.115936, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][2], 103.000000, 72.979995);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][2], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][2], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][2], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][2], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][2], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][2], 0);

    uiTextDrawIG[playerid][3] = CreatePlayerTextDraw(playerid, 183.899932, 350.349853, "stats");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][3], 0.252999, 0.800833);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][3], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][3], -229098497);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][3], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][3], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][3], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][3], 1);

    uiTextDrawIG[playerid][4] = CreatePlayerTextDraw(playerid, 124.500000, 360.333343, "");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][4], 61.000000, 47.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][4], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][4], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][4], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][4], 0x00000000);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][4], 5);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][4], 0);
    PlayerTextDrawSetPreviewModel(playerid, uiTextDrawIG[playerid][4], GetPlayerSkin(playerid));
    PlayerTextDrawSetPreviewRot(playerid, uiTextDrawIG[playerid][4], 0.000000, 0.000000, 0.000000, 1.000000);

    uiTextDrawIG[playerid][5] = va_CreatePlayerTextDraw(playerid, 208.000000, 362.083251, "%d_LEVEL", Account_GetScore(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][5], 0.245000, 0.876666);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][5], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][5], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][5], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][5], 1);

    uiTextDrawIG[playerid][6] = va_CreatePlayerTextDraw(playerid, 208.000000, 371.383819, "~g~$~w~%d", Account_GetBankMoney(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][6], 0.245000, 0.876666);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][6], 0.000000, 144.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][6], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][6], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][6], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][6], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][6], 1);

    uiTextDrawIG[playerid][7] = va_CreatePlayerTextDraw(playerid, 208.000000, 380.584381, "%d~y~g", Account_GetGold(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][7], 0.245000, 0.876666);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][7], 0.000000, 144.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][7], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][7], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][7], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][7], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][7], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][7], 1);

    uiTextDrawIG[playerid][8] = CreatePlayerTextDraw(playerid, 136.299621, 411.984375, ReturnPlayerName(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][8], 0.245000, 0.876666);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][8], 144.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][8], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][8], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][8], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][8], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][8], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][8], 1);

    uiTextDrawIG[playerid][9] = va_CreatePlayerTextDraw(playerid, 207.899719, 390.501007, "0/~r~%d~w~exp", Account_GetExp(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][9], 0.245000, 0.876666);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][9], 0.000000, 103.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][9], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][9], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][9], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][9], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][9], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][9], 1);

    uiTextDrawIG[playerid][10] = CreatePlayerTextDraw(playerid, 23.000000, 435.266540, "Trenutno igrate na gta-world samp serveru, verzija moda: 1.0");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][10], 0.256000, 1.005000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][10], 476.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][10], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][10], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][10], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][10], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][10], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][10], 1);

    uiTextDrawIG[playerid][11] = CreatePlayerTextDraw(playerid, 7.900000, 435.566680, "LD_CHAT:BADCHAT");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][11], 9.400009, 9.490011);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][11], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][11], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][11], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][11], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][11], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][11], 0);

    uiTextDrawIG[playerid][24] = CreatePlayerTextDraw(playerid, 604.100341, 434.716674, "dupli_respekti");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][24], 0.244000, 1.022500);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][24], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][24], -229098497);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][24], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][24], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][24], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][24], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][24], 1);

    // showing 11 textdraws (no speedometer)
    for (new i = 0; i <= 11; i++)
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][i]);
    PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][24]);
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

    uiLoginTextDraw[playerid][4] = CreatePlayerTextDraw(playerid, 281.500000, 28.844436, "GTA-WORLD");
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
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][8], ReturnPlayerName(playerid));
    
    if (!Account_GetBankCard(playerid))
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][6], "~r~Nemate racun"); 
    else va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][6], "~g~$~w~%d", Account_GetBankMoney(playerid));
    
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][7], "~w~%d~y~G", Account_GetGold(playerid));
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][5], "%d_level", GetPlayerScore(playerid));
    va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][9], "%d/~r~%d~w~exp", Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
    PlayerTextDrawSetPreviewModel(playerid, uiTextDrawIG[playerid][4], GetPlayerSkin(playerid));
    PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][4]);
    return 1;
}

stock UI_SetSpeedometer(const playerid, bool:status)
{
    if (!status)
    {
        for (new i = 12; i <= 23; i++)
        {
            PlayerTextDrawDestroy(playerid, uiTextDrawIG[playerid][i]);
            uiTextDrawIG[playerid][i] = PlayerText: INVALID_PLAYER_TEXT_DRAW;
        }
        return 1;
    }

    // speedometer
    uiTextDrawIG[playerid][12] = CreatePlayerTextDraw(playerid, 521.797973, 349.349121, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][12], 103.000000, 72.979995);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][12], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][12], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][12], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][12], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][12], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][12], 0);

    uiTextDrawIG[playerid][13] = CreatePlayerTextDraw(playerid, 521.797973, 349.349121, "LD_SPAC:white");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][13], 103.000000, 72.979995);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][13], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][13], 153);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][13], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][13], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][13], 0);

    uiTextDrawIG[playerid][14] = CreatePlayerTextDraw(playerid, 572.799804, 351.216491, "speedometer");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][14], 0.252999, 0.800833);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][14], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][14], -229098497);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][14], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][14], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][14], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][14], 1);

    uiTextDrawIG[playerid][15] = CreatePlayerTextDraw(playerid, 514.300537, 353.966796, "");
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][15], 59.000000, 57.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][15], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][15], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][15], 0x00000000);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][15], 5);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][15], 0);
    PlayerTextDrawSetPreviewModel(playerid, uiTextDrawIG[playerid][15], GetVehicleModel(GetPlayerVehicleID(playerid)));
    PlayerTextDrawSetPreviewRot(playerid, uiTextDrawIG[playerid][15], -20.000000, 0.000000, 25.000000, 1.000000);
    PlayerTextDrawSetPreviewVehCol(playerid, uiTextDrawIG[playerid][15], 1, 1);

    uiTextDrawIG[playerid][16] = CreatePlayerTextDraw(playerid, 524.500000, 411.866668, GetVehicleName(GetPlayerVehicleID(playerid)));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][16], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][16], 632.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][16], 1);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][16], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][16], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][16], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][16], 1);

    uiTextDrawIG[playerid][17] = va_CreatePlayerTextDraw(playerid, 595.199707, 364.799957, "%s", (Vehicle_GetLights(playerid) == 1 ? "~g~svetla" : "~r~svetla"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][17], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][17], 0.000000, 632.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][17], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][17], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][17], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][17], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][17], 1);

    uiTextDrawIG[playerid][18] = va_CreatePlayerTextDraw(playerid, 595.199707, 373.900512, "%s", (Vehicle_GetEngine(playerid) == 1 ? "~g~motor" : "~r~motor"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][18], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][18], 0.000000, 632.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][18], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][18], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][18], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][18], 1);

    uiTextDrawIG[playerid][19] = va_CreatePlayerTextDraw(playerid, 595.199707, 383.201080, "%s", (Player_GetSeatbelt(playerid) == 1 ? "~g~pojas" : "~r~pojas"));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][19], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][19], 0.000000, 632.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][19], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][19], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][19], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][19], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][19], 1);

    uiTextDrawIG[playerid][20] = va_CreatePlayerTextDraw(playerid, 595.199707, 392.201629, "%dL", Vehicle_GetFuel(playerid));
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][20], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][20], 0.000000, 632.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][20], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][20], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][20], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][20], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][20], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][20], 1);

    uiTextDrawIG[playerid][21] = CreatePlayerTextDraw(playerid, 595.199707, 401.802215, "---");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][21], 0.214999, 0.865000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][21], 0.000000, 632.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][21], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][21], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][21], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][21], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][21], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][21], 1);

    uiTextDrawIG[playerid][22] = CreatePlayerTextDraw(playerid, 618.299804, 412.533416, "___");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][22], 0.167999, 0.713333);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][22], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][22], -16776961);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][22], 0);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][22], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][22], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][22], 1);

    uiTextDrawIG[playerid][23] = CreatePlayerTextDraw(playerid, 572.899291, 340.516723, "svelta-~y~n__~w~motor-~y~2__~w~/pojas");
    PlayerTextDrawLetterSize(playerid, uiTextDrawIG[playerid][23], 0.173999, 0.795000);
    PlayerTextDrawTextSize(playerid, uiTextDrawIG[playerid][23], 0.000000, 117.000000);
    PlayerTextDrawAlignment(playerid, uiTextDrawIG[playerid][23], 2);
    PlayerTextDrawColor(playerid, uiTextDrawIG[playerid][23], -1);
    PlayerTextDrawSetShadow(playerid, uiTextDrawIG[playerid][23], 0);
    PlayerTextDrawSetOutline(playerid, uiTextDrawIG[playerid][23], 1);
    PlayerTextDrawBackgroundColor(playerid, uiTextDrawIG[playerid][23], 255);
    PlayerTextDrawFont(playerid, uiTextDrawIG[playerid][23], 3);
    PlayerTextDrawSetProportional(playerid, uiTextDrawIG[playerid][23], 1);

    for (new i = 12; i <= 23; i++)
    {
        PlayerTextDrawSetPreviewModel(playerid, uiTextDrawIG[playerid][15], GetVehicleModel(GetPlayerVehicleID(playerid)));
        PlayerTextDrawSetPreviewVehCol(playerid, uiTextDrawIG[playerid][15], Vehicle_GetColor(GetPlayerVehicleID(playerid), 0), Vehicle_GetColor(GetPlayerVehicleID(playerid), 1));
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][i]);
    }
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
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][18], "~r~motor");
        vehicleEngine[playerid] = 0;
        return 1;
    }

    SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][18], "~g~motor");
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
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][17], "~r~svetla");
        vehicleLights[playerid] = 0;
        return 1;
    }

    SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 1, alarm, doors, bonnet, boot, objective);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][17], "~g~svetla");
    vehicleLights[playerid] = 1;
    return 1;
}

stock Vehicle_SetSeatbelt(const playerid)
{
    new const status = !Player_GetSeatbelt(playerid);
    if (!status)
    {
        Player_SetSeatbelt(playerid, false);
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][19], "~r~pojas");
        SendServerMsg(playerid, "Odvezali ste pojas.");
        return 1;
    }

    Player_SetSeatbelt(playerid, true);
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][19], "~g~pojas");
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
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][22], "~r~(P)");
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][22]);
    }

    else if (IsPlayerInAnyVehicle(playerid) && RELEASED(KEY_AIM))
    {
        PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][22], "___");
        PlayerTextDrawShow(playerid, uiTextDrawIG[playerid][22]);
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
        va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][21], "%dkm/h", GetVehicleSpeed(GetPlayerVehicleID(playerid)));
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

        va_PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][20], "%dL", Vehicle_GetFuel(playerid));
    }
    return 1;
}

PTASK__ UI_UpdateRandomMsg[5000](playerid)
{
    PlayerTextDrawSetString(playerid, uiTextDrawIG[playerid][10], randomMessages[random(sizeof(randomMessages))]);
}