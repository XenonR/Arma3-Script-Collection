/*
	Script:  Supress
	Version: 1.1
	Web:     https://ndf-clan.com
	Mail:    xenonr@ndf-clan.com

	Place Trigger with onActivation:
		unit_name, bursts, bullets/burst, target
			// Defaults are:
			// Fire 6 bursts with 10 bullets/burst with no target (viewing direction)
			_s = [firing_unit] execVM "script\supress.sqf";

			// Fire 2 bursts with 30 bullets/burst at target_object
			_s = [firing_unit, 2, 30, target_object] execVM "script\supress.sqf";
			// Fire 2 bursts with 30 bullets/burst in viewing direction
			_s = [firing_unit, 2, 30] execVM "script\supress.sqf";
*/

_unit = param [ 0, objNull];

if (isServer && !isNull _unit ) then {
	_bursts = param [ 1, 6];
	_rounds = param [ 2, 10];
	_target = param [ 3, objNull];

	private["_is_vehicle","_weapon","_reloading"];

	_is_vehicle = !(isNull objectParent _unit);
	if ( _is_vehicle ) then {
		_weapon = currentMuzzle (gunner (vehicle _unit));
	} else {
		_weapon = currentMuzzle _unit;
	};

	_delay = (configfile >> "CfgWeapons" >> _weapon >> "reloadTime") call BIS_fnc_getCfgData;

	for "_b" from 1 to _bursts step 1 do {
		// systemChat format["[%3] Burst: %1/%2", _b, _bursts, _unit];

		if !(isNull _target) then {
			_unit doWatch _target;
			sleep 1;
		};
		
		if !(_is_vehicle) then {
			// ### Raise weapon
			_unit setBehaviour "COMBAT";
			sleep 1;
		};

		for "_round" from 1 to _rounds step 1 do {
			// ### Check if currently reloading
			if ( _is_vehicle ) then {
				_reloading = weaponState [vehicle _unit, [0]] select 6;
			} else {
				_reloading = weaponState _unit select 6;
			};

			while { _reloading > 0 } do {
				// systemChat format["[%1] Reloading: %2%3", _unit, ceil ((1-_reloading)*100), "%" ];
				sleep 1;
				if ( _is_vehicle ) then {
					_reloading = weaponState [vehicle _unit, [0]] select 6;
				} else {
					_reloading = weaponState _unit select 6;
				};
			};

			_unit forceWeaponFire [currentMuzzle (gunner (vehicle _unit)), currentWeaponMode gunner vehicle _unit];
			sleep _delay+(random(11)/10);
		};

		sleep 2+random(11);
	};
};