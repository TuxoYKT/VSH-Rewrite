#define MONOCULUS_MODEL			"models/props_halloween/halloween_demoeye.mdl"
#define EYEPROJECTILE_MODEL		"models/props_halloween/eyeball_projectile.mdl"

#define PARTICLE_EYEBALL_AURA_ANGRY		"eb_aura_angry01"
#define PARTICLE_EYEBALL_AURA_CALM		"eb_aura_calm01"
#define PARTICLE_EYEBALL_AURA_GRUMPY	"eb_aura_grumpy01"
#define PARTICLE_EYEBALL_AURA_STUNNED	"eb_aura_stunned01"

#define MAX_DISTANCE_FROM_THE_FLOOR		576

static float g_flMonoculusRageTimer[TF_MAXPLAYERS];
static float g_flMonoculusLastAttack[TF_MAXPLAYERS];
static float g_flMonoculusAttackRateDuringRage[TF_MAXPLAYERS];
static float g_flRandomAnimationTimer[TF_MAXPLAYERS];
static float g_flDistance[TF_MAXPLAYERS];

static bool g_bMonoculusStunned[TF_MAXPLAYERS];


static char g_strMonoculusRoundStart[][] = {
	"vo/halloween_eyeball/eyeball_biglaugh01.mp3"
};

static char g_strMonoculusWin[][] = {
	"vo/halloween_eyeball/eyeball11.mp3"
};

static char g_strMonoculusLose[][] = {
	"vo/halloween_eyeball/eyeball09.mp3",
	"vo/halloween_eyeball/eyeball10.mp3"
};

static char g_strMonoculusRage[][] = {
	"vo/halloween_eyeball/eyeball_mad01.mp3",
	"vo/halloween_eyeball/eyeball_mad02.mp3",
	"vo/halloween_eyeball/eyeball_mad03.mp3"
};

static char g_strMonoculusKill[][] = {
	"vo/halloween_eyeball/eyeball_laugh01.mp3",
	"vo/halloween_eyeball/eyeball_laugh02.mp3",
	"vo/halloween_eyeball/eyeball_laugh03.mp3"
};

static char g_strMonoculusLastMan[][] = {
	"ui/halloween_boss_player_becomes_it.wav"
};

static char g_strMonoculusBackStabbed[][] = {
	"vo/halloween_eyeball/eyeball01.mp3",
	"vo/halloween_eyeball/eyeball02.mp3",
	"vo/halloween_eyeball/eyeball03.mp3",
	"vo/halloween_eyeball/eyeball04.mp3",
	"vo/halloween_eyeball/eyeball05.mp3",
	"vo/halloween_eyeball/eyeball06.mp3",
	"vo/halloween_eyeball/eyeball07.mp3",
	"vo/halloween_eyeball/eyeball09.mp3"
};

static char g_strMonoculusAttack[][] = {
	"vo/halloween_eyeball/eyeball04.mp3"
};

static char g_strMonoculusPain[][] = {
	"vo/halloween_eyeball/eyeball_boss_pain01.mp3"
};

public void Monoculus_Create(SaxtonHaleBase boss)
{
	boss.CreateClass("WeaponFists");
	
	boss.iHealthPerPlayer = 400;
	boss.flHealthExponential = 1.05;
	boss.nClass = TFClass_DemoMan;
	boss.iMaxRageDamage = 2000;
	
	g_flMonoculusRageTimer[boss.iClient] = 0.0;
	g_flMonoculusLastAttack[boss.iClient] = GetGameTime();
	g_flRandomAnimationTimer[boss.iClient] = GetGameTime();
}

public void Monoculus_GetBossName(SaxtonHaleBase boss, char[] sName, int length)
{
	strcopy(sName, length, "Monoculus");
}

public void Monoculus_GetBossInfo(SaxtonHaleBase boss, char[] sInfo, int length)
{
	StrCat(sInfo, length, "\nHealth: Low");
	StrCat(sInfo, length, "\n ");
	StrCat(sInfo, length, "\nAbilities");
	StrCat(sInfo, length, "\n- Flight");
	StrCat(sInfo, length, "\n ");
	StrCat(sInfo, length, "\nRage");
	StrCat(sInfo, length, "\n- Damage requirement: 2000");
  	StrCat(sInfo, length, "\n- Rocket Barrage");
	StrCat(sInfo, length, "\n- 200%% Rage: Extends duration to 15 seconds");
}

