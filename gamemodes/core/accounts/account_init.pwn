#if defined _INC_account_init_inc
    #endinput
#endif
#define _INC_account_init_inc

#include <YSI_Coding\y_hooks>

enum e_PLAYER_DATA
{
    pPassword[MAX_PASSWORD_LENGTH],
    pSkin,
    pMoney,
    pScore,
    pGender,
    pCountry,
    pDOB[24],
    pSpawn,
    pBankCard,
    pBankMoney,
    pAtmPinCode,
    pGold,
    pHours,
    pImovina1,
    pImovina2,
    pImovina3,
    pExp,
    pWeed,
    pJob,
    pWanted,
    pAdmin,
    pVIP,
    pCar1,
    pCar2
};

new
    PlayerData[MAX_PLAYERS][e_PLAYER_DATA],
    bool:playerSpawned[MAX_PLAYERS],

    // Timers
    spawnTimer[MAX_PLAYERS],
    playerSKTimer[MAX_PLAYERS],
    accountLoadingTimer[MAX_PLAYERS],
    BitArray: Bit_JobUniform<MAX_PLAYERS>,
    BitArray: Bit_JobStarted<MAX_PLAYERS>;

#define Account_GetPassword(%0) PlayerData[%0][pPassword]
#define USER_PATH "/Users/%s.ini"

// function with tag result used before definition, forcing reparse
forward bool:Selection_GetUI(const playerid);

forward LoadUser_data(playerid,name[],value[]);
public LoadUser_data(playerid,name[],value[])
{
    INI_String("Password", PlayerData[playerid][pPassword]);
    INI_Int("Skin", PlayerData[playerid][pSkin]);
    INI_Int("Money", PlayerData[playerid][pMoney]);
    INI_Int("Admin", PlayerData[playerid][pAdmin]);
    INI_Int("VIP", PlayerData[playerid][pVIP]);
    INI_Int("Score", PlayerData[playerid][pScore]);
    INI_Int("Gender", PlayerData[playerid][pGender]);
    INI_Int("Country", PlayerData[playerid][pCountry]);
    INI_String("DOB", PlayerData[playerid][pDOB]);
    INI_Int("Spawn", PlayerData[playerid][pSpawn]);
    INI_Int("BankCard", PlayerData[playerid][pBankCard]);
    INI_Int("BankMoney", PlayerData[playerid][pBankMoney]);
    INI_Int("AtmPin", PlayerData[playerid][pAtmPinCode]);
    INI_Int("Weed", PlayerData[playerid][pWeed]);
    INI_Int("Gold", PlayerData[playerid][pGold]);
    INI_Int("Hours", PlayerData[playerid][pHours]);
    INI_Int("Imovina1", PlayerData[playerid][pImovina1]);
    INI_Int("Imovina2", PlayerData[playerid][pImovina2]);
    INI_Int("Imovina3", PlayerData[playerid][pImovina3]);
    INI_Int("Exp", PlayerData[playerid][pExp]);
    INI_Int("Job", PlayerData[playerid][pJob]);
    INI_Int("Wanted", PlayerData[playerid][pWanted]);
    INI_Int("Car1", PlayerData[playerid][pCar1]);
    INI_Int("Car2", PlayerData[playerid][pCar2]);
    return 1;
}

stock UserPath(playerid)
{
    new string[128],playername[MAX_PLAYER_NAME];
    GetPlayerName(playerid,playername,sizeof(playername));
    format(string,sizeof(string),USER_PATH,playername);
    return string;
}

stock Account_GetDOB(const playerid)
{
    new tmpString[32];
    format(tmpString, sizeof(tmpString), "%s", PlayerData[playerid][pDOB]);
    return tmpString;
}

stock Account_GetProperty(const playerid, const index)
{
    if (index == 1)
        return PlayerData[playerid][pImovina1];
    
    else if (index == 2)
        return PlayerData[playerid][pImovina2];
    
    else if (index == 3)
        return PlayerData[playerid][pImovina3];
    return 0;
}

