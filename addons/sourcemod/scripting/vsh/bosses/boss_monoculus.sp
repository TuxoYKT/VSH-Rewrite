#define MONOCULUS_MODEL			"models/props_halloween/halloween_demoeye.mdl"
#define EYEPROJECTILE_MODEL		"models/props_halloween/eyeball_projectile.mdl"

#define PARTICLE_EYEBALL_AURA_ANGRY		"eb_aura_angry01"
#define PARTICLE_EYEBALL_AURA_CALM		"eb_aura_calm01"
#define PARTICLE_EYEBALL_AURA_GRUMPY	"eb_aura_grumpy01"

static float g_flMonoculusRageTimer[TF_MAXPLAYERS];
static float g_flMonoculusLastAttack[TF_MAXPLAYERS];
static float g_flMonoculusAttackRateDuringRage[TF_MAXPLAYERS];
static float g_flRandomAnimationTimer[TF_MAXPLAYERS];

static int g_iMonoculusParticle[TF_MAXPLAYERS];

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
/* 
static char g_strMonoculusTeleport[][] = {
	"vo/halloween_eyeball/eyeball_teleport01.mp3"
}; */

methodmap CMonoculus < SaxtonHaleBase
{
	public CMonoculus(CMonoculus boss)
	{	
		boss.iHealthPerPlayer = 400;
		boss.flHealthExponential = 1.05;
		boss.nClass = TFClass_DemoMan;
		boss.iMaxRageDamage = 2000;
		
		g_flMonoculusRageTimer[boss.iClient] = 0.0;
		g_flMonoculusLastAttack[boss.iClient] = GetGameTime();
		g_flRandomAnimationTimer[boss.iClient] = GetGameTime();
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "Monoculus");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
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
	
	public void OnSpawn()
	{
		int iClient = this.iClient;

		char attribs[128];
		Format(attribs, sizeof(attribs), "59 ; 1.0 ; 252 ; 1.0 ; 214 ; %d", GetRandomInt(9999, 99999));
		int iWeapon = this.CallFunction("CreateWeapon", 405, "tf_wearable", 100, TFQual_Strange, attribs);
		if (iWeapon > MaxClients)
		{
			SetEntityRenderMode(iWeapon, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iWeapon, _, _, _, 0);
		}

		TF2_AddCondition(iClient, TFCond_SwimmingNoEffects, TFCondDuration_Infinite);

		SetEntPropFloat(iClient, Prop_Data, "m_flModelScale", 0.80);

		float vecOrigin[3];
		vecOrigin[2] += 48.0;
		SetVariantVector3D(vecOrigin);
		AcceptEntityInput(iClient, "SetCustomModelOffset");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, MONOCULUS_MODEL);
	}
	
	public void GetSound(char[] sAnim, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_RoundStart: strcopy(sAnim, length, g_strMonoculusRoundStart[GetRandomInt(0,sizeof(g_strMonoculusRoundStart)-1)]);
			case VSHSound_Win: strcopy(sAnim, length, g_strMonoculusWin[GetRandomInt(0,sizeof(g_strMonoculusWin)-1)]);
			case VSHSound_Lose: strcopy(sAnim, length, g_strMonoculusLose[GetRandomInt(0,sizeof(g_strMonoculusLose)-1)]);
			case VSHSound_Rage: strcopy(sAnim, length, g_strMonoculusRage[GetRandomInt(0,sizeof(g_strMonoculusRage)-1)]);
			case VSHSound_Lastman: strcopy(sAnim, length, g_strMonoculusLastMan[GetRandomInt(0,sizeof(g_strMonoculusLastMan)-1)]);
			case VSHSound_Backstab: strcopy(sAnim, length, g_strMonoculusBackStabbed[GetRandomInt(0,sizeof(g_strMonoculusBackStabbed)-1)]);
		}
	}
	
	public void GetSoundKill(char[] sAnim, int length, TFClassType nClass)
	{
		strcopy(sAnim, length, g_strMonoculusKill[GetRandomInt(0,sizeof(g_strMonoculusKill)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/demoman", 10) == 0)//Block voicelines but allow Monoculus voicelines
			return Plugin_Handled;
		return Plugin_Continue;
	}

	public void OnRage()
	{
		int iClient = this.iClient;

		float vecOrigin[3];
		GetClientAbsOrigin(iClient, vecOrigin);

		vecOrigin[2] += 48.0;

		if (this.bSuperRage)
		{
			g_flMonoculusAttackRateDuringRage[iClient] = 0.5;
			g_iMonoculusParticle[iClient] = TF2_SpawnParticle(PARTICLE_EYEBALL_AURA_ANGRY, vecOrigin, NULL_VECTOR, true, iClient);
			g_flMonoculusRageTimer[iClient] = GetGameTime() + 5.0;
		}
		else
		{
			g_flMonoculusAttackRateDuringRage[iClient] = 0.3;
			g_iMonoculusParticle[iClient] = TF2_SpawnParticle(PARTICLE_EYEBALL_AURA_GRUMPY, vecOrigin, NULL_VECTOR, true, iClient);
		}

		g_flMonoculusRageTimer[iClient] = GetGameTime() + 10.0;
	}

	public void OnThink()
	{
		int iClient = this.iClient;

		//Do something when rage ends
		if (g_flMonoculusRageTimer[iClient] != 0.0 && g_flMonoculusRageTimer[iClient] <= GetGameTime())
		{
			g_flMonoculusRageTimer[iClient] = 0.0;
			g_flMonoculusAttackRateDuringRage[iClient] = 0.0;

			RemoveEntity(g_iMonoculusParticle[iClient]);
		}

		//Play idle animations
		if (g_flRandomAnimationTimer[iClient] != 0.0 && g_flRandomAnimationTimer[iClient] <= GetGameTime() && IsPlayerAlive(iClient) && g_flMonoculusLastAttack[iClient] < GetGameTime() - 0.8 + g_flMonoculusAttackRateDuringRage[iClient])
		{
			char sAnim[128];
			Format(sAnim, sizeof(sAnim), "lookaround%i", GetRandomInt(1,3));
			SDKCall_PlaySpecificSequence(iClient, sAnim);
			g_flRandomAnimationTimer[iClient] = GetGameTime() + 10.0;
		}
		
	}

	public void OnButton(int &buttons)
	{
		int iClient = this.iClient;

		float vecOrigin[3], vecAngles[3], vecVelocity[3];
		GetClientEyePosition(iClient, vecOrigin);
		GetClientEyeAngles(iClient, vecAngles);

		if (buttons & IN_ATTACK && IsPlayerAlive(iClient) && g_flMonoculusLastAttack[iClient] != 0.0 && g_flMonoculusLastAttack[iClient] < GetGameTime() - 0.8 + g_flMonoculusAttackRateDuringRage[iClient])
		{
			g_flMonoculusLastAttack[iClient] = GetGameTime();

			int iRocket = CreateEntityByName("tf_projectile_rocket");
			if (iRocket > MaxClients)
			{
				SetEntProp(iRocket, Prop_Send, "m_iTeamNum", GetClientTeam(iClient));
				SetEntProp(iRocket, Prop_Send, "m_iDeflected", 1);
				SetEntPropEnt(iRocket, Prop_Send, "m_hOwnerEntity", iClient);
				SetEntDataFloat(iRocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, 60.0, true);

				DispatchSpawn(iRocket);

				SetEntityModel(iRocket, EYEPROJECTILE_MODEL);

				GetAngleVectors(vecAngles, vecVelocity, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(vecVelocity, 900.0);

				TeleportEntity(iRocket, vecOrigin, vecAngles, vecVelocity);
			}

			if (g_flMonoculusRageTimer[iClient] > GetGameTime())
			{
				SDKCall_PlaySpecificSequence(iClient, "firing3");
				
				EmitAmbientSound(g_strMonoculusRage[GetRandomInt(0,2)], vecOrigin, iClient);
			}
			else
			{
				SDKCall_PlaySpecificSequence(iClient, "firing1");

				EmitAmbientSound(g_strMonoculusAttack[0], vecOrigin, iClient);
			}
		}
	}
	
	public void Precache()
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
	}
};