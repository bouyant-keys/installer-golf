@tool
class_name ReplaceTextEffect extends RichTextEffect
## "Censors" a word by replacing vowels with symbols.

## Syntax: [cuss][]
const bbcode = "cuss"

const CUSS_CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ&$!@*#%"

func _process_custom_fx(c: CharFXTransform):
	var offset := randi_range(0, CUSS_CHARS.length()-1)
	var char_index := (Time.get_ticks_msec()/1000) % CUSS_CHARS.length()
	var new_char := CUSS_CHARS[char_index]
	var text_server = TextServerManager.get_primary_interface()
	c.glyph_index = text_server.font_get_glyph_index(c.font, 16, new_char.unicode_at(0), 0)
	
	return true
