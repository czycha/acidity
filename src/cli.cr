require "./acidity.cr"

if ARGV.size != 2 && ARGV.size != 3
  puts "Usage: acidity INPUT.png OUTPUT.png [RADIUS]
       INPUT: Required. PNG image to convert.
       OUTPUT: Required. PNG image to write to.
       RADIUS: Optional, defaults to 9. Higher numbers takes longer, but produce larger bands of texture."
  exit(-1)
end

output = ARGV.size == 3 ? Acidity.from_png_path(ARGV[0], ARGV[2].to_i) : Acidity.from_png_path(ARGV[0])
StumpyPNG.write(output, ARGV[1])
