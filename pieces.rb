#Piece class
# /               \                 \
#Sliding piece   stepping piece   pawn
# |                       |
#Biship,Rook,Queen    knight,king

require 'colorize'

class InvalidMoveError < RuntimeError

end

class Piece

  @@visual ={
    King:   "\u265A",
    Queen:  "\u265B",
    Rook:   "\u265C",
    Bishop: "\u265D",
    Knight: "\u265E",
    Pawn:   "\u265F",
  }

  attr_accessor :color, :symbol, :pos
  #type :pieces,  color :white/:black, pos = Pos object, board = Board object
  def initialize(type, color, pos, board)
    @type = type
    @color = color
    @pos = Pos.new(pos)
    @board = board
    @symbol = @@visual[type]
  end

  def on_board?(pos)
    (0...@board.size).cover?(pos.rows) && (0...@board.size).cover?(pos.columns)
  end

  def not_blocked?(possible_moves)
    #remove target move before testing for blocks
    possible_moves.pop
    possible_moves.each {|move| return false unless @board[move].nil?}
    return true
  end

  def own_piece?(target)
    return false if target == nil
    self.color == target.color
  end

  def move_helper(end_pos)

    @board[end_pos] = self
    #p @board.board.object_id
    @board[self.pos] = nil
    self.pos = end_pos
  end

end


class Bishop < Piece
  def initialize(color, pos, board)
    super(:Bishop, color, pos, board)
  end

  def can_move?(end_pos)
    return false if !on_board?(end_pos)
    return false if !self.pos.is_diag?(end_pos)
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false if !not_blocked(all_moves)
    return true
  end

  def move(end_pos)
    raise InvalidMoveError if !self.pos.is_diag?(end_pos)
    all_moves = self.pos.to(end_pos)
    raise InvalidMoveError if all_moves.empty?
    if not_blocked?(all_moves) && on_board?(end_pos)
      if @board[end_pos] != nil && (not own_piece?(@board[end_pos]))
        move_helper(end_pos)
        return :captured_piece
      else
        move_helper(end_pos)
      end
    end
    raise InvalidMoveError
  end


end

class Rook < Piece
  def initialize(color, pos, board)
    super(:Rook, color, pos, board)
  end
  def move(end_pos)
    all_moves = self.pos.to(end_pos)
    raise InvalidMoveError if all_moves.empty?

  end
end

class Queen < Piece
  def initialize(color, pos, board)
    super(:Queen, color, pos, board)
  end
end

class Knight < Piece
  @@knight_delta = [Pos.new([2 , 1]),
                    Pos.new([2 ,-1]),
                    Pos.new([1 , 2]),
                    Pos.new([1 ,-2]),
                    Pos.new([-1, 2]),
                    Pos.new([-1,-2]),
                    Pos.new([-2, 1]),
                    Pos.new([-2,-1])]

  def initialize(color, pos, board)
    super(:Knight, color, pos, board)
  end
  #b = Knight.new(:black,Pos.new([2,2]),board)

  def move(end_pos)
    if @@knight_delta.include?(end_pos - self.pos)
      if own_piece?(@board[end_pos])
        raise InvalidMoveError
      elsif @board[end_pos] != nil
        move_helper(end_pos)
        return :captured_piece
      else
        move_helper(end_pos)
      end
    else
      raise InvalidMoveError
    end
  end
end

class King < Piece
  def initialize(color, pos, board)
    super(:King, color, pos, board)
  end
end

class Pawn < Piece
  #normal moves
  @@moves = [Pos.new([1 , 0]),
            Pos.new([1 , 1]),
            Pos.new([1 , -1]),
            Pos.new([2,0])]

  def initialize(color, pos, board)
    super(:Pawn, color, pos, board)
  end

  def move(end_pos)
    if self.color == :black
      raise InvalidMoveError unless @@moves.include?(end_pos-self.pos)
      #if first move
      if self.pos[0] == 1 && end_pos - self.pos == @@moves.last
        #only valid if sqaure ahead is empty or two ahead
        return InvalidMoveError if @board[self.pos + @@moves.first] != nil
        return InvalidMoveError if @board[self.pos + @@moves.last] != nil

        move_helper(end_pos)
      end
      #if capture
      if @@moves[1..2].include? (end_pos - self.pos)
        return InvalidMoveError if @board[end_pos].nil? || own_piece?(@board[end_pos])
        move_helper(end_pos)
        return :captured_piece
      end

      if @@moves.first == (end_pos - self.pos)
        if @board[end_pos].nil?
          move_helper(end_pos)
        end
      end
    end

    if self.color == :white
      raise InvalidMoveError unless @@moves.include?(self.pos-end_pos)
      #if first move
      if self.pos[0] == 6 && self.pos - end_pos == @@moves.last
        #only valid if sqaure ahead is empty or two ahead
        return InvalidMoveError if @board[self.pos - @@moves.first] != nil
        return InvalidMoveError if @board[self.pos - @@moves.last] != nil

        move_helper(end_pos)
      end
      #if capture
      if @@moves[1..2].include? (self.pos - end_pos)
        return InvalidMoveError if @board[end_pos].nil? || own_piece?(@board[end_pos])
        move_helper(end_pos)
        return :captured_piece
      end

      if @@moves.first == (self.pos - end_pos)
        if @board[end_pos].nil?
          move_helper(end_pos)
        end
      end
    end

  end


end
