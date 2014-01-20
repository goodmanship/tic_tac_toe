class TicTacToe
  def initialize()
    @t = [1,2,3,4,5,6,7,8,9]
    print_board
    print "You go first\n"
    move(gets.chomp)
  end

  def move( cell )
    if @t.include? cell.to_i
      p "you move to #{cell}"
    else
      p "invalid move, try again"
      move(gets.chomp)
    end
  end

  def computer_move
  end

  def print_board
    print " #{[@t[0..2].join(" | "),@t[3..5].join(" | "),@t[6..8].join(" | ")].join(" \n---+---+---\n ")} \n"
  end
end

TicTacToe.new()