public void Monoculus_OnSpawn(SaxtonHaleBase boss)
{
	char attribs[128];
	Format(attribs, sizeof(attribs), "1 ; 0.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 214 ; %d", GetRandomInt(9999, 99999));
	int iWeapon = boss.CallFunction("CreateWeapon", 195, "tf_weapon_fists", 100, TFQual_Strange, attribs);
	if (iWeapon > MaxClients)
		SetEntPropEnt(boss.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);

	// Hide weapon from view
	SetEntPropFloat(iWeapon, Prop_Send, "m_flModelScale", 0.001);

	// Make boss float
	TF2_AddCondition(boss.iClient, TFCond_SwimmingNoEffects, TFCondDuration_Infinite);
	/*
	Fist attributes:
	
	1: damage penalty
	252: reduction in push force taken from damage
	259: Deals 3x falling damage to the player you land on
	214: kill_eater
	*/

	float vecOrigin[3];
	vecOrigin[2] += 48.0;
	SetVariantVector3D(vecOrigin);
	AcceptEntityInput(boss.iClient, "SetCustomModelOffset");
}

public void Monoculus_GetModel(SaxtonHaleBase boss, char[] sModel, int length)
{
	strcopy(sModel, length, MONOCULUS_MODEL);
}

public void Monoculus_GetSound(SaxtonHaleBase boss, char[] sSound, int length, SaxtonHaleSound iSoundType)
{
	switch (iSoundType)
	{
		case VSHSound_RoundStart: strcopy(sSound, length, g_strMonoculusRoundStart[GetRandomInt(0,sizeof(g_strMonoculusRoundStart)-1)]);
		case VSHSound_Win: strcopy(sSound, length, g_strMonoculusWin[GetRandomInt(0,sizeof(g_strMonoculusWin)-1)]);
		case VSHSound_Lose: strcopy(sSound, length, g_strMonoculusLose[GetRandomInt(0,sizeof(g_strMonoculusLose)-1)]);
		case VSHSound_Rage: strcopy(sSound, length, g_strMonoculusRage[GetRandomInt(0,sizeof(g_strMonoculusRage)-1)]);
		case VSHSound_Lastman: strcopy(sSound, length, g_strMonoculusLastMan[GetRandomInt(0,sizeof(g_strMonoculusLastMan)-1)]);
		case VSHSound_Backstab: strcopy(sSound, length, g_strMonoculusBackStabbed[GetRandomInt(0,sizeof(g_strMonoculusBackStabbed)-1)]);
		case VSHSound_Pain: strcopy(sSound, length, g_strMonoculusPain[GetRandomInt(0,sizeof(g_strMonoculusPain)-1)]);
	}
}

public void Monoculus_GetSoundKill(SaxtonHaleBase boss, char[] sSound, int length, TFClassType nClass)
{
	strcopy(sSound, length, g_strMonoculusKill[GetRandomInt(0,sizeof(g_strMonoculusKill)-1)]);
}

