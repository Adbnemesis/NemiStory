class_name StoryDirector
extends Node

## Story Director DSL
## Provides high-level declarative beat controls, holds, and synchronization.

signal beat_started(beat_name: String)
signal story_completed

@export var character: StoryCharacter
@export var camera: StoryCamera
@export var speech_bubble: SpeechBubble
@export var subtitle_label: Label

## Intentional static hold: execution pauses while artwork holds completely still
func hold(duration: float) -> void:
	await get_tree().create_timer(duration).timeout

## Display clean bottom subtitle
func subtitle(text: String) -> void:
	if subtitle_label:
		subtitle_label.text = text
		subtitle_label.visible = (text != "")

## Clear subtitle
func clear_subtitle() -> void:
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false

## End the scene and signal completion
func complete_story() -> void:
	emit_signal("story_completed")
