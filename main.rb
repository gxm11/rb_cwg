# encoding: utf-8
require_relative "cw"

# Read word_list
Words = File.read("./word_list.txt").split(/\s*\n/)
Words_Number = Words.size

# Read args
ARGV.each_with_index do |text, i|
  case text
  when "-s" then Xmap_Size = ARGV[i + 1].to_i
  when "-p" then Char_Weight = ARGV[i + 1].to_f
  end
end

Xmap_Size ||= Words_Number
Char_Weight ||= 0

# Sort words
Words.sort_by! { |w| -w.size - w.chars.uniq.size * Char_Weight }

Choices = [0] * Words_Number

xmap = Xmap.new(Xmap_Size, Words[0])

i = 1
_counts = 0
t = Time.now

# try to put each word in Xmap
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
