# encoding: utf-8
require "json"

class Xmap
  Xword = Struct.new(:word, :x, :y, :vertical) do
    def size
      self.word.size
    end

    def chars
      self.word.split("")
    end
  end

  Cache_Maxmin = Struct.new(:x_min, :x_max, :y_min, :y_max)

  attr_reader :xwords

  def initialize(max_size, first_word = "")
    @max_size = max_size
    @xwords = []
    @cache_maxmin = Cache_Maxmin.new(0, 0, 0, 0)
    if !first_word.empty?
      @xwords << Xword.new(first_word, 0, 0, false)
      refresh_xwords_maxmin
    end
  end

  def refresh_xwords_maxmin
    @cache_maxmin.x_min = @xwords.collect(&:x).min
    @cache_maxmin.x_max = @xwords.collect { |xw| xw.x + (xw.vertical ? 1 : xw.size) - 1 }.max
    @cache_maxmin.y_min = @xwords.collect(&:y).min
    @cache_maxmin.y_max = @xwords.collect { |xw| xw.y + (xw.vertical ? xw.size : 1) - 1 }.max
  end

  def push(xword)
    @xwords << xword
    refresh_xwords_maxmin
  end

  def pop
    @xwords.pop
    refresh_xwords_maxmin
  end

  def make_choices(text)
    choices = []
    a_text = text.split("")

    @xwords.each do |xword|
      a_xword = xword.chars
      a = a_xword & a_text
      next if a.empty?
      # select all possible xwords
      a_xword.each_with_index do |char, i|
        if a.include?(char)
          a_text.each_with_index do |_char, j|
            if char == _char
              if xword.vertical
                new_xword = Xword.new(text, xword.x - j, xword.y + i, false)
              else
                new_xword = Xword.new(text, xword.x + i, xword.y - j, true)
              end
              if consist_after?(new_xword)
                choices << new_xword
              end
            end
          end
        end
      end
    end
    return choices
  end

  def consist_after?(new_xword)
    consist_after_part1(new_xword) && consist_after_part2(new_xword) && consist_after_part3(new_xword)
  end

  def consist_after_part1(new_xword)
    new_xword_vertical = new_xword.vertical
    # 1. 判断是否出界
    if new_xword_vertical
      y_min = [@cache_maxmin.y_min, new_xword.y].min
      y_max = [@cache_maxmin.y_max, new_xword.y + (new_xword_vertical ? new_xword.size : 1)].max
      if y_max - y_min >= @max_size
        return false
      end
    else
      x_min = [@cache_maxmin.x_min, new_xword.x].min
      x_max = [@cache_maxmin.x_max, new_xword.x + (new_xword_vertical ? 1 : new_xword.size) - 1].max
      if x_max - x_min >= @max_size
        return false
      end
    end
    return true
  end

  def consist_after_part2(new_xword)
    new_xword_vertical = new_xword.vertical
    # 4 个 临界点的坐标之跟 xw 无关的部分
    y_max = new_xword_vertical ? new_xword.size : 1
    x_max = new_xword_vertical ? 1 : new_xword.size
    @xwords.each do |xw|
      next if new_xword_vertical != xw.vertical
      dx, dy = xw.x - new_xword.x, xw.y - new_xword.y
      next if dx > x_max || dy > y_max
      # 4 个 临界点的坐标之跟 xw 有关的部分
      x_min = new_xword_vertical ? -1 : -xw.size
      y_min = new_xword_vertical ? -xw.size : -1
      # 超出临界点之外
      next if (dx < x_min || dy < y_min)
      # 在临界点上
      next if (dx == x_min || dx == x_max) && (dy == y_min || dy == y_max)
      return false
    end
    return true
  end

  def consist_after_part3(new_xword)
    new_xword_vertical = new_xword.vertical
    x_min = -1
    y_max = 1
    @xwords.each do |xw|
      next if new_xword_vertical == xw.vertical
      h, v = new_xword_vertical ? [xw, new_xword] : [new_xword, xw]
      dx, dy = v.x - h.x, v.y - h.y
      next if dx < x_min || dy > y_max
      # 4 个 临界点的坐标
      x_max = h.size
      y_min = -v.size
      # 超出临界点之外
      next if (dx > x_max || dy < y_min)
      # 在临界点上
      next if (dx == x_min || dx == x_max) && (dy == y_min || dy == y_max)
      # 有交叉点
      next if h.word[dx] == v.word[-dy]
      return false
    end
    # 通过测试
    return true
  end
