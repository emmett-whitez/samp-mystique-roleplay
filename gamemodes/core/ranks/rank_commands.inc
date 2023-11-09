#if defined _INC_rank_commands_inc
    #endinput
#endif
#define _INC_rank_commands_inc

#include <player/player_commands>
#include <vip/vip_commands>
#include <admin/admin_commands>

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
    if (success != COMMAND_OK)
    {
        SendErrorMsgF(playerid, "Komanda %s ne postoji.", cmdtext);
        return COMMAND_OK;
    }
    return COMMAND_OK;
}