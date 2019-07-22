# encoding: utf-8

Xword = Struct.new(:word, :x, :y, :vertical) do
  def size
    self.word.size
  end

  def chars
    self.word.split("")
  end
end

class Xmap
  attr_reader :max_size
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
    @xwords.each do |xword|
      a_xword = xword.chars
      a_text = text.split("")
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
    # 1. 判断是否出界
    if new_xword.vertical
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
      next if new_xword.vertical != xw.vertical
      d = new_xword.vertical ? (new_xword.x - xw.x) : (new_xword.y - xw.y)
      dd = new_xword.vertical ? (new_xword.y - xw.y) : (new_xword.x - xw.x)
      # 1. 差距在 2 行以外，直接无视
      next if d.abs > 1
      # 2. 差距是 1 行，不能重叠
      if d.abs == 1
        next if dd < 0 && dd + new_xword.size <= 0
        next if dd > 0 && dd - xw.size >= 0
      end
      # 3. 差距是 0 行，不能重叠，也不能连着
      if d == 0
        next if dd < 0 && dd + new_xword.size <= -1
        next if dd > 0 && dd - xw.size >= 1
      end
      return false
    end
    # 垂直测试
    @xwords.each do |xw|
      next if new_xword.vertical == xw.vertical
      h, v = new_xword.vertical ? [xw, new_xword] : [new_xword, xw]
      # 4 个 临界点的坐标
      vx_min = h.x - 1
      vx_max = h.x + h.size
      vy_min = h.y - v.size
      vy_max = h.y + 1
      # 超出临界点之外
      next if v.x < vx_min || v.x > vx_max || v.y < vy_min || v.y > vy_max
      # 在临界点上
      if v.x == vx_min || v.x == vx_max
        next if v.y == vy_min || v.y == vy_max
        return false
      end
      if v.y == vy_min || v.y == vy_max
        # next if v.x == vx_min || v.x == vx_max
        return false
      end
      # 有交叉点
      char_h = h.chars[v.x - h.x]
      char_v = v.chars[h.y - v.y]
      next if char_h == char_v
      return false
    end

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
    canvas
  end
end
