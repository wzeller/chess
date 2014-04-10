require './position.rb'
require './pieces.rb'
require 'colorize'
require 'debugger'


class Board
  attr_accessor :board, :white_pieces, :black_pieces
  def initialize(place_piece = true)
    make_board(place_piece)
    color_board
    @captured_pieces = []
    @black_pieces = []
    @white_pieces = []
    #@get_pieces = {:white => @white_pieces, :black => @black_pieces}
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

  def get_pieces(turn)
    return @black_pieces if turn ==:black
    return @white_pieces if turn ==:white
  end

  def make_board(place_piece)

    @board = Array.new(8){Array.new(8)}

    if place_piece == true
      @black_pieces = [Rook.new(:black,Pos.new([0,0]),self),
                  Knight.new(:black,Pos.new([0,1]),self),
                  Bishop.new(:black,Pos.new([0,2]),self),
                  Queen.new(:black,Pos.new([0,3]),self),
                  King.new(:black,Pos.new([0,4]),self),
                  Bishop.new(:black,Pos.new([0,5]),self),
                  Knight.new(:black,Pos.new([0,6]),self),
                  Rook.new(:black,Pos.new([0,7]),self)]
      8.times do |i|
        @black_pieces << Pawn.new(:black, Pos.new([1,i]), self)
      end

      @white_pieces = [Rook.new(:white, Pos.new([7,0]),self),
                  Knight.new(:white, Pos.new([7,1]),self),
                  Bishop.new(:white, Pos.new([7,2]),self),
                  Queen.new(:white, Pos.new([7,3]),self),
                  King.new(:white, Pos.new([7,4]),self),
                  Bishop.new(:white, Pos.new([7,5]),self),
                  Knight.new(:white, Pos.new([7,6]),self),
                  Rook.new(:white, Pos.new([7,7]),self)]
      8.times do |i|
        @white_pieces << Pawn.new(:white, Pos.new([6,i]), self)
      end

      (@black_pieces + @white_pieces).each {|piece| self[piece.pos] = piece}

    end
  end

  def color_board
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

  def dup
    dup_board = Board.new(false)
    # p "Inside dup -- before making piece: #{dup_board.object_id}"
    # (@black_pieces + @white_pieces).each do
    #   |piece| dup_board[piece.pos] = Object::const_get(piece.type.to_s).new(piece.color, Pos.new([piece.pos[0],piece.pos[1]]),dup_board)
    # end
    (0...8).each do |row|
      (0...8).each do |col|
         unless @board[row][col] == nil
           # old_piece_type = @board[row][col].type
           # old_piece_color = @board[row][col].color
           # new_piece = Object::const_get(old_piece_type.to_s).new(old_piece_color, Pos.new([row,col]),dup_board)
           old_piece = @board[row][col]
           new_piece = old_piece.class.new(old_piece.color, Pos.new([row,col]), dup_board)
           # p "Piece board: #{new_piece.board.object_id}"
           # p "Inside dup -- after making piece: #{dup_board.object_id}"
           dup_board.board[row][col] = new_piece
           dup_board.black_pieces << new_piece if new_piece.color == :black
           dup_board.white_pieces << new_piece if new_piece.color == :white
         end
      end
    end
    dup_board
  end

  def stage
    buffer = Array.new(8){Array.new(8)}
    frame = []
    frame << "   0  1  2  3  4  5  6  7\n"
    (0...8).each do |row|
      frame << "#{row} "
      (0...8).each do |col|
        square = @board_color[row][col]
        if @board[row][col].nil?
          frame << "   ".colorize({background: square})
        else
          piece = @board[row][col]
          frame << (" " + piece.symbol + " ").colorize({color: piece.color, background: square, bold: true})
        end
      end
      frame <<  "\n"
    end
    return frame.join
  end

#first test after move is made -- dup board, see if king square is in check, ASSUMING
#validity -- if it is, return InvalidMoveError, else, throw out duped board, run move method

#Other alternative is dup board, generate all possible moves for own color, and if
#none of those moves result in king NOT being in check, return checkmate

  def is_board_in_check?(self_turn, opponent_turn)
    king_pos =  self.board.flatten.select {|piece| !piece.nil? && piece.type == :King && piece.color == self_turn}[0].pos
    all_pos_opponent_moves = []
    #test if check
    self.get_pieces(opponent_turn).each {|piece| all_pos_opponent_moves += piece.piece_valid_moves}

    if all_pos_opponent_moves.include?(king_pos)
      return true
    end

    return false
  end

  def is_square_in_check?(square, opponent_color)
    square = Pos.new(square)
    (0...8).each do |row|
      (0...8).each do |col|
        next if @board[row][col].nil?
        next unless @board[row][col].color == opponent_color

        #skip king for now
        next if @board[row][col].type == :King

        return true if @board[row][col].can_move?(square)
      end
    end
    return false
  end

  def is_checkmate?(turn, opponent_turn)
    all_pos_self_moves = []
    all_pos_valid_moves = []
    self.get_pieces(turn).each {|piece| all_pos_self_moves << piece.piece_valid_moves}
    #next test if, after each move, king in check, you lose
    all_pos_self_moves.each do |move|
      #make position?
      new_dup = self.dup

      new_pos = new_dup.get_pieces(turn).each do |piece|
        if piece.can_move?(move) == true
          piece.move(move)
          all_pos_valid_moves << move unless new_dup.is_board_in_check?(turn, opponent_turn[turn])
        end
        new_dup = self.dup
      end
    end
      #checkmate if...
      return true if all_pos_self_moves.empty?
      return false
    end
end

# board = Board.new
#
# pos1 = [7,1]
# pos2 = [5,2]
# pos3 = [6,3]
# pos4 = [4,3]
# pos5 = [7,3]
# pos6 = [5,3]
# pos7 = [3,5]
# pos8 = [3,0]
# pos9 = [1,0]
# pos10 = [0,0]
# pos11 = [1,0]
# board[Pos.new(pos1)].move(Pos.new(pos2))
# board[Pos.new(pos3)].move(Pos.new(pos4))
# board[Pos.new(pos5)].move(Pos.new(pos6))
# board[pos6].move(Pos.new(pos7))
# board[pos7].move(Pos.new(pos8))
# board[pos8].move(Pos.new(pos9))
# board[pos10].move(pos11)
# p board.is_square_in_check?([5,2], :white)
# p board.is_square_in_check?([6,0], :black)
# print board.stage
# d =board.dup
# print d.stage
# p board.object_id
# p d.object_id

