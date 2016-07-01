DUNGEONS = {}

hook.Add( "PlayerNoClip", "nc", function( ply, desiredNoClipState )
	return true
end )