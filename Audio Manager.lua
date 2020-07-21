local CLASS = {}

--// SERVICES //--

local DEBRIS_SERVICE = game:GetService("Debris")
local SOUND_SERVICE = game:GetService("SoundService")
local TWEEN_SERVICE = game:GetService("TweenService")

--// CONSTANTS //--

local LOADING_TIMEOUT = 10
local LOADING_INTERVAL = 1

local BACKGROUND_MUSIC_FADE_INTERVAL = 5

local AUDIO_ASSETS_FOLDER = script:WaitForChild("Audio Assets")
local BACKGROUND_MUSICS_FOLDER = AUDIO_ASSETS_FOLDER:WaitForChild("Background Musics")
local SOUND_EFFECTS_FOLDER = AUDIO_ASSETS_FOLDER:WaitForChild("Sound Effects")

local WORKSPACE_ASSET_FOLDER = Instance.new("Folder", workspace)
WORKSPACE_ASSET_FOLDER.Name = "Audio Manager Assets"
local SOUND_SERVICE_ASSET_FOLDER = Instance.new("Folder", SOUND_SERVICE)
SOUND_SERVICE_ASSET_FOLDER.Name = "Audio Manager Assets"

--// VARIABLES //--



--// CONSTRUCTOR //--

function CLASS.New()
	local dataTable = setmetatable(
		{
			BackgroundMusics = {},
			SoundEffects = {},
			CurrentBackgroundMusic = nil
		},
		CLASS
	)
	local proxyTable = setmetatable(
		{
			
		},
		{
			__index = function(self, index)
				return dataTable[index]
			end,
			__newindex = function(self, index, newValue)
				dataTable[index] = newValue
			end
		}
	)
	
	proxyTable:Initialize()
	
	return proxyTable
end

--// FUNCTIONS //--

local function ConvertDictionaryToTableByValues(dictionary)
	local valuesTable = {}
	for _, value in pairs(dictionary) do
		table.insert(valuesTable, value)
	end
	return valuesTable
end

--// METHODS //--

function CLASS:GetSoundWeight(sound)
	return (sound:FindFirstChild("Weight") ~= nil and sound.Weight:IsA("NumberValue")) and (sound.Weight.Value) or (1)
end

function CLASS:GetSoundName(sound)
	 return (sound:FindFirstChild("Id") ~= nil and sound.Id:IsA("StringValue") and sound.Id.Value ~= "") and (sound.Id.Value) or (sound.Name)
end

function CLASS:ValidateSoundId(soundId)
	if (soundId == nil) then
		error("Audio Manager Loading Sounds Error: Malformed sound id")
	end
end

function CLASS:LoadWithPredicate(predicate, errorMessage)
	local timeStamp = tick()
	while (predicate() == false) do
		if (tick() - timeStamp > LOADING_TIMEOUT) then
			error("Audio Manager Loading Sounds Timeout: " .. errorMessage, 0)
		end
		wait(LOADING_INTERVAL)
	end
end

function CLASS:LoadSound(soundInstance)
	self:LoadWithPredicate(
		function()
			return soundInstance.TimeLength > 0
		end,
		"Please make sure no sound is of length 0 or increase loading timeout"
	)
end

function CLASS:LoadSoundsIntoDictionary(soundsFolder)
	local soundsDictionary = {}
	for _, child in pairs(soundsFolder:GetChildren()) do
		if (child:IsA("Sound")) then
			self:ValidateSoundId(child.SoundId)
			self:LoadSound(child)
			soundsDictionary[self:GetSoundName(child)] = child
		elseif (child:IsA("Folder")) then
			soundsDictionary[child.Name] = self:LoadSoundsIntoDictionary(child)
		end
	end
	return soundsDictionary
end

function CLASS:LoadBackgroundMusics()
	self.BackgroundMusics = self:LoadSoundsIntoDictionary(BACKGROUND_MUSICS_FOLDER)
end

function CLASS:LoadSoundEffects()
	self.SoundEffects = self:LoadSoundsIntoDictionary(SOUND_EFFECTS_FOLDER)
end

function CLASS:Initialize()
	self:LoadBackgroundMusics()
	self:LoadSoundEffects()
