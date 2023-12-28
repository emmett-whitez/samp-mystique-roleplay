public OnPlayerCommandReceived(playerid, cmdtext[])
{
    if (!IsPlayerConnected(playerid))
        return 0;
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if (!success)
        return SendErrorMsg(playerid, "Ta komanda ne postoji!");
    return 1;
}