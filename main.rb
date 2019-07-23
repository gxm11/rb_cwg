# encoding: utf-8
require "json"
require_relative "xmap"

# Read args
ARGV.each_with_index do |text, i|
  case text
  when "-i" then Input_File = ARGV[i + 1]
  when "-o" then Output_File = ARGV[i + 1]
  when "-s" then Xmap_Size = ARGV[i + 1].to_i
  when "-p" then Char_Weight = ARGV[i + 1].to_f
  when /^\-/
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

# Sort words
Words.sort_by! { |w| -w.size - w.chars.uniq.size * Char_Weight }

Choices = [0] * Words_Size

xmap = Xmap.new(Xmap_Size, Words[0])

i = 1
_counts = 0
t = Time.now

# try to put each word in Xmap
until i == Words_Size || i == 0
  w = Words[i]
  cs = xmap.make_choices(w)
  if Choices[i] == cs.size
    Choices[i] = 0
    i -= 1
    Choices[i] += 1
    xmap.xwords.pop
  else
    xmap.xwords << cs[Choices[i]]
    i += 1
  end
  _counts += 1
end

puts "Run %d iterations in %.2f sec." % [_counts, Time.now - t]

if i == 0
  puts "Failed to generate."
else
  xmap.render
  h = xmap.xwords.collect { |xw|
    { word: xw.word, x: xw.x, y: xw.y, vertical: xw.vertical }
  }
  File.open(Output_File, "w") do |f|
    f << JSON.pretty_generate(h)
  end
end
