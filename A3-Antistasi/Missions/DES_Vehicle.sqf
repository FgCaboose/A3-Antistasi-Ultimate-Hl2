//Mission: Destroy the vehicle
if (!isServer and hasInterface) exitWith{};

private ["_markerX","_positionX","_dateLimit","_dateLimitNum","_nameDest","_typeVehX","_texto","_truckCreated","_size","_pos","_veh","_group","_unit"];

_markerX = _this select 0;

_difficultX = if (random 10 < tierWar) then {true} else {false};
_leave = false;
_contactX = objNull;
_groupContact = grpNull;
_tsk = "";
_positionX = getMarkerPos _markerX;
_lado = if (sidesX getVariable [_markerX,sideUnknown] == Occupants) then {Occupants} else {Invaders};
_timeLimit = if (_difficultX) then {30} else {120};
if (hasIFA) then {_timeLimit = _timeLimit * 2};
_dateLimit = [date select 0, date select 1, date select 2, date select 3, (date select 4) + _timeLimit];
_dateLimitNum = dateToNumber _dateLimit;
_nameDest = [_markerX] call A3A_fnc_localizar;

_typeVehX = if (_lado == Occupants) then {vehNATOAA} else {vehCSATAA};

[[teamPlayer,civilian],"DES",[format ["We know an enemy armor (%4) is stationed in %1. It is a good chance to destroy or steal it before it causes more damage. Do it before %2:%3.",_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,getText (configFile >> "CfgVehicles" >> (_typeVehX) >> "displayName")],"Steal or Destroy Armor",_markerX],_positionX,false,0,true,"Destroy",true] call BIS_fnc_taskCreate;
_truckCreated = false;
missionsX pushBack ["DES","CREATED"]; publicVariable "missionsX";

waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (spawner getVariable _markerX == 0)};
_bonus = if (_difficultX) then {2} else {1};
if (spawner getVariable _markerX == 0) then
	{
	_truckCreated = true;
	_size = [_markerX] call A3A_fnc_sizeMarker;
	_pos = [];
	if (_size > 40) then {_pos = [_positionX, 10, _size, 10, 0, 0.3, 0] call BIS_Fnc_findSafePos} else {_pos = _positionX findEmptyPosition [10,60,_typeVehX]};
	_veh = createVehicle [_typeVehX, _pos, [], 0, "NONE"];
	_veh allowdamage false;
	_veh setDir random 360;
	[_veh] call A3A_fnc_AIVEHinit;

	_group = createGroup _lado;

	sleep 5;
	_veh allowDamage true;
	_tipo = if (_lado == Occupants) then {NATOCrew} else {CSATCrew};
	for "_i" from 1 to 3 do
		{
		_unit = _group createUnit [_tipo, _pos, [], 0, "NONE"];
		[_unit,""] call A3A_fnc_NATOinit;
		sleep 2;
		};

	if (_difficultX) then
		{
		_group addVehicle _veh;
		}
	else
		{
		waitUntil {sleep 1;({leader _group knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _group,teamPlayer] call A3A_fnc_distanceUnits) > 0) or (dateToNumber date > _dateLimitNum) or (not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)};

		if ({leader _group knowsAbout _x > 1.4} count ([distanceSPWN,0,leader _group,teamPlayer] call A3A_fnc_distanceUnits) > 0) then {_group addVehicle _veh;};
		};

	waitUntil {sleep 1;(dateToNumber date > _dateLimitNum) or (not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)};

	if ((not alive _veh) or ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0)) then
		{
		["DES",[format ["We know an enemy armor (%4) is stationed in a %1. It is a good chance to steal or destroy it before it causes more damage. Do it before %2:%3.",_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,getText (configFile >> "CfgVehicles" >> (_typeVehX) >> "displayName")],"Steal or Destroy Armor",_markerX],_positionX,"SUCCEEDED","Destroy"] call A3A_fnc_taskUpdate;
		if ({(_x getVariable ["spawner",false]) and (side group _x == teamPlayer)} count crew _veh > 0) then
			{
			["TaskFailed", ["", format ["AA Stolen in %1",_nameDest]]] remoteExec ["BIS_fnc_showNotification",_lado];
			};
		[0,300*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
		if (_lado == Invaders) then {[0,3] remoteExec ["A3A_fnc_prestige",2]; [0,10*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]} else {[3,0] remoteExec ["A3A_fnc_prestige",2];[0,5*_bonus,_positionX] remoteExec ["A3A_fnc_citySupportChange",2]};
		[1200*_bonus] remoteExec ["A3A_fnc_timingCA",2];
		{if (_x distance _veh < 500) then {[10*_bonus,_x] call A3A_fnc_playerScoreAdd}} forEach (allPlayers - (entities "HeadlessClient_F"));
		[5*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
		};
	}
else
	{
	["DES",[format ["We know an enemy armor (%4) is stationed in a %1. It is a good chance to steal or destroy it before it causes more damage. Do it before %2:%3.",_nameDest,numberToDate [2035,_dateLimitNum] select 3,numberToDate [2035,_dateLimitNum] select 4,getText (configFile >> "CfgVehicles" >> (_typeVehX) >> "displayName")],"Steal or Destroy Armor",_markerX],_positionX,"FAILED","Destroy"] call A3A_fnc_taskUpdate;
	[-5*_bonus,-100*_bonus] remoteExec ["A3A_fnc_resourcesFIA",2];
	[5*_bonus,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	[-600*_bonus] remoteExec ["A3A_fnc_timingCA",2];
	[-10*_bonus,theBoss] call A3A_fnc_playerScoreAdd;
	};

_nul = [1200,"DES"] spawn A3A_fnc_deleteTask;

waitUntil {sleep 1; (spawner getVariable _markerX == 2)};

if (_truckCreated) then
	{
	{deleteVehicle _x} forEach units _group;
	deleteGroup _group;
	if (!([distanceSPWN,1,_veh,teamPlayer] call A3A_fnc_distanceUnits)) then {deleteVehicle _veh};
	};