=begin
  def consist_after?(new_xword)
    new_xword_vertical = new_xword.vertical
    # 1. 判断是否出界
    if new_xword_vertical
      y_min = (@xwords + [new_xword]).collect(&:y).min
      y_max = (@xwords + [new_xword]).collect { |xw| xw.y + (xw.vertical ? xw.size : 1) - 1 }.max
      if y_max - y_min >= @max_size
        return false
      end
    else
      x_min = (@xwords + [new_xword]).collect(&:x).min
      x_max = (@xwords + [new_xword]).collect { |xw| xw.x + (xw.vertical ? 1 : xw.size) - 1 }.max
      if x_max - x_min >= @max_size
        return false
      end
    end
    # 平行测试
    @xwords.each do |xw|
      next if new_xword_vertical != xw.vertical
      # 4 个 临界点的坐标
      x_min = new_xword.x + (new_xword_vertical ? -1 : -xw.size)
      x_max = new_xword.x + (new_xword_vertical ? 1 : new_xword.size)
      y_min = new_xword.y + (new_xword_vertical ? -xw.size : -1)
      y_max = new_xword.y + (new_xword_vertical ? new_xword.size : 1)
      # 超出临界点之外
      next if xw.x < x_min || xw.x > x_max || xw.y < y_min || xw.y > y_max
      # 在临界点上
      if xw.x == x_min || xw.x == x_max
        next if xw.y == y_min || xw.y == y_max
      end
      return false
    end
    # 垂直测试
    @xwords.each do |xw|
      next if new_xword_vertical == xw.vertical
      h, v = new_xword_vertical ? [xw, new_xword] : [new_xword, xw]
      # 4 个 临界点的坐标
      x_min = h.x - 1
      x_max = h.x + h.size
      y_min = h.y - v.size
      y_max = h.y + 1
      # 超出临界点之外
      next if v.x < x_min || v.x > x_max || v.y < y_min || v.y > y_max
      # 在临界点上
      if v.x == x_min || v.x == x_max
        next if v.y == y_min || v.y == y_max
        return false
      end
      if v.y == y_min || v.y == y_max
        # next if v.x == x_min || v.x == x_max
        return false
      end
      # 有交叉点
      char_h = h.chars[v.x - h.x]
      char_v = v.chars[h.y - v.y]
      next if char_h == char_v
      return false
    end
    # 通过测试
    return true
  end
=end
  def render
    y_min = @xwords.collect(&:y).min
    y_max = @xwords.collect { |xw| xw.y + (xw.vertical ? xw.size : 1) - 1 }.max
    x_min = @xwords.collect(&:x).min
    x_max = @xwords.collect { |xw| xw.x + (xw.vertical ? 1 : xw.size) - 1 }.max

    canvas = Array.new(y_max - y_min + 1) { "." * (x_max - x_min + 1) }

    @xwords.each do |xw|
      if xw.vertical
        xw.chars.each_with_index do |char, y|
          canvas[xw.y + y - y_min][xw.x - x_min] = char
        end
      else
        xw.chars.each_with_index do |char, x|
          canvas[xw.y - y_min][xw.x + x - x_min] = char
        end
      end
    end

    puts "Xmap Shape: #{x_max - x_min + 1} x #{y_max - y_min + 1}"
    puts canvas.join("\n")
    return canvas
  end
end

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

Trace = [0] * Words_Size

xmap = Xmap.new(Xmap_Size, Words[0])

i = 1
_counts = 0
t = Time.now

# try to put each word in Xmap
until i == Words_Size || i == 0
  w = Words[i]
  choices = xmap.make_choices(w)
  if Trace[i] == choices.size
    Trace[i] = 0
    i -= 1
    Trace[i] += 1
    xmap.pop
  else
    xmap.push(choices[Trace[i]])
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
