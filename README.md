# ROBLOX-Audio-Manager

More information at https://devforum.roblox.com/t/open-source-audio-manager/682714

--[[

PROPERTIES:

	AUDIO_MANAGER = require(pathToThisModule)

	<table> AUDIO_MANAGER.BackgroundMusics
	<table> AUDIO_MANAGER.SoundEffects
	<Instance> AUDIO_MANAGER.CurrentBackgroundMusic

METHODS:

	AUDIO_MANAGER = require(pathToThisModule)

	<void> AUDIO_MANAGER:PlayBackgroundMusic(<string> backgroundMusicId)
	<void> AUDIO_MANAGER:StopBackgroundMusic()
	<void> AUDIO_MANAGER:PlaySoundEffect(<string> soundEffectId)
	<void> AUDIO_MANAGER:PlaySoundEffectAtPosition(<string> soundEffectId, <Vector3> position)
	<void> AUDIO_MANAGER:PlaySoundEffectOnInstance(<string> soundEffectId, <Instance> instance)

DOCUMENTATION:

	<table> AUDIO_MANAGER.BackgroundMusics

	> {[<string> BackgroundMusicId] = <Instance> BackgroundMusicSoundInstance, ... }
	> Id is either the name of the sound instance or the value of an optional StringValue
		instance named 'Id' placed inside it 



	<table> AUDIO_MANAGER.SoundEffects

	> {[<string> SoundEffectId] = <Instance> SoundEffectSoundInstance, ... }
	> Id is either the name of the sound instance or the value of an optional StringValue
		instance named 'Id' placed inside it 



	<Instance> AUDIO_MANAGER.CurrentBackgroundMusic

	> The sound instance of currently playing background music
	> If no background music is playing, it is nil



	<void> AUDIO_MANAGER:PlayBackgroundMusic(<string> backgroundMusicId)

	> Plays a new background music using the given id
	> Throws an error if the id does not match any existing assets
	> Stops playing any previously playing background musics



	<void> AUDIO_MANAGER:StopBackgroundMusic()

	> Stops playing any currently playing background musics



	<void> AUDIO_MANAGER:PlaySoundEffect(<string> soundEffectId)

	> Plays a sound effect using the given id
	> Throws an error if the id does not match any existing assets
	> Clones the detected sound asset and parents it to sound service before playing
	> Cleans up all the created instances after the sound is played



	<void> AUDIO_MANAGER:PlaySoundEffectAtPosition(<string> soundEffectId, <Vector3> position)

	> Plays a sound effect at the given position using the given id
	> Throws an error if the id does not match any existing assets
	> Creates an attachment at the given position and parents it to workspace.Terrain
	> Clones the detected sound asset into this attachment before playing
	> Cleans up all the created instances after the sound is played



	<void> AUDIO_MANAGER:PlaySoundEffectOnInstance(<string> soundEffectId, <Instance> instance)

	> Plays a sound effect on the given instance using the given id
	> Throws an error if the id does not match any existing assets
	> Clones the detected sound asset and parents it to the instance
	> Cleans up all the created instances after the sound is played

NOTES:

	> Audio Manager is an easy solution for handling audios inside of the game
	> Do not destroy or change any of the folders inside the audio manager
	> Do not edit anything in the code expect a select few constants
	> Ids can now specify either a group of sounds or a single sound by using the
		following syntax group1/group2/group3/id
	> When a group is specified, a random sound will be played so long as no weights
		are inserted into any of the sounds. Otherwise, a weighted random sound will
		be played

--]]
