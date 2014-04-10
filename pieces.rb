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

  @@opponents_color ={
    white:  :black,
    black:  :white
  }

  attr_accessor :type, :color, :symbol, :pos, :board

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
    # p "INSIDE MOVE_HELPER"
    # p end_pos.to_a
    # #print @board.stage
    # p "self.board id #{self.board.object_id}"
    @board[end_pos] = self
    #print @board.stage
    @board[self.pos] = nil
    #print @board.stage
    self.pos = Pos.new([end_pos[0],end_pos[1]])
    # print @board.stage
    # p "Inside: #{@board.object_id}"
    self.moved = true if self.type == :Pawn
  end

  def move(end_pos, dup_move = false)
    # p end_pos
    # p dup_move

    if !can_move?(end_pos) && dup_move == false
      raise InvalidMoveError
    elsif !can_move?(end_pos) && dup_move == true
      return nil
    end

    if @board[end_pos] != nil
      # p "making move"
      move_helper(end_pos)
      return :captured_piece
    else
      # p "making move"
      move_helper(end_pos)
    end
  end

  def piece_valid_moves
    valid_moves = []
    (0...8).each do |row|
      (0...8).each do |col|
        p = Pos.new([row,col])
         valid_moves << p if can_move?(p)
       end
     end
     valid_moves
  end

  def can_move?(end_pos)
    raise NotYetImplemented
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
    return false unless not_blocked?(all_moves)
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
    #p all_moves
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
  #replace with real king
  def can_move?(end_pos)
    return false if end_pos == self.pos
    return false unless on_board?(end_pos)
    return false unless self.pos.vertical_to?(end_pos) || self.pos.horizontal_to?(end_pos)
    return false if own_piece?(@board[end_pos])
    all_moves = self.pos.to(end_pos)
    return false if all_moves.empty?
    return false unless not_blocked?(all_moves)
    return false unless (self.pos - end_pos) != nil && (self.pos - end_pos).two_norm_square == 2
    return false if is_square_in_check?(end_pos, @@opponent_color[self.color])
    return true
  end
end

class Pawn < Piece
  #normal moves

  attr_accessor :moved

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
      return false unless (end_pos.rows - self.pos.rows) == delta || (end_pos.rows - self.pos.rows) == (delta * 2)
    elsif @moved == true && self.pos.vertical_to?(end_pos)
      return false unless (end_pos.rows - self.pos.rows) == delta
    end

    #checks for captures
    if self.pos.is_diag?(end_pos)
      return false unless end_pos.rows - self.pos.rows == delta && !@board[end_pos].nil?
    end

    #set flag for later moves
    return true
  end

end
