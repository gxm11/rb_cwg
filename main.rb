# encoding: utf-8
require_relative "cw"

Words = File.read("./word_list.txt").split(/\s*\n/)[0..30]

Words_Number = Words.size
Words.sort_by! { |w| -w.size }
Choices = [0] * Words_Number

_counts = 0

xmap_size = ARGV[0] ? ARGV[0].to_i : Words_Number

i = 0
xmap = Xmap.new(xmap_size, Words[i])
i += 1
t = Time.now

until i == Words_Number || i == 0
  w = Words[i]
  cs = xmap.make_choices(w)
  if Choices[i] == cs.size
    Choices[i] = 0
    i -= 1
    Choices[i] += 1
    xmap.xwords.pop
  else
    xmap.xwords.push(cs[Choices[i]])
    i += 1
  end
  _counts += 1
end

puts "Run %d times, cost %.2f sec." % [_counts, Time.now - t]

if i == 0
  puts "Failed to generate."
else
  canvas = xmap.render
  File.open("./crossword.txt", "w") do |f|
    f << canvas.join("\n")
  end
end
