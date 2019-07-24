# encoding: utf-8
require_relative "xmap"

# Read args
ARGV.each_with_index do |text, i|
  case text
  when "-i" then Input_File = ARGV[i + 1]
  when "-o" then Output_File = ARGV[i + 1]
  when "-s" then Xmap_Size = ARGV[i + 1].to_i
  when "-p" then Char_Weight = ARGV[i + 1].to_f
  when "-h"
    puts <<~HELP
           Github: https://github.com/gxm11/rb_cwg
           Usage:
             -i Input Word List
             -o Output Json
             -s Maximum Xmap Size
             -p Tuning Parameter
         HELP
    exit
  end
end

Xmap_Size ||= 256
Char_Weight ||= 0.1
Input_File ||= "./word_list.txt"
Output_File ||= "./crossword.json"

# Read word_list
Words = File.read(Input_File).split(/\s*\n/)
Words_Size = Words.size
puts "Load #{Words_Size} words."

# Sort words
Words.sort_by! { |w| -w.size - w.chars.uniq.size * Char_Weight }

xmap = Xmap.new(Xmap_Size, Words[0])

# cache choices
choice = []
choice_index = [0] * Words_Size

i = 1
choice[i] = xmap.make_choices(Words[i])

# try to put word in order into Xmap
_counts = 0
t_start = Time.now
loop do
  _counts += 1

  if choice_index[i] == choice[i].size
    choice_index[i] = 0
    i -= 1
    break if i == 0
    choice_index[i] += 1
    choice.pop
    xmap.pop
  else
    xmap.push(choice[i][choice_index[i]])
    i += 1
    break if i == Words_Size
    choice[i] = xmap.make_choices(Words[i])
  end
end
t_end = Time.now

puts "Run %d iterations in %.2f sec." % [_counts, t_end - t_start]

if i == 0
  puts "Failed to generate."
else
  xmap.render
  j = xmap.xwords.collect { |xw|
    d = <<-JSON
  {
    "word": "#{xw.word}",
    "x": #{xw.x},
    "y": #{xw.y},
    "vertical": #{xw.vertical}
  }
  JSON
    d.rstrip()
  }.join(",\n")
  File.open(Output_File, "w") do |f|
    f << "[\n" << j << "\n]"
  end
end
