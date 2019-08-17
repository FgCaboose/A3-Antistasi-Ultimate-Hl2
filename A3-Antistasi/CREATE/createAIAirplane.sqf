if (!isServer and hasInterface) exitWith{};

private ["_pos","_markerX","_vehiclesX","_groups","_soldiers","_positionX","_busy","_buildings","_pos1","_pos2","_groupX","_countX","_typeVehX","_veh","_unit","_arrayVehAAF","_nVeh","_frontierX","_size","_ang","_mrk","_typeGroup","_flagX","_dog","_typeUnit","_garrison","_sideX","_cfg","_max","_vehicle","_vehCrew","_groupVeh","_roads","_dist","_road","_roadscon","_roadcon","_dirveh","_bunker","_typeGroup","_positionsX","_posMG","_posMort","_posTank"];
_markerX = _this select 0;

diag_log format ["[Antistasi] Spawning Airbase %1 (createAIAirplane.sqf)", _markerX];

_vehiclesX = [];
_groups = [];
_soldiers = [];

_positionX = getMarkerPos (_markerX);
_pos = [];

_size = [_markerX] call A3A_fnc_sizeMarker;
//_garrison = garrison getVariable _markerX;

_frontierX = [_markerX] call A3A_fnc_isFrontline;
_busy = if (dateToNumber date > server getVariable _markerX) then {false} else {true};
_nVeh = round (_size/60);

_sideX = sidesX getVariable [_markerX,sideUnknown];

_positionsX = roadsX getVariable [_markerX,[]];
_posMG = _positionsX select {(_x select 2) == "MG"};
_posMort = _positionsX select {(_x select 2) == "Mort"};
_posTank = _positionsX select {(_x select 2) == "Tank"};
_posAA = _positionsX select {(_x select 2) == "AA"};
_posAT = _positionsX select {(_x select 2) == "AT"};

