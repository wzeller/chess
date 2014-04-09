#cannot move into check -- add to test for validity in each piece


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

  attr_accessor :type, :color, :symbol, :pos

  #type :pieces,  color :white/:black, pos = Pos object, board = Board object
  def initialize(type, color, pos, board)
    @type = type
    @color = color
    @pos = Pos.new(pos)
    @board = board
    @symbol = @@visual[type]
  end

  def on_board?(pos)
    (0...@board.size).cover?(pos[0]) && (0...@board.size).cover?(pos[1])
  end

  def not_blocked?(possible_moves)
    #remove target move before testing for blocks
    possible_moves.pop
    possible_moves.each {|move| move = Pos.new(move); return false unless @board[move].nil?}
    return true
  end

  def own_piece?(target)
    return false if target == nil
    self.color == target.color
  end

  def move_helper(end_pos)
    @board[end_pos] = self
    @board[self.pos] = nil
    self.pos = end_pos
  end

  def move(end_pos)
    end_pos = Pos.new(end_pos)
    raise InvalidMoveError unless can_move?(end_pos) 
    if @board[end_pos] != nil
      move_helper(end_pos)
      return :captured_piece
    else
      move_helper(end_pos)
    end
  end
end

class Bishop < Piece

  def initialize(color, pos, board)
    super(:Bishop, color, pos, board)
  end

  def can_move?(end_pos)
    return false unless on_board?(end_pos)
    return false unless self.pos.is_diag?(end_pos)
    return false if own_piece?(@board[end_pos])
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false unless not_blocked(all_moves)
    return true
  end
  
end

class Rook < Piece

  def initialize(color, pos, board)
    super(:Rook, color, pos, board)
  end

  def can_move?(end_pos)
    return false unless on_board?(end_pos)
    return false unless self.pos.vertical_to?(end_pos) || self.pos.horizontal_to?(end_pos)
    return false if own_piece?(@board[end_pos])
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false unless not_blocked?(all_moves)
    return true
  end

end

class Queen < Piece

  def initialize(color, pos, board)
    super(:Queen, color, pos, board)
  end

  def can_move?(end_pos)
    return false unless on_board?(end_pos)
    return false unless self.pos.is_diag?(end_pos) || self.pos.vertical_to?(end_pos) || self.pos.horizontal_to?(end_pos)
    return false if own_piece?(@board[end_pos])
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false unless not_blocked?(all_moves)
    return true
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
  
  def can_move?(end_pos)
    end_pos = Pos.new(end_pos)
    return false unless on_board?(end_pos)
    return false unless @@knight_delta.include?(end_pos - self.pos)
    return false if own_piece?(@board[end_pos])
    return true
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
    @moved = false
  end

  def can_move?(end_pos)
    delta = 1 if self.color == :black
    delta = -1 if self.color == :white
    
    #standard checks for illegal move
    return false unless on_board?(end_pos)
    return false if own_piece?(@board[end_pos])
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false unless not_blocked?(all_moves)
    
    #checks for straight moves
    if @moved == false && self.pos.vertical_to?(end_pos)
      return false unless (end_pos.rows - self.pos.rows) == delta || (end_pos.rows - self.pos.rows) == delta*2
    elsif @moved == true && self.pos.vertical_to?(end_pos)
      return false unless (end_pos.rows - self.pos.rows) == delta
    end
    
    #checks for captures
    if self.pos.is_diag?(end_pos)
      return false unless end_pos.rows - self.pos.ros == delta && !@board[end_pos].nil?
    end
    
    #set flag for later moves
    @moved = true 
    return true 
  end

end
