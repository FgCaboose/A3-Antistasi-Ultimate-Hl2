	class HL_Base
	{
		requiredAddons[] = {"HL_CMB_Core","CUP_BaseConfigs","CUP_Vehicles_Core","HL_CMB_Weapons_SMG_01","HL_CMB_Vehicles","HL_CMB_Weapons","WBK_Combinus"};
		logo = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_combine_co.paa);
		basepath = QPATHTOFOLDER(Templates\Templates\HL2);
		priority = 30;
	};
////// Combine Start ///////
	class HL_COMB : HL_Base
	{
		side = "Inv";
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_combine_co.paa);
		name = "The Combine Union";
		file = "HL_Combine";
		description = "We are the Universal Union. Held by a conglomerate effort to Unite, Protect, and Eliminate. In the early days of The Combine Invasion, humans were used for a militia force.";
	};
////// Coalition Start///////	
	class HL_COA : HL_Base
	{
		side = "Occ";
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_udc_co.paa);
		name = "Defense Coalition";
		file = "HL_Coalition_Arid";
		climate[] = {"arid", "temperate"};
		description = "The remnants of the old world militaries. Fighting to restore earth to the old order.";	
	};	
	class HL_COA_TMPRT : HL_COA
	{
		name = "Defense Coalition (Temperate)";
		file = "HL_Coalition_Temperate";
		climate[] = {"temperate"};
	};
////////// Citizen and Zombie //////////
	class HL_CIV : HL_Base
	{
		side = "Civ";
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_combine_co.paa);
		name = "Union Citizens";
		file = "HL_Citizen";
	};
	class HL_ZOM : HL_CIV
	{
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_combine_co.paa);
		name = "Xenian Life";
		file = "HL_Zombie";
	};
/////////// Rival ////////////////
	class HL_RIV : HL_Base
	{
		side = "Riv";
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_combine_co.paa);
		name = "Collaborative Enforcers";
		file = "HL_Rival";
	};
/////////////// Rebel ///////////////
	class HL_REB : HL_Base
	{
		side = "Reb";
		flagTexture = QPATHTOFOLDER(Templates\Templates\HL2\images\flag_rebel_co.paa);
		name = "Forward Resistance";
		file = "HL_Rebel";
		description = "The Forward Resistance. We fight for a free and better Earth. We are the front line of Humanity.";
	};