stock Account_SetProperty(const playerid, const index, const value)
{
    if (!(1 <= index <= 3))
        return 0;

    if (index == 1)
        return PlayerData[playerid][pImovina1] = value;
    
    else if (index == 2)
        return PlayerData[playerid][pImovina2] = value;
    
    else if (index == 3)
        return PlayerData[playerid][pImovina3] = value;
    return 1;
}
stock Account_SetWanted(const playerid, const wanted) return PlayerData[playerid][pWanted] = wanted;
stock Account_GetSkin(const playerid) return PlayerData[playerid][pSkin];
stock Account_GetMoney(const playerid) return PlayerData[playerid][pMoney];
stock Account_GetScore(const playerid) return PlayerData[playerid][pScore];
stock Account_GetGender(const playerid) return PlayerData[playerid][pGender];
stock Account_GetCountry(const playerid) return PlayerData[playerid][pCountry];
stock Account_GetSpawn(const playerid) return PlayerData[playerid][pSpawn];
stock Account_GetBankCard(const playerid) return PlayerData[playerid][pBankCard];
stock Account_GetBankMoney(const playerid) return PlayerData[playerid][pBankMoney];
stock Account_GetGold(const playerid) return PlayerData[playerid][pGold];
stock Account_GetHours(const playerid) return PlayerData[playerid][pHours];
// stock Account_GetHouse(const playerid) return PlayerData[playerid][pHouse];
stock Player_Spawned(const playerid) return PlayerData[playerid][playerSpawned];
stock Account_GetExp(const playerid) return PlayerData[playerid][pExp];

stock Account_SavePlayer(const playerid)
{
    new INI:File = INI_Open(UserPath(playerid));
    INI_SetTag(File,"data");
    INI_WriteString(File, "Password", PlayerData[playerid][pPassword]);
    INI_WriteInt(File, "Skin", PlayerData[playerid][pSkin]);
    INI_WriteInt(File, "Money", PlayerData[playerid][pMoney]);
    INI_WriteInt(File, "Admin", PlayerData[playerid][pAdmin]);
    INI_WriteInt(File, "VIP", PlayerData[playerid][pVIP]);
    INI_WriteInt(File, "Score", PlayerData[playerid][pScore]);
    INI_WriteInt(File, "Gender", PlayerData[playerid][pGender]);
    INI_WriteInt(File, "Country", PlayerData[playerid][pCountry]);
    INI_WriteString(File, "DOB", PlayerData[playerid][pDOB]);
    INI_WriteInt(File, "Spawn", PlayerData[playerid][pSpawn]);
    INI_WriteInt(File, "BankCard", PlayerData[playerid][pBankCard]);
    INI_WriteInt(File, "BankMoney", PlayerData[playerid][pBankMoney]);
    INI_WriteInt(File, "AtmPin", PlayerData[playerid][pAtmPinCode]);
    INI_WriteInt(File, "Weed", PlayerData[playerid][pWeed]);
    INI_WriteInt(File, "Gold", PlayerData[playerid][pGold]);
    INI_WriteInt(File, "Hours", PlayerData[playerid][pHours]);
    INI_WriteInt(File, "Imovina1", PlayerData[playerid][pImovina1]);
    INI_WriteInt(File, "Imovina2", PlayerData[playerid][pImovina2]);
    INI_WriteInt(File, "Imovina3", PlayerData[playerid][pImovina3]);
    INI_WriteInt(File, "Exp", PlayerData[playerid][pExp]);
    INI_WriteInt(File, "Job", PlayerData[playerid][pJob]);
    INI_WriteInt(File, "Wanted", PlayerData[playerid][pWanted]);
    INI_WriteInt(File, "Car1", PlayerData[playerid][pCar1]);
    INI_WriteInt(File, "Car2", PlayerData[playerid][pCar2]);
    INI_Close(File);
    return 1;
}

stock Account_SetPassword(const playerid, const password[])
{
    new Alloc:str_alloc = malloc(16);
    msets(str_alloc, 0, password);
    strcpy(PlayerData[playerid][pPassword], mget(str_alloc, 0));
    free(str_alloc);
    return 1;
}

stock Account_SetSkin(const playerid, const skin)
{
    PlayerData[playerid][pSkin] = skin;
    SetPlayerSkin(playerid, skin);
    return 1;
}

stock Account_SetDOB(const playerid, const date[])
{
    strcopy(PlayerData[playerid][pDOB], date);
    return 1;
}

stock Account_SetExp(const playerid, const value) return PlayerData[playerid][pExp] = value;
stock Account_SetMoney(const playerid, const value) return PlayerData[playerid][pMoney] = value;
stock Account_SetScore(const playerid, const score) return PlayerData[playerid][pScore] = score;
stock Account_SetGender(const playerid, const gender) return PlayerData[playerid][pGender] = gender;
stock Account_SetSpawnID(const playerid, const spawnid) return PlayerData[playerid][pSpawn] = spawnid;
stock Account_SetBankCard(const playerid, const value) return PlayerData[playerid][pBankCard] = value;
stock Account_SetBankMoney(const playerid, const value) return PlayerData[playerid][pBankMoney] = value;
stock Account_SetGold(const playerid, const value) return PlayerData[playerid][pGold] = value;
stock Account_SetHours(const playerid, const value) return PlayerData[playerid][pHours] = value;
// stock Account_SetHouse(const playerid, const value) return PlayerData[playerid][pHouse] = value;
stock Account_PlayerSpawned(const playerid, bool:status) return playerSpawned[playerid] = status;

