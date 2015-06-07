function draw.DrawShadowText( text, font, x, y, color, xA, yA, xS, yS, sColor )
	draw.SimpleText( text, font, x + xS, y + yS, sColor, xA, yA )
	draw.SimpleText( text, font, x, y, color, xA, yA )
end
function draw.DrawAbdulText( text, font, blurfont, x, y, color, xA, yA, ao )
	draw.SimpleText( text, blurfont, x, y, Color( color.r, color.g, color.b, 80 - ao ), xA, yA )
	draw.DrawShadowText( text, font, x, y, color, xA, yA, 1, 1, Color( 0, 0, 0, 100 - ao ) )
end
function surface.GetTextSizeEx( text, font )
	surface.SetFont( font )
	return surface.GetTextSize( text )
end
function ScreenScaleEx( num )
	return math.Clamp(ScrH() / 1080, 0.6, 1) * num *1.29
end