end

function CLASS:GetAudioAssetFromGroup(group)
	local sumOfWeights = 0
	for _, sound in pairs(group) do
		local weight = self:GetSoundWeight(sound)
		sumOfWeights = sumOfWeights + weight
	end
	local randomNumber = Random.new():NextNumber(0, sumOfWeights)
	for _, sound in pairs(group) do
		local weight = self:GetSoundWeight(sound)
		if (randomNumber < weight) then return sound end
		randomNumber = randomNumber - weight
	end
end

function CLASS:GetAudioAssetFromId(Id, assetDictionary)
	for match in string.gmatch(Id, "/?([^/]+)/?") do
		assetDictionary = assetDictionary[match]
		if (assetDictionary == nil) then
			error("Audio Manager Asset Error: '" .. Id .. "' is not a valid audio asset id", 3)
		end
	end
	local asset = assetDictionary
	if (typeof(asset) == "table") then
		if (next(asset) == nil) then
			error("Audio Manager Asset Error: '" .. Id .. "' is an empty group", 3)
		else
			asset = self:GetAudioAssetFromGroup(asset)
		end
	end
	return asset
end

function CLASS:PlayBackgroundMusic(backgroundMusicId)
	local sound = self:GetAudioAssetFromId(backgroundMusicId, self.BackgroundMusics)
	if (self.CurrentBackgroundMusic ~= nil) then
		local currentBackgroundMusicId = self:GetSoundName(self.CurrentBackgroundMusic)
		if (currentBackgroundMusicId == backgroundMusicId) then
			return
		else
			self:StopBackgroundMusic()
		end
	end
	
	local soundClone = sound:Clone()
	soundClone.Volume = 0
	soundClone.Looped = true
	soundClone.Parent = SOUND_SERVICE_ASSET_FOLDER
	soundClone:Play()
	TWEEN_SERVICE:Create(soundClone, TweenInfo.new(BACKGROUND_MUSIC_FADE_INTERVAL), {Volume = sound.Volume}):Play()
	self.CurrentBackgroundMusic = soundClone
end

function CLASS:StopBackgroundMusic()
	if (self.CurrentBackgroundMusic == nil) then
		warn("Audio Manager Invalid Action Warning: Attempt to stop background music without playing one before")
	else
		DEBRIS_SERVICE:AddItem(self.CurrentBackgroundMusic, BACKGROUND_MUSIC_FADE_INTERVAL/2)
		TWEEN_SERVICE:Create(self.CurrentBackgroundMusic, TweenInfo.new(BACKGROUND_MUSIC_FADE_INTERVAL/2), {Volume = 0}):Play()
		self.CurrentBackgroundMusic = nil
	end
end

function CLASS:PlaySoundEffect(soundEffectId)
	local sound = self:GetAudioAssetFromId(soundEffectId, self.SoundEffects)
	
	local soundClone = sound:Clone()
	soundClone.Parent = SOUND_SERVICE_ASSET_FOLDER
	DEBRIS_SERVICE:AddItem(soundClone, soundClone.TimeLength)
	soundClone:Play()
end

function CLASS:PlaySoundEffectAtPosition(soundEffectId, position)
	local sound = self:GetAudioAssetFromId(soundEffectId, self.SoundEffects)
	
	local soundPart = Instance.new("Part")
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Size = Vector3.new()
	soundPart.Position = position
	soundPart.Parent = WORKSPACE_ASSET_FOLDER
	local soundClone = sound:Clone()
	soundClone.Parent = soundPart
	DEBRIS_SERVICE:AddItem(soundPart, soundClone.TimeLength)
	soundClone:Play()
end

function CLASS:PlaySoundEffectOnInstance(soundEffectId, instance)
	local sound = self:GetAudioAssetFromId(soundEffectId, self.SoundEffects)
	
	local soundClone = sound:Clone()
	soundClone.Parent = instance
	DEBRIS_SERVICE:AddItem(soundClone, soundClone.TimeLength)
	soundClone:Play()
end

--// INSTRUCTIONS //--

CLASS.__index = CLASS

return CLASS.New()
