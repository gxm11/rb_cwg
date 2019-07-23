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

  attr_reader :xwords

  def initialize(max_size, first_word = "")
    @max_size = max_size
    @xwords = []
    if !first_word.empty?
      @xwords << Xword.new(first_word, 0, 0, false)
    end
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
