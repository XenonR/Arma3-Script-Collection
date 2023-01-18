/*
	Script:  Mortar
	Version: 1.1
	Web:     https://ndf-clan.com
	Mail:    xenonr@ndf-clan.com

	Place Trigger with onActivation:
		center_point, radius, bomabrdments, bomb/bombardment, smoke shell, bombardment delay, smoke length
			// Defaults are:
			// around game_logic; in a 100m radius; fire 1 time; 4 shells; non smoke; 6s pause in between, smoke length 180s
			_s = [game_logic] execVM "script\mortar.sqf";
*/

_center_name = param [ 0, objNull];

if (isServer && !isNull _center_name ) then {
	_radius = 				param [ 1, 100];
	_bombing_runs = 		param [ 2, 1];
	_bombs_per_run = 		param [ 3, 4];
	_use_smoke = 			param [ 4, false];
	_time_between_runs = 	param [ 5, 6];
	_smoke_length = 		param [ 6, 180];

	_center_position = getPos _center_name;
	// systemChat format["[%1] Position: %2", _center_name, _center_position];

	private ["_shell"];
	if (_use_smoke) then {
		_shell = "SmokeShell_Infinite";
	} else {
		_shell = "M_Mo_82mm_AT";
	};

	for "_bombing_run" from 1 to _bombing_runs do {
		[_center_position, _radius, _bombing_run, _bombing_runs, _bombs_per_run, _shell, _center_name, _use_smoke, _smoke_length] spawn {
			// ### call arguments to variables
			params ["_center_position","_radius","_bombing_run","_bombing_runs","_bombs_per_run","_shell","_center_name","_use_smoke","_smoke_length"];

			for "_bomb" from 1 to _bombs_per_run do {
				sleep random(1.5);
				// systemChat format["[%1] Run #%2/%3 Shell %4/%5: %6", _center_name, _bombing_run, _bombing_runs, _bomb, _bombs_per_run, _shell_position];

				_shell_position = [[[ _center_position, _radius]], ["water", "out"]] call BIS_fnc_randomPos;
				_audio_position = [_shell_position select 0, _shell_position select 1, _shell_position select 2];
				_audio_position set [2, (_audio_position select 2)+15];

				playSound3D ["a3\sounds_f\weapons\falling_bomb\fall_01.wss", _audio_position, false, _audio_position];
				playSound3D ["a3\sounds_f\weapons\falling_bomb\fall_02.wss", _audio_position, false, _audio_position];
				playSound3D ["a3\sounds_f\weapons\falling_bomb\fall_03.wss", _audio_position, false, _audio_position];
				playSound3D ["a3\sounds_f\weapons\falling_bomb\fall_04.wss", _audio_position, false, _audio_position];
				sleep 5;

				_explosion = createVehicle [ _shell, _shell_position, [], 0, "NONE"];
				hideObject _explosion;

				if (_use_smoke) then {
					// Play impact sound
					playSound3D ["A3\Sounds_F\arsenal\explosives\grenades\Explosion_HE_grenade_01.wss", _shell_position, false, _shell_position, 1, 2];

					// ### Delay deletion to allow smoke to propagate
					[_explosion, _smoke_length] spawn {
						params ["_explosion","_smoke_length"];
						// ### Smoke is emmited for _smoke_length seconds
						sleep _smoke_length;
						deleteVehicle _explosion;
					};
				} else {
					sleep 1;
					deleteVehicle _explosion;
				};

			};
		};

		sleep _time_between_runs+6+random(3);
	};
};
