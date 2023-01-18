/*
	Script:  Battle Sounds
	Version: 2.1
	Web:     https://ndf-clan.com
	Mail:    xenonr@ndf-clan.com

	Place Game Logic with Init:
		this, radius around logic position, explosions, extra_delay, minimum_player_distance
			// Defaults are:
			// In a 500m radius; with explosions; no extra delay between fights; with a mimimum player distance of 100m
			_s = [this] execVM "script\battle_sounds.sqf";

			// In a 500m radius; with explosions; an extra delay of 10s between fights; with a mimimum player distance of 100m
			_s = [this,500,true,10,100] execVM "script\battle_sounds.sqf"
			// In a 500m radius; with explosions; an extra delay of 10s between fights
			_s = [this,500,true,10] execVM "script\battle_sounds.sqf"
			// In a 500m radius; with explosions
			_s = [this,500,true] execVM "script\battle_sounds.sqf";
			// In a 500m radius
			_s = [this,500] execVM "script\battle_sounds.sqf";
*/

_source = param [ 0, objNull];

// ### only execute for players
if (!isDedicated && hasInterface && !isNull _source) then {
	// ### waitUntil for valid player
	waitUntil {!isNull player};

	// ### call arguments to variables
	_radius =					param [ 1, 500];
	_explosions =				param [ 2, true];
	_extra_delay =				param [ 3, 0];
	_minimum_player_distance =	param [ 4, 100];

	while {true} do {
		// ### create 1-4 fighting positions at once
		_fighting_location_count = 1 + Ceil (random 2);

		for "_fighting_location" from 1 to _fighting_location_count do {



			[_source, _radius, _fighting_location, _explosions, _minimum_player_distance] spawn {
				// ### call arguments to variables
				params ["_source","_radius","_fighting_location","_explosions","_minimum_player_distance"];

				// ### copy _source to new temporary logic object with same location
				_center = createCenter sideLogic;
				_group = createGroup _center;
				_audio_position_logic = _group createUnit ["LOGIC",(getPos _source) , [], 0, ""];

				// ### initial wait before fight, random time to misalign multiple sources at start
				sleep (1 + random 7);

				// ### how long should the fight be in loops
				for "_fight_length" from 1 to (random 7) do {
					// ### Defaults
					_allsounds = [];

					// ### relative sound position from _fighting_location
					_new_relative_position = [
						random (_radius*2) - random _radius,
						random (_radius*2) - random _radius,
						random 3
					];

					// systemChat format["[%2] Rel. Audio Pos. (%3) %1", _new_relative_position, _source, _radius];
					// systemChat format["[%2] Cur. Audio Pos. %1", getPos _audio_position_logic, _source];

					// ### set to new position
					_audio_position_logic setPos (_audio_position_logic modelToWorld _new_relative_position);

					// systemChat format["[%2] New Audio Pos. %1", getPos _audio_position_logic, _source];

					// ### pick random sound assets
					_sound1 = format ["A3\Sounds_F\ambient\battlefield\battlefield_firefight%1.wss",floor (random 5)];
					// ### allow firefight
					_allsounds pushBack _sound1;

					if (_explosions) then {
						// ### if no water at _audio_position_logic
						if ( !(surfaceIsWater getPos _audio_position_logic) ) then {
							_sound2 = format ["A3\Sounds_F\ambient\battlefield\battlefield_explosions%1.wss",floor (random 6)];
							// ### allow explosions
							_allsounds pushBack _sound2;
						};
					};

					// ### if player distance > _minimum_player_distance play; otherwise not
					if (_audio_position_logic distance player >= _minimum_player_distance) then {
						// ### set sensible volumes according to distance from player
						// ### lower volume as closer, so it always appears to be in the distance
						_volume = switch (true) do {
							case (_audio_position_logic distance player <= 250) : {.1};
							case (_audio_position_logic distance player > 250 and _audio_position_logic distance player <= 500) : {.5};
							case (_audio_position_logic distance player > 500 and _audio_position_logic distance player <= 800) : {1};
							case (_audio_position_logic distance player > 800 and _audio_position_logic distance player <= 1000) : {1.5};
							case (_audio_position_logic distance player > 1000) : {2};
						};

						// ### only play one picked sound
						_maxtype = (count _allsounds);
						_sound = _allsounds select (floor random _maxtype);

						// ### setup pitch
						_pitch = if (_sound == _sound1) then {random .5 + .5} else {random .6 + .8};

						// ### final volume setup; randomize a little
						_final_volume = if (_sound == _sound1) then {_volume + 1 + random 3} else {_volume + .1 + random 2};

						// systemChat format["(%2) Play @ %1", getPosASL _audio_position_logic, player];

						// ### FINALLY, play the damn thing
						playsound3d [_sound, _audio_position_logic, false, getPosASL _audio_position_logic, _final_volume, _pitch];

					}; // if (_audio_position_logic distance player >= _minimum_player_distance)

					// ### pause for the "enemy" to respond
					sleep (random 20 + random 10);

				}; // for "_fight_length"

				// ### Cleanup
				deleteVehicle _audio_position_logic;

			}; // spawn



		}; // for "_fighting_location"

		// ### waittime between creation of new fighting locations
		sleep (random 20 + random 20 + _extra_delay);
	}; // while {true}
}; // if (!isDedicated && hasInterface)