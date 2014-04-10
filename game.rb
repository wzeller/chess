

require './board.rb'
require 'debugger'

class PlayerMoveError < RuntimeError
end

class Game

  def initialize
    @board = Board.new
    @opponent_turn = {:white => :black, :black => :white}
    @framebuffer = [@board.stage, "Make a move: (start move, end move) e.g. 0,1,1,1:   ", "", "\n Turn \n"]
  end

  def play
    @own_king_in_check = false
    #erase dup board after finished
    turn = :white
    begin

    while true

      render


      #test if check
      dup_board = @board.dup
      @own_king_in_check = dup_board.is_board_in_check?(turn, @opponent_turn[turn])

      all_pos_self_moves = []
      #if so, test if checkmate

      #first get all self moves
      dup_board.get_pieces(turn).each {|piece| all_pos_self_moves += piece.piece_valid_moves}

      #debugger
      # p dup_board.get_pieces(turn)
      #next test if, after each move, king in check, you lose
      all_legal_moves = []
      all_pos_self_moves.each do |move|
        #make position?
        dup_move = true
        new_dup = dup_board.dup
        new_dup.get_pieces(turn).each do |piece|
          if piece.can_move?(move) == true
            piece.move(move, dup_move)
            # p piece.pos.to_a
            # p turn
            # p @opponent_turn[turn]
            # print new_dup.stage
            # p new_dup.object_id.to_s + " OUTSIDE OF MOVE"

            if not new_dup.is_board_in_check?(turn, @opponent_turn[turn])
              all_legal_moves << move
            end
          end
        end
      end


      # @framebuffer[2] = turn.to_s.upcase.colorize({color: :yellow})+"'s Turn: " + "\n"
      display_moves = []
      all_pos_self_moves.each {|move|  display_moves << move.to_a}
      puts display_moves.inspect + "\n"


      #checkmate if...
      if all_legal_moves.empty?
        puts "You lose -- checkmate!\n"
        break
      end

      if @own_king_in_check == true
       puts "you're in check\n\n"
      end

      @framebuffer[1] =  "Make a move: (start move, end move) e.g. 0,1,1,1:    \n" #0,1,1,1
      requested_move = gets
      raise PlayerMoveError if requested_move.nil?
      requested_move = requested_move.chomp.split(',').map(&:to_i)
      start_pos = Pos.new(requested_move[0..1])

      start_piece = @board[start_pos]
      end_pos = Pos.new(requested_move[2..3])

      raise PlayerMoveError if start_piece.nil? || start_piece.color != turn
      raise PlayerMoveError unless start_piece.piece_valid_moves.include?(end_pos)
      raise PlayerMoveError unless all_legal_moves.include?(end_pos)

      start_piece.move(end_pos)

      turn = @opponent_turn[turn]
      @framebuffer[0] = @board.stage

    end

    rescue PlayerMoveError
      puts "Invalid Move, try again"
      @framebuffer[0] = @board.stage
      #erase old duped board
      #redup board to test next user input
      retry
    end
  end


  def render
    print "\e[2J"  #clear screen
    print @framebuffer.join
    @framebuffer = []
  end


end

game = Game.new
game.play