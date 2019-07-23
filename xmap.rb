# encoding: utf-8

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
      push(Xword.new(first_word, 0, 0, false))
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
        next if !a.include?(char)
        a_text.each_with_index do |_char, j|
          next if char != _char
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
    return choices
  end

  def consist_after?(new_xword)
    consist_after_part1(new_xword) && consist_after_part2(new_xword) && consist_after_part3(new_xword)
  end

  # Part1: 判断是否出界
  def consist_after_part1(new_xword)
    new_xword_vertical = new_xword.vertical
    # 1. 判断是否出界
    if new_xword_vertical
      y_min = [@cache_maxmin.y_min, new_xword.y].min
      y_max = [@cache_maxmin.y_max, new_xword.y + new_xword.size].max
      if y_max - y_min >= @max_size
        return false
      end
    else
      x_min = [@cache_maxmin.x_min, new_xword.x].min
      x_max = [@cache_maxmin.x_max, new_xword.x + new_xword.size - 1].max
      if x_max - x_min >= @max_size
        return false
      end
    end
    return true
  end

  # Part2: 判断与 new_xword 平行的 Xword
  def consist_after_part2(new_xword)
    new_xword_vertical = new_xword.vertical
    # 4 个 临界点的坐标之跟 xw 无关的部分
    y_max = new_xword.size
    x_max = 1
    x_min = -1
    @xwords.each do |xw|
      next if new_xword_vertical != xw.vertical
      if new_xword_vertical
        dx, dy = xw.x - new_xword.x, xw.y - new_xword.y
      else
        dy, dx = xw.x - new_xword.x, xw.y - new_xword.y
      end
      next if dx > x_max || dy > y_max || dx < x_min
      # 4 个 临界点的坐标之跟 xw 有关的部分
      y_min = -xw.size
      # 超出临界点之外
      next if dy < y_min
      # 在临界点上
      next if (dx == x_min || dx == x_max) && (dy == y_min || dy == y_max)
      return false
    end
    return true
  end

  # Part2: 判断与 new_xword 垂直的 Xword
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
      # 有交叉点，注意此处如果没有交叉点，则必有一个为 nil
      # 若 2 个都为 nil，则
      next if h.word[dx] == v.word[-dy] && dx >= 0 && dy <= 0
      return false
    end
    # 通过测试
    return true
  end

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
