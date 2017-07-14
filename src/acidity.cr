require "./acidity/*"
require "stumpy_png"
include StumpyPNG

if ARGV.size != 2
	puts "Usage: acidity INPUT.png OUTPUT.png"
	exit(-1)
end

def rgba_to_int(rgba : RGBA)
	r, g, b, a = rgba.to_rgba
	return ((r.to_u64 << 24) + (g.to_u64 << 16) + (b.to_u64 << 8) + a.to_u64)
end

def int_to_rgba(i)
	r = ((i >> 24) & 0xFF).to_u16
	g = ((i >> 16) & 0xFF).to_u16
	b = ((i >> 8) & 0xFF).to_u16
	a = (i & 0xFF).to_u16
	return RGBA.from_rgba8(r, g, b, a)
end

SPLIT = 9

input = StumpyPNG.read(ARGV[0])
w, h = input.width, input.height
output = Canvas.new(w, h)

(0...w).each do |x|
	(0...h).each do |y|
		pxl = rgba_to_int(input[x, y])
		count = 1
		((x - SPLIT)..(x + SPLIT)).each do |xi|
			if xi < w && xi >= 0
				((y - SPLIT)..(y + SPLIT)).each do |yi|
					if yi < h && yi >= 0 && (yi != y && xi != x)
						pxl += rgba_to_int(input[xi, yi])
						count += 1
					end
				end
			end
		end
		color = (pxl / count) | 255
		output[x, y] = int_to_rgba(color)
	end
end

StumpyPNG.write(output, ARGV[1])
