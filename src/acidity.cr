require "stumpy_png"

module Acidity
  extend self
  include StumpyPNG
  DEFAULT_RADIUS = 9

  # Converts Stumpy's RGBA to a hexademical integer (e.g., 0xRRGGBBAA).
  def rgba_to_int(rgba : RGBA)
    r, g, b, a = rgba.to_rgba
    return ((r.to_u64 << 24) + (g.to_u64 << 16) + (b.to_u64 << 8) + a.to_u64)
  end

  # Converts hexadecimal integer (e.g., 0xRRGGBBAA) to Stumpy's RGBA.
  def int_to_rgba(i)
    r = UInt16.new((i >> 24) & 0xFF)
    g = UInt16.new((i >> 16) & 0xFF)
    b = UInt16.new((i >> 8) & 0xFF)
    a = UInt16.new(i & 0xFF)
    return RGBA.from_rgba8(r, g, b, a)
  end

  # Create an aciditic image directly from a Stumpy Canvas.
  #
  # radius is used in computation. General rule: larger radius is more time, but larger bands of acidity
  def from_stumpy(input : Canvas, radius : Int32 = DEFAULT_RADIUS)
    raise "Invalid radius: must be positive, non-zero integer" if radius <= 0
    w, h = input.width, input.height
    output = Canvas.new(w, h) # Resulting Canvas

    # Precompute int values for pixels
    int_canvas = Array(UInt64).new(w * h, 0_u64)
    (0...h).each do |y|
      (0...w).each do |x|
        int_canvas[y * w + x] = rgba_to_int input[x, y]
      end
    end

    # Loop through image to acidify each pixel
    (0...h).each do |y|
      (0...w).each do |x|
        sum = 0_u64 # The sum of the integer colors of the pixel and radius pixels away.
        count = 0   # How many pixels represented in the pxl sum
        # Loop through (2 * radius + 1) x (2 * radius + 1) square, centered on (x, y)
        ((x - radius)..(x + radius)).each do |xi|
          if xi < w && xi >= 0
            ((y - radius)..(y + radius)).each do |yi|
              if yi < h && yi >= 0
                sum += int_canvas[yi * w + xi]
                count += 1
              end
            end
          end
        end
        # Average pixel color, but retain original opacity
        color = (sum / count) | (int_canvas[y * w + x] & 0xFF)
        output[x, y] = int_to_rgba color
      end
    end
    return output
  end

  # Create an aciditic image from a direct path to a PNG image.
  #
  # radius is used in computation. General rule: larger radius is more time, but larger bands of acidity
  def from_png_path(path : String, radius : Int32 = DEFAULT_RADIUS)
    raise "Invalid radius: must be positive, non-zero integer" if radius <= 0
    input = StumpyPNG.read path
    return from_stumpy(input, radius)
  end
end