if (spawner getVariable _markerX != 2) then
	{
	_typeVehX = if (_sideX == Occupants) then {vehNATOAA} else {vehCSATAA};
	if ([_typeVehX] call A3A_fnc_vehAvailable) then
		{
		_max = if (_sideX == Occupants) then {1} else {2};
		for "_i" from 1 to _max do
			{
			_pos = [_positionX, 50, _size, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
			//_pos = _positionX findEmptyPosition [_size - 200,_size+50,_typeVehX];
			_vehicle=[_pos, random 360,_typeVehX, _sideX] call bis_fnc_spawnvehicle;
			_veh = _vehicle select 0;
			_vehCrew = _vehicle select 1;
			{[_x,_markerX] call A3A_fnc_NATOinit} forEach _vehCrew;
			[_veh] call A3A_fnc_AIVEHinit;
			_groupVeh = _vehicle select 2;
			_soldiers = _soldiers + _vehCrew;
			_groups pushBack _groupVeh;
			_vehiclesX pushBack _veh;
			sleep 1;
			};
		};
	};

if ((spawner getVariable _markerX != 2) and _frontierX) then
	{
	_roads = _positionX nearRoads _size;
	if (count _roads != 0) then
		{
		_groupX = createGroup _sideX;
		_groups pushBack _groupX;
		_dist = 0;
		_road = objNull;
		{if ((position _x) distance _positionX > _dist) then {_road = _x;_dist = position _x distance _positionX}} forEach _roads;
		_roadscon = roadsConnectedto _road;
		_roadcon = objNull;
		{if ((position _x) distance _positionX > _dist) then {_roadcon = _x}} forEach _roadscon;
		_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
		_pos = [getPos _road, 7, _dirveh + 270] call BIS_Fnc_relPos;
		_bunker = "Land_BagBunker_01_small_green_F" createVehicle _pos;
		_vehiclesX pushBack _bunker;
		_bunker setDir _dirveh;
		_pos = getPosATL _bunker;
		_typeVehX = if (_sideX==Occupants) then {staticATOccupants} else {staticATInvaders};
		_veh = _typeVehX createVehicle _positionX;
		_vehiclesX pushBack _veh;
		_veh setDir _dirVeh + 180;
		_veh setPos _pos;
		_typeUnit = if (_sideX==Occupants) then {staticCrewOccupants} else {staticCrewInvaders};
		_unit = _groupX createUnit [_typeUnit, _positionX, [], 0, "NONE"];
		[_unit,_markerX] call A3A_fnc_NATOinit;
		[_veh] call A3A_fnc_AIVEHinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		};
	};
_mrk = createMarkerLocal [format ["%1patrolarea", random 100], _positionX];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanceSPWN/2),(distanceSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_ang = markerDir _markerX;
_mrk setMarkerDirLocal _ang;
if (!debug) then {_mrk setMarkerAlphaLocal 0};
_garrison = garrison getVariable [_markerX,[]];
_garrison = _garrison call A3A_fnc_garrisonReorg;
_radiusX = count _garrison;
private _patrol = true;
if (_radiusX < ([_markerX] call A3A_fnc_garrisonSize)) then
	{
	_patrol = false;
	}
else
	{
	if ({if ((getMarkerPos _x inArea _mrk) and (sidesX getVariable [_x,sideUnknown] != _sideX)) exitWIth {1}} count markersX > 0) then {_patrol = false};
	};
if (_patrol) then
	{
	_countX = 0;
	while {(spawner getVariable _markerX != 2) and (_countX < 4)} do
		{
		_arraygroups = if (_sideX == Occupants) then {groupsNATOsmall} else {groupsCSATsmall};
		if ([_markerX,false] call A3A_fnc_fogCheck < 0.3) then {_arraygroups = _arraygroups - sniperGroups};
		_typeGroup = selectRandom _arraygroups;
		_groupX = [_positionX,_sideX, _typeGroup,false,true] call A3A_fnc_spawnGroup;
		if !(isNull _groupX) then
			{
			sleep 1;
			if ((random 10 < 2.5) and (not(_typeGroup in sniperGroups))) then
				{
				_dog = _groupX createUnit ["Fin_random_F",_positionX,[],0,"FORM"];
				[_dog] spawn A3A_fnc_guardDog;
				sleep 1;
				};
			_nul = [leader _groupX, _mrk, "SAFE","SPAWNED", "RANDOM", "NOVEH2"] execVM "scripts\UPSMON.sqf";
			_groups pushBack _groupX;
			{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
			};
		_countX = _countX +1;
		};
	};
_countX = 0;

_groupX = createGroup _sideX;
_groups pushBack _groupX;
_typeUnit = if (_sideX==Occupants) then {staticCrewOccupants} else {staticCrewInvaders};
_typeVehX = if (_sideX == Occupants) then {NATOMortar} else {CSATMortar};
{
if (spawner getVariable _markerX != 2) then
	{
	_veh = _typeVehX createVehicle [0,0,1000];
	_veh setDir (_x select 1);
	_veh setPosATL (_x select 0);
	_nul=[_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";
	_unit = _groupX createUnit [_typeUnit, _positionX, [], 0, "NONE"];
	[_unit,_markerX] call A3A_fnc_NATOinit;
	_unit moveInGunner _veh;
	_soldiers pushBack _unit;
	_vehiclesX pushBack _veh;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	sleep 1;
	};
} forEach _posMort;
_typeVehX = if (_sideX == Occupants) then {NATOMG} else {CSATMG};
{
if (spawner getVariable _markerX != 2) then
	{
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _typeVehX createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _groupX createUnit [_typeUnit, _positionX, [], 0, "NONE"];
		[_unit,_markerX] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehiclesX pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posMG;
_typeVehX = if (_sideX == Occupants) then {staticAAOccupants} else {staticAAInvaders};
{
if (spawner getVariable _markerX != 2) then
	{
	if !([_typeVehX] call A3A_fnc_vehAvailable) exitWith {};
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _typeVehX createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _groupX createUnit [_typeUnit, _positionX, [], 0, "NONE"];
		[_unit,_markerX] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehiclesX pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posAA;
_typeVehX = if (_sideX == Occupants) then {staticATOccupants} else {staticATInvaders};
{
if (spawner getVariable _markerX != 2) then
	{
	if !([_typeVehX] call A3A_fnc_vehAvailable) exitWith {};
	_proceed = true;
	if ((_x select 0) select 2 > 0.5) then
		{
		_bld = nearestBuilding (_x select 0);
		if !(alive _bld) then {_proceed = false};
		};
	if (_proceed) then
		{
		_veh = _typeVehX createVehicle [0,0,1000];
		_veh setDir (_x select 1);
		_veh setPosATL (_x select 0);
		_unit = _groupX createUnit [_typeUnit, _positionX, [], 0, "NONE"];
		[_unit,_markerX] call A3A_fnc_NATOinit;
		_unit moveInGunner _veh;
		_soldiers pushBack _unit;
		_vehiclesX pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		sleep 1;
		};
	};
} forEach _posAT;

_ret = [_markerX,_size,_sideX,_frontierX] call A3A_fnc_milBuildings;
_groups pushBack (_ret select 0);
_vehiclesX append (_ret select 1);
_soldiers append (_ret select 2);

private _fnc_runwayInfo = {
	private _mainRunway = configFile >> "CfgWorlds" >> worldName;
	private _otherRunways = "true" configClasses (_mainRunway >> "SecondaryAirports");
	
	[_mainRunway] + _otherRunways;
};

if (!_busy) then
	{
	private _runways = [] call _fnc_runwayInfo;
	private _runwayIlsPositions = _runways apply {getArray (_x >> "ilsPosition")};
	private _runwaySpawnLocation = [];
	private _taxiNumberArr = [];
	
	{
		if (_positionX distance _x < 700) exitWith {
			//Array of position, and extract compass direction of runway.
			_runwaySpawnLocation = [_x, acos (getArray ((_runways select _foreachindex) >> "ilsDirection") select 2) + 180];
			_taxiNumberArr = getArray ((_runways select _foreachindex) >> "ilsTaxiIn") + getArray ((_runways select _foreachindex) >> "ilsTaxiOut");
		};
	} forEach _runwayIlsPositions;
	
	private _taxiwaySpawnLocations = [];
	
	//Taxi locations is just an array of numbers. We need to pair them up.
	{ 
		if ((_forEachIndex % 2) == 0) then { 
			_taxiwaySpawnLocations pushBack [_x];
		} else { 
			(_taxiwaySpawnLocations select (count _taxiwaySpawnLocations - 1)) pushBack _x 
		}
	} forEach _taxiNumberArr;

	//If we've found a nearby runway, we can continue.
	if !(_runwaySpawnLocation isEqualTo []) then
		{
		_pos = _runwaySpawnLocation select 0;
		_ang = _runwaySpawnLocation select 1;
		 
		_groupX = createGroup _sideX;
		_groups pushBack _groupX;
		_countX = 0;
		_taxiwayPosSelection = 0;
		
		while {(_countX < 5)} do
			{
			_typeVehX = if (_sideX == Occupants) then {selectRandom (vehNATOAir select {[_x] call A3A_fnc_vehAvailable})} else {selectRandom (vehCSATAir select {[_x] call A3A_fnc_vehAvailable})};
			
			private _forceTaxiwaySpawn = false;
			if (_typeVehX isKindOf "Helicopter") then {
				private _shouldExit = false;
				scopeName "HelicopterSpawn";
				while {!_shouldExit && _taxiwayPosSelection < (count _taxiwaySpawnLocations)} do {
					private _currentPosition = _taxiwaySpawnLocations select _taxiwayPosSelection;
					private _oldPosition = if (_taxiwayPosSelection == 0) then {[0,0,0]} else {_taxiwaySpawnLocations select (_taxiwayPosSelection - 1)};
					if (_currentPosition distance _oldPosition < 30 || _currentPosition distance (_runwaySpawnLocation select 0) < 30) then {
						_taxiwayPosSelection = _taxiwayPosSelection + 1;
					} else {
						breakTo "HelicopterSpawn";
					};
				};
				if (_taxiwayPosSelection < (count _taxiwaySpawnLocations)) then {
					_forceTaxiwaySpawn = true;
				};
			};
			
			private _veh = objNull;
			if (_forceTaxiwaySpawn) then {
				_veh = createVehicle [_typeVehX, _taxiwaySpawnLocations select _taxiwayPosSelection, [],3, "NONE"];
				_taxiwayPosSelection = _taxiwayPosSelection + 1;
			} else {
				_veh = createVehicle [_typeVehX, _pos, [],3, "NONE"];
				_veh setDir (_ang);
				_pos = [_pos, 50,_ang] call BIS_fnc_relPos;
			};
			
			_vehiclesX pushBack _veh;
			_nul = [_veh] call A3A_fnc_AIVEHinit;
			_countX = _countX + 1;
			};
		_nul = [leader _groupX, _markerX, "SAFE","SPAWNED","NOFOLLOW","NOVEH"] execVM "scripts\UPSMON.sqf";
		};
	};

_typeVehX = if (_sideX == Occupants) then {NATOFlag} else {CSATFlag};
_flagX = createVehicle [_typeVehX, _positionX, [],0, "CAN_COLLIDE"];
_flagX allowDamage false;
[_flagX,"take"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_flagX];
_vehiclesX pushBack _flagX;
if (_sideX == Occupants) then
	{
	_veh = NATOAmmoBox createVehicle _positionX;
	_nul = [_veh] call A3A_fnc_NATOcrate;
	_vehiclesX pushBack _veh;
	_veh call jn_fnc_logistics_addAction;
	}
else
	{
	_veh = CSATAmmoBox createVehicle _positionX;
	_nul = [_veh] call A3A_fnc_CSATcrate;
	_vehiclesX pushBack _veh;
	_veh call jn_fnc_logistics_addAction;
	};

if (!_busy) then
	{
	{
	_arrayVehAAF = if (_sideX == Occupants) then {vehNATOAttack select {[_x] call A3A_fnc_vehAvailable}} else {vehCSATAttack select {[_x] call A3A_fnc_vehAvailable}};
	if ((spawner getVariable _markerX != 2) and (count _arrayVehAAF > 0)) then
		{
		_veh = createVehicle [selectRandom _arrayVehAAF, (_x select 0), [], 0, "NONE"];
		_veh setDir (_x select 1);
		_vehiclesX pushBack _veh;
		_nul = [_veh] call A3A_fnc_AIVEHinit;
		_nVeh = _nVeh -1;
		sleep 1;
		};
	} forEach _posTank;
	};
_arrayVehAAF = if (_sideX == Occupants) then {vehNATONormal} else {vehCSATNormal};

_countX = 0;
while {(spawner getVariable _markerX != 2) and (_countX < _nVeh)} do
	{
	_typeVehX = selectRandom _arrayVehAAF;
	_pos = [_positionX, 10, _size/2, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos;
	_veh = createVehicle [_typeVehX, _pos, [], 0, "NONE"];
	_veh setDir random 360;
	_vehiclesX pushBack _veh;
	_nul = [_veh] call A3A_fnc_AIVEHinit;
	sleep 1;
	_countX = _countX + 1;
	};

_array = [];
_subArray = [];
_countX = 0;
_radiusX = _radiusX -1;
while {_countX <= _radiusX} do
	{
	_array pushBack (_garrison select [_countX,7]);
	_countX = _countX + 8;
	};
for "_i" from 0 to (count _array - 1) do
	{
	_groupX = if (_i == 0) then {[_positionX,_sideX, (_array select _i),true,false] call A3A_fnc_spawnGroup} else {[_positionX,_sideX, (_array select _i),false,true] call A3A_fnc_spawnGroup};
	_groups pushBack _groupX;
	{[_x,_markerX] call A3A_fnc_NATOinit; _soldiers pushBack _x} forEach units _groupX;
	if (_i == 0) then {_nul = [leader _groupX, _markerX, "SAFE", "RANDOMUP","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"} else {_nul = [leader _groupX, _markerX, "SAFE","SPAWNED", "RANDOM","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"};
	};

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

deleteMarker _mrk;
{if (alive _x) then
	{
	deleteVehicle _x
	};
} forEach _soldiers;
//if (!isNull _periodista) then {deleteVehicle _periodista};
{deleteGroup _x} forEach _groups;
{
if (!(_x in staticsToSave)) then
	{
	if ((!([distanceSPWN-_size,1,_x,teamPlayer] call A3A_fnc_distanceUnits))) then {deleteVehicle _x}
	};
} forEach _vehiclesX;


