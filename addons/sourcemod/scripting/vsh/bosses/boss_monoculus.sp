#define MONOCULUS_MODEL			"models/props_halloween/halloween_demoeye.mdl"
#define EYEPROJECTILE_MODEL		"models/props_halloween/eyeball_projectile.mdl"

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
	Format(attribs, sizeof(attribs), "2 ; 2.80 ; 252 ; 0.5 ; 259 ; 1.0 ; 214 ; %d", GetRandomInt(9999, 99999));
	int iWeapon = boss.CallFunction("CreateWeapon", 195, "tf_weapon_shovel", 100, TFQual_Strange, attribs);
	if (iWeapon > MaxClients)
		SetEntPropEnt(boss.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);

	TF2_AddCondition(boss.iClient, TFCond_SwimmingNoEffects, TFCondDuration_Infinite);
	/*
	Fist attributes:
	
	2: damage bonus
	252: reduction in push force taken from damage
	259: Deals 3x falling damage to the player you land on
	214: kill_eater
	*/
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
	if (strncmp(sample, "vo/demoman", 10) == 0)//Block voicelines but allow Monoculus voicelines
		return Plugin_Handled;
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

