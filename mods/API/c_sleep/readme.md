### Sleep [c_sleep]

An API mod for managing sleep.


## About

This is a pure API mod, that by itself doesn't provoide any functionality
besides registering players as sleeping or not sleeping.

It provides a number of functions and callbacks that games can use to implement
the specific sleeping behaviour they desire.


If player dies while they are asleep they are woken up but 'on_sleep_end'
callbacks are NOT called, since there is a high likeyhood that they might displace
the player back to where they were before going to sleep.



## API

c_sleep.sleeping_players = {
	["player_name"] = true,
	...,
}
- table of all currently sleeping players
- do not change directly!, only use for lookup, if necessary


# Functions

c_sleep.can_sleep(player)
- returns boolean, and if 'false' a "reason" as a second argument
- used in fashion of 'core.is_creative_enabled(name)' to determine if a player
can go to sleep

c_sleep.is_sleeping(player)
- 'true' if player is sleeping, otherwise 'nil'
- a quick lookup into the 'c_sleep.sleeping_players' table

c_sleep.start_sleep(player)
- returns 'true' if sucessfull
- returns 'false', "reason" if not sucessfull
- checks whether player 'c_sleep.can_sleep(player)', if so,
calls 'on_sleep_start' and 'on_count_changed' callbacks and
registeres player as sleeping

c_sleep.end_sleep(player)
- unregisters player as asleep and calls 'on_sleep_end' and 'on_count_changed'
callbacks

# convenience funcitons
c_sleep.wake_everyone_up()
- calls 'c_sleep.end_sleep(player)' on all players

c_sleep.toggle_sleep(player)
- calls 'c_sleep.start_sleep(player)' or 'c_sleep.end_sleep(player)' depending
on whether player is awake or asleep


# Callbacks

c_sleep.register_on_sleep_start(function(player))
- called when player sucessfully enters sleep state

c_sleep.register_on_sleep_end(function(player))
- called when player exits sleep state

c_sleep.register_on_count_changed(function(n_sleeping, n_total))
- called when player enters or exits sleep state
- cakked when a player joins or leaves the game
- 'n_sleeping', current number of sleeping players
- 'n_total', total number of players online


## Integration

Although this mod by default doesn't implement any sleeping effects,
it does provide some helper functions to easily set up common behaviours.
These are located in the 'c_sleep.integration' table.

Time parametrers range from 0.0 to 1.0 as used by 'core.set_timeofday(val)'

integration.limit_sleep_time(start_time, end_time)
- limit ability to start sleep to between 'start_time' and 'end_time'

integration.prevent_sleep_while_moving()
- prevent moving players from startin sleep

integration.skip_to_morning(time, player_fraction)
- after 'player_fraction' of online players are asleep set day time to 'time'
- wakes everyone up after

integration.limit_interaction()
- takes away players interact priv while they are asleep
- doesn't work in singleplayer and for admins due to luanti fuckery
- IMPORTANT! give the player a way to wake up without the interact priv,
otherwise they will be trapped

integration.speedup_time(multiplier, player_fraction)
- while 'player_fraction' of players is asleep mutiply time speed by 'multiplier'

integration.show_sleeping_players()
- sleeping players get a HUD showing how many other players are sleeping

integration.sleepers_snore(snore_percenatage)
- 'snore_percenatage' not implemented yet
- converts sleeping players messeges to snoring sounds

integration.force_3rd_person_camera()
- on start of sleep forces player camera to 3rd person

integration.stop_sleeping_on_damage()
- wakes sleeping players up, when they take damage