public Action Monoculus_OnSoundPlayed(SaxtonHaleBase boss, int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (strncmp(sample, "vo/", 3) == 0)//Block voicelines but allow Monoculus voicelines
	{
		if (StrContains(sample, "vo/halloween_boss/", false) == 0)
			return Plugin_Continue;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void Monoculus_Precache(SaxtonHaleBase boss)
{
	PrecacheModel(MONOCULUS_MODEL);
	PrecacheModel(EYEPROJECTILE_MODEL);
	for (int i = 0; i < sizeof(g_strMonoculusRoundStart); i++) PrecacheSound(g_strMonoculusRoundStart[i]);
	for (int i = 0; i < sizeof(g_strMonoculusWin); i++) PrecacheSound(g_strMonoculusWin[i]);
	for (int i = 0; i < sizeof(g_strMonoculusLose); i++) PrecacheSound(g_strMonoculusLose[i]);
	for (int i = 0; i < sizeof(g_strMonoculusRage); i++) PrecacheSound(g_strMonoculusRage[i]);
	for (int i = 0; i < sizeof(g_strMonoculusKill); i++) PrecacheSound(g_strMonoculusKill[i]);
	for (int i = 0; i < sizeof(g_strMonoculusLastMan); i++) PrecacheSound(g_strMonoculusLastMan[i]);
	for (int i = 0; i < sizeof(g_strMonoculusBackStabbed); i++) PrecacheSound(g_strMonoculusBackStabbed[i]);
	for (int i = 0; i < sizeof(g_strMonoculusAttack); i++) PrecacheSound(g_strMonoculusAttack[i]);
	for (int i = 0; i < sizeof(g_strMonoculusPain); i++) PrecacheSound(g_strMonoculusPain[i]);
}

public void Monoculus_OnButton(SaxtonHaleBase boss, int &buttons)
{
	if (buttons & IN_ATTACK)
		ShootRocket(boss.iClient);

	if (g_flDistance[boss.iClient] > MAX_DISTANCE_FROM_THE_FLOOR &&
	    buttons & IN_JUMP)
		buttons &= ~IN_JUMP;
}

public void Monoculus_OnThink(SaxtonHaleBase boss)
{
	// Play idle animations
	if (g_flRandomAnimationTimer[boss.iClient] <= GetGameTime())
	{
		/* // Don't play animation if the boss attacked
		if (g_flMonoculusLastAttack[boss.iClient] > GetGameTime() - 1.5 + g_flMonoculusAttackRateDuringRage[boss.iClient])
		{
			return;
		} */

		char sAnim[128];
		Format(sAnim, sizeof(sAnim), "lookaround%i", GetRandomInt(1,3));
		SDKCall_PlaySpecificSequence(boss.iClient, sAnim);
		g_flRandomAnimationTimer[boss.iClient] = GetGameTime() + 10.0;
	}

	// Limit Monoculus height gain
	float vecPos[3], vecEndPos[3], vecVel[3];
	GetClientEyePosition(boss.iClient, vecPos);
	TR_TraceRayFilter(vecPos, view_as<float>( { 90.0, 0.0, 0.0 } ), MASK_SOLID, RayType_Infinite, TraceRay_DontHitPlayersAndObjects);
	TR_GetEndPosition(vecEndPos);
	g_flDistance[boss.iClient] = GetVectorDistance(vecPos, vecEndPos);

   	GetEntPropVector(boss.iClient, Prop_Data, "m_vecVelocity", vecVel);
	AddVectors(vecVel, view_as<float>( { 0.0, 0.0, -30.0 } ), vecVel);

	if (g_flDistance[boss.iClient] > MAX_DISTANCE_FROM_THE_FLOOR)
		TeleportEntity(boss.iClient, NULL_VECTOR, NULL_VECTOR, vecVel);

	// Make sure the boss is alive
	if (!IsPlayerAlive(boss.iClient))
	{
		return;
	}
	// Make sure the rage is empty
	if (g_flMonoculusRageTimer[boss.iClient] == 0.0)
	{
		return;
	}

	// Rage ends here
	if (g_flMonoculusRageTimer[boss.iClient] <= GetGameTime())
	{
		g_flMonoculusRageTimer[boss.iClient] = 0.0;
		g_flMonoculusAttackRateDuringRage[boss.iClient] = 0.0;
	}
}

public void Monoculus_OnRage(SaxtonHaleBase boss)
{
	float vecOrigin[3];
	GetClientAbsOrigin(boss.iClient, vecOrigin);

	vecOrigin[2] += 48.0;
	g_flMonoculusAttackRateDuringRage[boss.iClient] = 1.0;

	if (boss.bSuperRage)
	{
		CreateTimer(15.0, Timer_EntityCleanup, TF2_SpawnParticle(PARTICLE_EYEBALL_AURA_ANGRY, vecOrigin, NULL_VECTOR, true, boss.iClient));
		g_flMonoculusRageTimer[boss.iClient] = GetGameTime() + 15.0;
		return;
	}

	CreateTimer(10.0, Timer_EntityCleanup, TF2_SpawnParticle(PARTICLE_EYEBALL_AURA_GRUMPY, vecOrigin, NULL_VECTOR, true, boss.iClient));
	g_flMonoculusRageTimer[boss.iClient] = GetGameTime() + 10.0;	
}

public Action Monoculus_OnTakeDamage(SaxtonHaleBase boss, int &attacker, int &inflictor, int &damage, int &damagetype)
{
	char sInflictor[32];
	GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));

	// Check for rocket damage
	if (strcmp(sInflictor, "tf_projectile_rocket") != 0) 
		return Plugin_Continue;

	// Ignore damage from own rockets
	if (attacker == boss.iClient) 
		return Plugin_Stop;

	// Check for deflected rocket
	if (GetEntProp(inflictor, Prop_Send, "m_iDeflected") == 0) 
		return Plugin_Continue;

	// Check if boss is not in rage mode
	if (!(g_flMonoculusRageTimer[boss.iClient] > GetGameTime())) 
		StunMonoculus(boss.iClient);

	return Plugin_Continue;
}