hook OnPlayerConnect(playerid)
{
    TogglePlayerSpectating(playerid, 1);
    SendClientMessage(playerid, MAIN_COLOR_HEX, "[SERVER]: Ocitavanje servera, sacekajte malo!");

    // Player_ClearChat(playerid, .lines = 60);
    SetPlayerColor(playerid, 0xFFFFFFAA);

    // We need to call it twice because objects are already created in OnGameModeInit
    // so we need to "recall" the function to set object status first to true then to false
    // Winter_ShowSnowObjects(playerid);
    // Winter_ShowSnowObjects(playerid);

    static const empty_player[e_PLAYER_DATA];
    PlayerData[playerid] = empty_player;

    GameTextForPlayer(playerid, "~y~UCITAVANJE...", 4000, 3);
    accountLoadingTimer[playerid] = SetTimerEx("Account_OnLoad", 5000, false, "d", playerid);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid, reason)
{
    Account_SavePlayer(playerid);
    UI_SetPlayerIGTD(playerid);
    Bit_Set(Bit_JobUniform, playerid, false);
    Bit_Set(Bit_JobStarted, playerid, false);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerRequestClass(playerid, classic)
{
    if (Account_GetSpawn(playerid) == 1)
        SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
    else if (Account_GetSpawn(playerid) == 2)
    {
        SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
        // new houseid = Account_GetHouse(playerid);
        // SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), House_GetIntPos(houseid, 0), House_GetIntPos(houseid, 1), House_GetIntPos(houseid, 2), 0.0, 0, 0, 0, 0, 0, 0);
    }

    SpawnPlayer(playerid);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerSpawn(playerid)
{
    Account_PlayerSpawned(playerid, true);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
    Account_PlayerSpawned(playerid, false);
    GivePlayerMoney(playerid, 100);
    return Y_HOOKS_CONTINUE_RETURN_1;
}

forward Account_OnLoad(const playerid);
public Account_OnLoad(const playerid)
{
    InterpolateCameraPos(playerid, 163.370742, -2130.891113, 3.614542, 150.508148, -1941.372436, 53.552555, 7000);
    InterpolateCameraLookAt(playerid, 163.097000, -2125.963867, 4.419613, 152.024612, -1945.852172, 51.930122, 7000);
    KillTimer(accountLoadingTimer[playerid]);

    if(fexist(UserPath(playerid)))
    {
        INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
        Dialog_Show(playerid, "DIALOG_LOGIN", DIALOG_STYLE_PASSWORD,
            D_CAPTION,
            ""MAIN_COLOR"_______________________________________________\n\n\
            "WHITE"Unesite tacnu lozinku\n\
            "WHITE"Lozinka sadrzi "MAIN_COLOR"%d "WHITE"karaktera.\n\
            "MAIN_COLOR"_______________________________________________",
            ""MAIN_COLOR"Unesi", "Izlaz",
            strlen(Account_GetPassword(playerid))
        );

        UI_CreateLoginTextDraw(playerid);
    }

    else
    {
        Dialog_Show(playerid, "DIALOG_REGISTER", DIALOG_STYLE_PASSWORD,
            D_CAPTION,
            ""MAIN_COLOR"_______________________________________________\n\
            "MAIN_COLOR">>> "WHITE"Unesite zeljenu lozinku\n\
            "WHITE"Lozinka mora sadrzati najmanje "MAIN_COLOR"%d "WHITE"i najvise "MAIN_COLOR"%d "WHITE"karaktera!\n\
            "MAIN_COLOR"_______________________________________________",
            ""MAIN_COLOR"Unesi", "Izlaz",
            MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH
        );
    }
    return 1;
}

forward Account_SetSpawnData(const playerid, const spawnid);
public Account_SetSpawnData(const playerid, const spawnid)
{
    KillTimer(spawnTimer[playerid]);
    switch (spawnid)
    {
        case 1: Account_SetSpawn(playerid, 1);
        case 2: Account_SetSpawn(playerid, 2);

        default:
        {
            print("[ERROR]: Invalid spawn ID!");
        }
    }
    return 1;
}

forward SK_Timer(const playerid);
public SK_Timer(const playerid)
{
    TogglePlayerControllable(playerid, 1);
    KillTimer(playerSKTimer[playerid]);
    return 1;
}

stock Account_SetSpawn(const playerid, const spawnid)
{
    StopAudioStreamForPlayer(playerid);
    UI_UpdateInfoTD(playerid);
    TogglePlayerSpectating(playerid, 0);
    TogglePlayerControllable(playerid, 0);

    GameTextForPlayer(playerid, "~y~ANTI SPAWN KILL ZASTITA U TOKU...", 3000, 3);
    playerSKTimer[playerid] = SetTimerEx("SK_Timer", 3000, false, "d", playerid);

    switch (spawnid)
    {
        case 1:
        {
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
            
            for (new i = 0; i < 30; i++)
                SendClientMessage(playerid, -1, " ");

            SendServerMsgF(playerid, "Dobrodosao nazad %s %s.", Player_SplitName(playerid, "name"), Player_SplitName(playerid, "lastname"));
            SendServerMsgF(playerid, "Vas trenutni level: %d | Exp: %d/%d", Account_GetScore(playerid), Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
            if (Account_GetBankCard(playerid))
                SetTimerEx("Timer_UpdateAccHours", 45 * 1000 * 60, true, "d", playerid);
        }

        case 2:
        {
            // new houseid = Account_GetHouse(playerid);
            // SetPlayerVirtualWorld(playerid, House_GetVW(houseid));
            // SetPlayerInterior(playerid, 0);
            // SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), House_GetIntPos(houseid, 0), House_GetIntPos(houseid, 1), House_GetIntPos(houseid, 2), 0.0, 0, 0, 0, 0, 0, 0);
            // SpawnPlayer(playerid);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetSpawnInfo(playerid, 0, Account_GetSkin(playerid), 1583.8350, -2338.2874, 13.5890, 54.4807, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
            
            for (new i = 0; i < 30; i++)
                SendClientMessage(playerid, -1, " ");

            SendServerMsgF(playerid, "Dobrodosao nazad %s %s.", Player_SplitName(playerid, "name"), Player_SplitName(playerid, "lastname"));
            SendServerMsgF(playerid, "Vas trenutni level: %d | Exp: %d/%d", Account_GetScore(playerid), Account_GetExp(playerid), (Account_GetScore(playerid) * 2));
            if (Account_GetBankCard(playerid))
                SetTimerEx("Timer_UpdateAccHours", 45 * 1000 * 60, true, "d", playerid);
        }

        default:
        {
            print("[ERROR]: Invalid spawn ID!");
        }
    }
    return 1;
}

// Dialogs
Dialog: DIALOG_REGISTER(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Kick(playerid);

    if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
    {
        Dialog_Show(playerid, "DIALOG_REGISTER", DIALOG_STYLE_PASSWORD,
            D_CAPTION,
            ""MAIN_COLOR"_______________________________________________\n\
            "MAIN_COLOR">>> "WHITE"Unesite zeljenu lozinku\n\
            "WHITE"Lozinka mora sadrzati najmanje "MAIN_COLOR"%d "WHITE"i najvise "MAIN_COLOR"%d "WHITE"karaktera!\n\
            "MAIN_COLOR"_______________________________________________",
            ""MAIN_COLOR"Unesi", "Izlaz",
            MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH
        );
        return SendErrorMsg(playerid, "Prekratka ili predugacka lozinka!");
    }

    strcopy(PlayerData[playerid][pPassword], inputtext);

    Dialog_Show(playerid, "DIALOG_GENDER", DIALOG_STYLE_LIST,
        D_CAPTION,
        "Musko\nZensko",
        ""MAIN_COLOR"Odaberi", "Izlaz"
    );
    return 1;
}

Dialog: DIALOG_GENDER(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Kick(playerid);

    PlayerData[playerid][pGender] = listitem + 1;
    PlayerData[playerid][pSkin] = (PlayerData[playerid][pGender] == 1 ? 240 : 193);
    
    Dialog_Show(playerid, "DIALOG_COUNTRY", DIALOG_STYLE_LIST,
        D_CAPTION,
        "Srbija\nHrvatska\nBosna i Hercegovina\nCrna Gora\nMakedonija\nOstalo",
        ""MAIN_COLOR"Odaberi", "Izlaz"
    );
    return 1;
}

Dialog: DIALOG_COUNTRY(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Kick(playerid);

    PlayerData[playerid][pCountry] = listitem + 1;
    Dialog_Show(playerid, "DIALOG_DOB", DIALOG_STYLE_INPUT,
        D_CAPTION,
        ""WHITE"Unesite datum Vaseg rodjenja u formatu: YYYY-MM-DD (npr. 2005-08-13):",
        ""MAIN_COLOR"Unesi", "Izlaz"
    );
    return 1;
}

Dialog: DIALOG_DOB(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Kick(playerid);

    strcopy(PlayerData[playerid][pDOB], inputtext);
    PlayerData[playerid][pSpawn] = 1;
    spawnTimer[playerid] = SetTimerEx("Account_SetSpawnData", 3000, false, "di", playerid, Account_GetSpawn(playerid));
    UI_ShowLoadingTextDraw(playerid, "UCITAVANJE...", 3000);

    // Default variables
    PlayerData[playerid][pScore] = 1;
    PlayerData[playerid][pMoney] = 20000;
    PlayerData[playerid][pJob] = 0;
    PlayerData[playerid][pBankCard] = 0;
    PlayerData[playerid][pBankMoney] = 0;
    // PlayerData[playerid][pHouse] = -1;

    GivePlayerMoney(playerid, Account_GetMoney(playerid));
    SetPlayerScore(playerid, Account_GetScore(playerid));
    UI_SetPlayerIGTD(playerid);
    // Movement_CreateUI(playerid, true);

    Account_SavePlayer(playerid);

    for (new i = 0; i < 30; i++)
        SendClientMessage(playerid, -1, " ");

    SendServerMsgF(playerid, "Dobrodosao %s.", ReturnPlayerName(playerid));
    return 1;
}

Dialog: DIALOG_LOGIN(const playerid, response, listitem, string: inputtext[])
{
    if (!response)
        return Kick(playerid);

    if (!strcmp(inputtext, PlayerData[playerid][pPassword], false))
    {
        INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
        UI_CreateLoginTextDraw(playerid);
        UI_ShowLoadingTextDraw(playerid, "UCITAVANJE...", 3000);
        spawnTimer[playerid] = SetTimerEx("Account_SetSpawnData", 3000, false, "di", playerid, Account_GetSpawn(playerid));

        GivePlayerMoney(playerid, Account_GetMoney(playerid));
        SetPlayerScore(playerid, Account_GetScore(playerid));
        UI_SetPlayerIGTD(playerid);
    }

    else
    {
        SendErrorMsg(playerid, "Netacna lozinka."); 
        Dialog_Show(playerid, "DIALOG_LOGIN", DIALOG_STYLE_PASSWORD,
            D_CAPTION,
            ""MAIN_COLOR"_______________________________________________\n\n\
            "WHITE"Unesite tacnu lozinku\n\
            "WHITE"Lozinka sadrzi "MAIN_COLOR"%d "WHITE"karaktera.\n\
            "MAIN_COLOR"_______________________________________________",
            ""MAIN_COLOR"Unesi", "Izlaz",
            strlen(Account_GetPassword(playerid))
        );
    }
    return 1;
}

// Update player hours spent on server
// 3,600,000ms = 1 hour
// 2,700,000ms = 45 minutes
forward Timer_UpdateAccHours(const playerid);
public Timer_UpdateAccHours(const playerid)
{
    new salary, base, exp;

    base += (1500 + random(250));
    salary = (base * Account_GetScore(playerid));
    exp = (Account_GetScore(playerid) * 2);

    if (Account_GetScore(playerid) < 10)
        Account_SetExp(playerid, (Account_GetExp(playerid) + 2));
    else
        Account_SetExp(playerid, (Account_GetExp(playerid) + 1));

    Account_SetHours(playerid, Account_GetHours(playerid) + 1);
    Account_SetBankMoney(playerid, (Account_GetBankMoney(playerid) + salary));
    if (Account_GetExp(playerid) >= exp)
    {
        Account_SetScore(playerid, (Account_GetScore(playerid) + 1));
        SetPlayerScore(playerid, Account_GetScore(playerid));
        Account_SetExp(playerid, (Account_GetExp(playerid)) - exp);
        SendServerMsgF(playerid, "Presli ste u sledeci level! Sada ste level %d!", Account_GetScore(playerid));
    }

    Dialog_Show(playerid, "DIALOG_PAYDAY", DIALOG_STYLE_MSGBOX,
        ""DARKGREEN"PAYDAY - "WHITE"Isplata",
        ""DARKGREEN"Plata je stigla na Vas racun!\n\n\
        "WHITE"Plata: "DARKGREEN"$"WHITE"%d\n\
        "WHITE"Level: %d",
        "Izlaz", "",
        salary, Account_GetScore(playerid)
    );
    UI_UpdateInfoTD(playerid);
    return 1;
}