require 'debugger'

class Pos

  attr_accessor :rows, :columns

  def first=(val)
    @rows = val
  end

  def last=(val)
    @columns = val
  end

  def first
    @rows
  end

  def last
    @columns
  end

  def two_norm_square
    return @rows*@rows + @columns*@columns
  end

  def [](index)
    return @rows if index == 0
    return @columns if index == 1
  end

  def []=(index, val)
    @rows = val if index == 0
    @columns = val if index == 1
  end

  def initialize(pos)
    @rows, @columns = pos.first, pos.last
  end

  def +(new_pos)
   Pos.new([@rows + new_pos.rows, @columns + new_pos.columns])
  end

  def -(new_pos)
    Pos.new([@rows - new_pos.rows, @columns - new_pos.columns])
  end

  def ==(new_pos)
    return false if new_pos.nil?
    @rows == new_pos.rows && @columns == new_pos.columns
  end

  def to_a
    [@rows, @columns]
  end

  def to(end_pos)
    range = []
    if horizontal_to?(end_pos)
      if @columns > end_pos.columns
        (@columns - 1).downto(end_pos.columns) do |new_col|
          range << Pos.new([@rows, new_col])
        end
      else
        (self.columns + 1).upto(end_pos.columns) do |new_col|
          range << Pos.new([@rows, new_col])
        end
      end
    elsif vertical_to?(end_pos)
      if @rows > end_pos.rows
        (@rows - 1).downto(end_pos.rows) do |new_row|
          range << Pos.new([new_row, @columns])
        end
      else
        (@rows + 1).upto(end_pos.rows) do |new_row|
          range << Pos.new([new_row, @columns])
        end
      end
    elsif left_diag_to?(end_pos)
      case @columns <=> end_pos.columns
      when 1
        (@columns - end_pos.columns).times {|i| range << self - Pos.new([i+1,i+1])}
      when -1
        (end_pos.columns - @columns).times {|i| range << self + Pos.new([i+1,i+1])}
      end
    elsif right_diag_to?(end_pos)
      case @columns <=> end_pos.columns
      when 1
        (@columns - end_pos.columns).times {|i| range << self + Pos.new([i+1,-i-1])}
      when -1
        (end_pos.columns - @columns).times {|i| range << self - Pos.new([i+1,-i-1])}
      end
    end
    range
  end

  def is_diag?(end_pos)
    self.right_diag_to?(end_pos) || self.left_diag_to?(end_pos)
  end

  def horizontal_to?(end_pos)
    end_pos.rows == @rows
  end

  def vertical_to?(end_pos)
    end_pos.columns == @columns
  end

  def right_diag_to?(end_pos)
    vector = end_pos - self
    vector[0] == -vector[1]
  end

  def left_diag_to?(end_pos)
    vector = end_pos - self
    vector[0] == vector[1]
  end
end

# p1 = Pos.new([3,4])
# p2 = Pos.new([6,7])
# p3 = Pos.new([3,1])
# p4 = Pos.new([1,3])
# p5 = Pos.new([1,7])
# p6 = Pos.new([1,-20])
# p p1.to(p5)
# p p1.to(p2).map(&:to_a)
# p p2.to(p1).map(&:to_a)
# p p3.to(p4).map(&:to_a)
# p p4.to(p3).map(&:to_a)
# p p5.to(p6).map(&:to_a)