public void ShootRocket(int iClient)
{	
	// Make sure player is alive and well
	if (!IsPlayerAlive(iClient))
		return;

	float vecOrigin[3], vecAngles[3], vecVelocity[3];
	GetClientEyePosition(iClient, vecOrigin);
	GetClientEyeAngles(iClient, vecAngles);

	// Make sure
	if (g_flMonoculusLastAttack[iClient] == 0.0)
		return;

	// Rocket cooldown
	if (g_flMonoculusLastAttack[iClient] > GetGameTime() - 1.5 + g_flMonoculusAttackRateDuringRage[iClient])
		return;

	// If boss stunned then don't allow it to shoot
	if (g_bMonoculusStunned[iClient])
		return;

	g_flMonoculusLastAttack[iClient] = GetGameTime();

	int iRocket = CreateEntityByName("tf_projectile_rocket")
	if (iRocket > MaxClients)
	{
		// Make it deflected so it can damage players
		SetEntProp(iRocket, Prop_Send, "m_iDeflected", 1);
		// Make boss the owner of the eyeball
		SetEntProp(iRocket, Prop_Send, "m_iTeamNum", GetClientTeam(iClient));
		SetEntPropEnt(iRocket, Prop_Send, "m_hOwnerEntity", iClient);
		// Set rocket damage
		SetEntDataFloat(iRocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, 60.0, true);
		// Set rocket model
		DispatchSpawn(iRocket);
		SetEntityModel(iRocket, EYEPROJECTILE_MODEL);
		// Spawn rocket in front of player
		GetAngleVectors(vecAngles, vecVelocity, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vecVelocity, 1200.0);
		TeleportEntity(iRocket, vecOrigin, vecAngles, vecVelocity);
	}

	// if enraged then play different animation 
	if (g_flMonoculusRageTimer[iClient] > GetGameTime())
	{
		SDKCall_PlaySpecificSequence(iClient, "firing3");
		EmitAmbientSound(g_strMonoculusRage[GetRandomInt(0,sizeof(g_strMonoculusRage)-1)], vecOrigin, iClient);
		return;
	}

	SDKCall_PlaySpecificSequence(iClient, "firing1");
	EmitAmbientSound(g_strMonoculusAttack[GetRandomInt(0,sizeof(g_strMonoculusAttack)-1)], vecOrigin, iClient);
	
}

public void StunMonoculus(int iClient)
{
	float vecOrigin[3];
	GetClientAbsOrigin(iClient, vecOrigin);

	g_bMonoculusStunned[iClient] = true;
	
	CreateTimer(5.0, Timer_EntityCleanup, TF2_SpawnParticle(PARTICLE_EYEBALL_AURA_STUNNED, vecOrigin, NULL_VECTOR));
	CreateTimer(5.0, StunMonoculusEnd, iClient);
	
	SetVariantInt(1);
	AcceptEntityInput(iClient, "SetForcedTauntCam");

	SetEntityMoveType(iClient, MOVETYPE_NONE);
	SDKCall_PlaySpecificSequence(iClient, "stunned");

	PrintCenterText(iClient, "You are stunned from a reflected rocket!");

	EmitAmbientSound(g_strMonoculusBackStabbed[GetRandomInt(0,sizeof(g_strMonoculusBackStabbed)-1)], vecOrigin, iClient);

	TF2_StunPlayer(iClient, 5.0, 0.0, TF_STUNFLAG_NOSOUNDOREFFECT, 0);
}

public Action StunMonoculusEnd(Handle timer, int iClient)
{
	g_bMonoculusStunned[iClient] = false;

	SetEntityMoveType(iClient, MOVETYPE_WALK);
	SetVariantInt(0);
	AcceptEntityInput(iClient, "SetForcedTauntCam");

	return Plugin_Continue;
}