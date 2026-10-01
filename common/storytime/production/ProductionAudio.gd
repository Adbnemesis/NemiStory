extends RefCounted
## Load generated local media directly; no editor-import dependency.
static func read(path: String) -> AudioStream:
	match path.get_extension().to_lower():
		"wav": return AudioStreamWAV.load_from_file(path)
		"mp3":
			var stream := AudioStreamMP3.new()
			stream.data=FileAccess.get_file_as_bytes(path)
			return stream
		"ogg": return AudioStreamOggVorbis.load_from_file(path)
	assert(false,"Unsupported production audio: "+path)
	return null
