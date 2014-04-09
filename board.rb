require './position.rb'
require './pieces.rb'
require 'colorize'
require 'debugger'


class Board
  attr_accessor :board
  def initialize
    make_board
    @captured_pieces = []

  end

  def [](pos)
    return @board[pos[0]][pos[1]]
  end

  def []=(pos,new_piece)
    @board[pos[0]][pos[1]] = new_piece
  end

  def size
    return @board.length
  end

  def make_board

    @board = Array.new(8){Array.new(8)}
    @board[0] = [Rook.new(:black,Pos.new([0,0]),self),
                Knight.new(:black,Pos.new([0,1]),self),
                Bishop.new(:black,Pos.new([0,2]),self),
                Queen.new(:black,Pos.new([0,3]),self),
                King.new(:black,Pos.new([0,4]),self),
                Bishop.new(:black,Pos.new([0,5]),self),
                Knight.new(:black,Pos.new([0,6]),self),
                Rook.new(:black,Pos.new([0,7]),self)]

    @board[1] = []
    8.times do |i|
      @board[1] << Pawn.new(:black, Pos.new([1,i]), self)
    end

    @board[6] = []
    8.times do |i|
      @board[6] << Pawn.new(:white, Pos.new([6,i]), self)
    end

    @board[7] = [Rook.new(:white, Pos.new([7,0]),self),
                Knight.new(:white, Pos.new([7,1]),self),
                Bishop.new(:white, Pos.new([7,2]),self),
                Queen.new(:white, Pos.new([7,3]),self),
                King.new(:white, Pos.new([7,4]),self),
                Bishop.new(:white, Pos.new([7,5]),self),
                Knight.new(:white, Pos.new([7,6]),self),
                Rook.new(:white, Pos.new([7,7]),self)]

    @board_color = Array.new(8){Array.new(8)}
    switch = false
    (0...8).each do |row|
      switch = !switch
      (0...8).each do |col|
        if switch == true
          @board_color[row][col] = :light_white
        else
          @board_color[row][col] = :light_black
        end
        switch = !switch
      end
    end
  end

  def stage
    buffer = Array.new(8){Array.new(8)}
    frame = []
    (0...8).each do |row|
      (0...8).each do |col|
        square = @board_color[row][col]
        if @board[row][col].nil?
          frame << "  ".colorize({background: square})
        else
          piece = @board[row][col]
          frame << (piece.symbol+" ").colorize({color: piece.color, background: square, bold: true})
        end
      end
      frame <<  "\n"
    end

    return frame.join

  end

  def debug_print
    @board.each do |row|
      row.each do |element|
        print element.symbol+"  " if element != nil
        print "   " if  element == nil
      end
      print "\n"
    end
  end

end

board = Board.new
pos1 = Pos.new [1,1]
pos2 = Pos.new [3,1]
pos3 = Pos.new [6,0]
pos4 = Pos.new [4,0]
board[pos1].move(pos2)
print board.stage
board[pos3].move(pos4)
print board.stage
board[pos2].move(pos4)
print board.stage
