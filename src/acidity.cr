require "./acidity/*"
require "stumpy_png"
include StumpyPNG

if ARGV.size != 2 && ARGV.size != 3
  puts "Usage: acidity INPUT.png OUTPUT.png [RADIUS]
       INPUT: Required. PNG image to convert.
       OUTPUT: Required. PNG image to write to.
       RADIUS: Optional, defaults to 9. Higher numbers takes longer, but produce larger bands of texture."
  exit(-1)
end

if ARGV.size == 3
  radius = ARGV[2].to_i
  if radius <= 0
    puts "Invalid radius."
    exit(-1)
  end
else
  radius = 9
end

##
# Converts StumpyPNG's RGBA format to int.
def rgba_to_int(rgba : RGBA)
  r, g, b, a = rgba.to_rgba
  return ((r.to_u64 << 24) + (g.to_u64 << 16) + (b.to_u64 << 8) + a.to_u64)
end

##
# Converts int format to StumpyPNG's RGBA format.
def int_to_rgba(i)
  r = UInt16.new((i >> 24) & 0xFF)
  g = UInt16.new((i >> 16) & 0xFF)
  b = UInt16.new((i >> 8) & 0xFF)
  a = UInt16.new(i & 0xFF)
  return RGBA.from_rgba8(r, g, b, a)
end

input = StumpyPNG.read(ARGV[0])
w, h = input.width, input.height
int_canvas = Array(UInt64).new(w * h, UInt64.new(0))
output = Canvas.new(w, h)

# Precompute int values for pixels
(0...h).each do |y|
  (0...w).each do |x|
    int_canvas[y * w + x] = rgba_to_int(input[x, y])
  end
end

(0...h).each do |y|
  (0...w).each do |x|
    pxl = int_canvas[y * w + x]
    count = 0
    ((x - radius)..(x + radius)).each do |xi|
      if xi < w && xi >= 0
        ((y - radius)..(y + radius)).each do |yi|
          if yi < h && yi >= 0 && (yi != y && xi != x)
            pxl += int_canvas[yi * w + xi]
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
