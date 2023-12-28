#if defined _INC_database_inc
    #endinput
#endif
#define _INC_database_inc

#include <YSI_Coding\y_hooks>

new MySQL: db_handle = MYSQL_INVALID_HANDLE;
#define MySQL_GetHandle() db_handle

hook OnGameModeInit()
{
	CreateDatabaseConnection();
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnGameModeExit()
{
    if (!mysql_close(db_handle))
        print("[MySQL]: Nemoguce zavrsiti konekciju sa databazom.");
    return Y_HOOKS_CONTINUE_RETURN_1;
}

static CreateDatabaseConnection()
{
	new MySQLOpt: options = mysql_init_options();
    mysql_set_option(options, AUTO_RECONNECT, true);

    MySQL_GetHandle() = mysql_connect("localhost", "root", "", "balkanlite_db", options);
    // MySQL_GetHandle() = mysql_connect("localhost", "sql_1092216_C54", "KBtpz8kD", "sql_1092216_C54", options);
    if (MySQL_GetHandle() == MYSQL_INVALID_HANDLE || mysql_errno(MySQL_GetHandle()))
    {
        print("[MySQL]: Nije moguce uspostaviti konekciju sa databazom!");
        SendRconCommand("exit");
        return 1;
    }

    print("[MySQL]: Uspesna konekcija sa databazom.");
	return 1;
}

// OnQueryError - REQUIRED
public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle) return 1;

// stock Task: MySQL_Query(const query[]) return mysql_aquery(MySQL_GetHandle(), query, true);
// stock Task: MySQL_QueryS(ConstStringTag:query) return mysql_aquery_s(MySQL_GetHandle(), query, true);