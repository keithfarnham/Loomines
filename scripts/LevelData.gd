extends Node2D

const Song = {
	BoardData.Levels.LEVEL_01: "res://audio/Not very cool or interesting_168bpm_96bars.wav",
	BoardData.Levels.LEVEL_02: "res://audio/160bpm16barloop.wav",
	BoardData.Levels.LEVEL_03: "res://audio/Background noise_110bpm.wav"
	}
	
const BPM = {
	BoardData.Levels.LEVEL_01: 168,
	BoardData.Levels.LEVEL_02: 160,
	BoardData.Levels.LEVEL_03: 110
}

const SpeedMod = {
	BoardData.Levels.LEVEL_01: 2,
	BoardData.Levels.LEVEL_02: 2,
	BoardData.Levels.LEVEL_03: 4
}

const RotateLeftSFX = {
	BoardData.Levels.LEVEL_01: "res://audio/sfx/left_rotate_swish_128bpm.wav",
	BoardData.Levels.LEVEL_02: "res://audio/sfx/left_rotate_swish_128bpm.wav",
	BoardData.Levels.LEVEL_03: "res://audio/sfx/left_rotate_swish_128bpm.wav"
}

const RotateRightSFX = {
	BoardData.Levels.LEVEL_01: "res://audio/sfx/right_rotate_swish_128bpm.wav",
	BoardData.Levels.LEVEL_02: "res://audio/sfx/right_rotate_swish_128bpm.wav",
	BoardData.Levels.LEVEL_03: "res://audio/sfx/right_rotate_swish_128bpm.wav"
}

const LandBlockSFX = {
	BoardData.Levels.LEVEL_01: "res://audio/sfx/clap_echo_128bpm.wav",
	BoardData.Levels.LEVEL_02: "res://audio/sfx/clap_echo_128bpm.wav",
	BoardData.Levels.LEVEL_03: "res://audio/sfx/clap_echo_128bpm.wav"
}

const BackgroundTexture = {
	BoardData.Levels.LEVEL_01: "res://art/test_textures/poisebois_level1.png",
	BoardData.Levels.LEVEL_02: "res://art/test_textures/jammuel_level2.png",
	BoardData.Levels.LEVEL_03: "res://art/test_textures/byo_level3.png"
}
