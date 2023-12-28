/*
	@ GAMEMODE NAME: 	MystiqueRP
	@ AUTHOR: 			Emmett (Dejan Jovanovic)
	@ SINCE:			2023
	@ TO-DO: 	 		//
*/

#define AMX_OLD_CALL
#define YSI_NO_HEAP_MALLOC
#define YSI_NO_VERSION_CHECK
#define YSI_NO_MODE_CACHE
#define YSI_NO_OPTIMISATION_MESSAGE

#define CGEN_MEMORY 50000
#define FOREACH_NO_BOTS
#define FOREACH_NO_STREAMED

#define MAX_PLAYERS 50

#include <a_samp>
#include <streamer>
#include <sscanf2>
// #include <winteredition>
#include <progress2>
#include <strlib>

#include <YSI_Storage\y_ini>
#include <YSI_Coding\y_malloc>
#include <YSI_Coding\y_timers>
#include <YSI_Server\y_colours>
#include <YSI_Data\y_bit>

#undef X11_RED
#define X11_RED 0xFF0000FF

#include <jit>
#include <easy-dialog>
#include <FCNPC>

#include <zcmd>

//==============================[ SETTINGS ]==============================
#include "/utils/settings.pwn"
//==============================[ WORLD ]==============================
#include "/world/world_init.pwn"
#include "/world/maps/map_spawn.pwn"
#include "/world/maps/map_hospital.pwn"
#include "/world/maps/map_bank.pwn"
// #include <maps/map_winteredition>
#include "/world/maps/map_lspd.pwn"
#include "/world/maps/map_postmanjob.pwn"
#include "/world/maps/map_mowerjob.pwn"
#include "/world/maps/map_houseint.pwn"
#include "/world/maps/map_cityhall.pwn"
#include "/world/maps/map_cardealership.pwn"
#include "/world/maps/map_tuneshop.pwn"
#include "/world/maps/map_weedgrower.pwn"
#include "/world/maps/map_jail.pwn"
#include "/world/maps/map_elkor.pwn"
#include "/world/maps/map_randomworldmaps.pwn"
//==============================[ ACCOUNTS ]==============================
#include "/core/accounts/account_init.pwn"
//==============================[ RANKS ]==============================
#include "/core/ranks/rank_init.pwn"
#include "/core/ranks/rank_commands.pwn"
#include "/core/ranks/player/player_functions.pwn"
#include "/core/ranks/vip/vip_commands.pwn"
#include "/core/ranks/admin/admin_commands.pwn"
#include "/core/ranks/player/commands.pwn"
//==============================[ PLAYERS ]==============================
#include "/core/player/jobs/job_postman.pwn"
#include "/core/player/jobs/job_lawnmower.pwn"
#include "/core/player/jobs/job_busdriver.pwn"
#include "/core/player/jobs/job_weedgrower.pwn"
#include "/core/player/jobs/job_init.pwn"
#include "/core/player/anims/anims_init.pwn"
#include "/core/player/ui/ui_ingame.pwn"
#include "/core/player/ui/ui_idcard.pwn"
//==============================[ SYSTEMS ]==============================
#include "/core/systems/rent/rent_init.pwn"
#include "/core/systems/property/property_init.pwn"
// #include "/core/systems/houses/house_init.pwn"
#include "/core/systems/vehicles/vehicle_init.pwn"
#include "/core/systems/kiosk/kiosk_init.pwn"
#include "/core/systems/orgs/org_lspd.pwn"
#include "/core/systems/orgs/org_init.pwn"
#include "/core/systems/gps/gps_init.pwn"
#include "/core/systems/wanted/wanted_init.pwn"
#include "/core/systems/mobile/mobile_init.pwn"
#include "/core/systems/port/port_init.pwn"
#include "/core/systems/events/event_dm.pwn"
#include "/core/systems/events/event_init.pwn"
#include "/core/systems/atms/atm_init.pwn"
#include "/core/systems/backpack/backpack_init.pwn"

main()
{
	printf("[INFO]: JIT %s", (IsJITPresent() ? ("nije prisutan.") : ("je prisutan.")));
	OnJITCompile();
	printf("[INFO]: Mod se uspesno ucitao.");
}

forward OnJITCompile();
forward Bind_OnPlayerDisconnect(
	CallbackHandler: self, Handle: task_handle, Task: task, const orig_playerid, const playerid
);

public OnJITCompile()
{
	printf("[INFO]: OnJITCompile->JIT %s", (IsJITPresent() ? ("nije prisutan.") : ("je prisutan.")));
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_ACTION)
	{
		new Float:vx, Float:vy, Float:vz;
		GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
		SetVehicleVelocity(GetPlayerVehicleID(playerid), vx * 1.2, vy *1.2, vz * 1.2);
    }

    // else if (newkeys & KEY_SECONDARY_ATTACK)
    // 	ApplyAnimation(playerid, "MISC","seat_talk_02", 2.0, 1, 0, 0, 0, 0, 1);	
    return 1;
}