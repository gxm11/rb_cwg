# encoding: utf-8
require_relative "xmap"

# Read args
ARGV.each_with_index do |text, i|
  case text
  when "-i" then Input_File = ARGV[i + 1]
  when "-o" then Output_File = ARGV[i + 1]
  when "-s" then Xmap_Size = ARGV[i + 1].to_i
  when "-p" then Phase_Theta = ARGV[i + 1].to_f
  when "-f" then Freeze_Number = ARGV[i + 1].to_i
  when "-h"
    puts <<~HELP
           Crossword Generator v1.2.1
           Author: guoxiaomi
           Github: https://github.com/gxm11/rb_cwg
           Usage:
             -i Input Word List
             -o Output Json
             -s Maximum Xmap Size
             -p Tuning Parameter: -1 ~ 1
             -f Freeze First N Words
             -h Show Help Message
         HELP
    exit
  end
end

Xmap_Size ||= 256
Phase_Theta ||= 0
Input_File ||= "./word_list.txt"
Output_File ||= "./crossword.json"
Freeze_Number ||= 0

# Read word_list
words = File.read(Input_File).split(/\s*\n/)
Words_Size = words.size
puts "Load #{Words_Size} words."

# Sort words
sorted_words = words[Freeze_Number..-1] || []
Words = (words - sorted_words).concat(sorted_words.sort_by! { |w|
  w.size * Math.cos(Phase_Theta * Math::PI) + w.chars.uniq.size * Math.sin(Phase_Theta * Math::PI)
}).reverse

xmap = Xmap.new(Xmap_Size)

# cache choices
choice = [[Xmap::Xword.new(Words.first, 0, 0, false)]]
choice_index = [0] * Words_Size

# Start Loop: put word in order
i = 0
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
# End Loop

puts "Run %d iterations in %.2f sec." % [_counts, t_end - t_start]

if i == 0
  puts "Failed to generate. Word List was:"
  puts Words.join("\n")
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
