class_name Speaker
extends Control

func _ready():
	speak_shader = %Speak_BG.material.duplicate()
	%Speak_BG.material = speak_shader
	self.scale = Vector2.ZERO
	self.visible = false

const SPEAK_TEXT_ROTATION_INITIAL : float = 165
# If this is 1.0, it will finish showing all the text for the duration of the effect
# Make it less so that it appears faster
const SPEAK_TEXT_APPEAR_SPEED_RATIO : float = 1.0
const SPEAK_TEXT_ROTATION_SPEED_RATIO : float = 1.25
var speak_tween : Tween = null
var speak_fader_tween : Tween = null
var speak_shader : ShaderMaterial = null
var speak_disappear_timer : SceneTreeTimer = null
func speak(text: Variant, bg_color: Color = Color.DEEP_SKY_BLUE, 
	appear_speed: float = .5, disappear_after: float = 0.0) -> void:
	if text == null:
		return
	
	text = text as String
	if text.is_empty():
		return
	
	if speak_tween:
		speak_tween.kill()
	
	if speak_fader_tween:
		speak_fader_tween.kill()
	
	if speak_disappear_timer:
		Utils.clear_signals(speak_disappear_timer)
		speak_disappear_timer = null
	
	self.visible = true
	var speak_text : Control = %Speak_Text
	var speak_bg : Control = %Speak_BG
	
	speak_shader.set_shader_parameter("color", bg_color)
	speak_text.text = text
	
	speak_text.visible_ratio = 0.0
	
	speak_text.rotation_degrees = SPEAK_TEXT_ROTATION_INITIAL
	speak_text.scale = Vector2.ZERO
	speak_bg.scale = Vector2.ZERO
	speak_bg.rotation_degrees = randi_range(0, 360)
	
	speak_shader.set_shader_parameter("alpha", 0.0)
	
	speak_tween = get_tree().create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)
	
	self.scale = Vector2.ONE
	speak_tween.tween_property(speak_bg, "scale", Vector2.ONE, appear_speed)
	speak_tween.parallel().tween_property(speak_text, "scale", Vector2.ONE, appear_speed)
	
	speak_tween.parallel().tween_property(speak_text, "rotation_degrees", 0.0, \
		appear_speed * SPEAK_TEXT_ROTATION_SPEED_RATIO)
	speak_tween.parallel().tween_property(speak_text, "visible_ratio", 1.0, \
		appear_speed * SPEAK_TEXT_APPEAR_SPEED_RATIO)
		
	speak_tween.parallel().tween_method(func(alpha: float):
			speak_shader.set_shader_parameter("alpha", alpha),
		0.0, 1.0, appear_speed)
	
	if disappear_after > 0.0:
		speak_disappear_timer = get_tree().create_timer(disappear_after)
		speak_disappear_timer.timeout.connect(func():
			self.leave())

func leave(disappear_speed: float = .35) -> void:
	var speak_text : Control = %Speak_Text
	#var speak_bg : Control = %Speak_Control.get_node("%Speak_BG")
	#
	#speak_fader_tween \
		#.tween_property(%Speak_Control, "modulate", Color.TRANSPARENT, disappear_speed)
	
	speak_fader_tween = get_tree().create_tween() \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	speak_fader_tween \
		.parallel().tween_property(speak_text, "rotation_degrees", -SPEAK_TEXT_ROTATION_INITIAL / 2.0, disappear_speed) \
		.set_ease(Tween.EASE_OUT)
	
	speak_fader_tween \
		.parallel().tween_property(speak_text, "scale", Vector2.ZERO, disappear_speed) \
		.set_ease(Tween.EASE_OUT)
	
	speak_fader_tween \
		.parallel().tween_method(func(alpha: float):
				speak_shader.set_shader_parameter("alpha", alpha),
			1.0, 0.0, disappear_speed)
	
	speak_fader_tween.tween_callback(func(): self.visible = false)
