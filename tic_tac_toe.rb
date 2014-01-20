class TicTacToe
  require 'set'
  def initialize()
    # these are the winning combinations
    @winners = [[1,2,3],[1,4,7],[1,5,9],[2,5,8],[3,5,7],[3,6,9],[4,5,6],[7,8,9]]
    @winners = @winners.map{ |w| w.to_set }
    # @t is used to print out the current state of the board
    @t = ['1','2','3','4','5','6','7','8','9']
    @corner_cells = ['1','3','7','9']

    # @o and @x are the cells with O's and X's
    @o = Set.new
    @x = Set.new

    print_board
    print "X goes first\n"
    move(gets.chomp)
  end

  def move( cell )
    # check if this is valid input and this cell is available
    if @t.include? cell
      pencil_in_x(cell.to_i) # also prints an announcement
      return if any_winners?( @x )

      p "O moves to #{computer_move}"
      return if any_winners?( @o )
    else
      p "invalid move, try again"
    end

    print_board
    move(gets.chomp)
  end

  def computer_move
    # Wikipedia:
    # Win: If the player has two in a row, they can place a third to get three in a row.
    # Block: If the opponent has two in a row, the player must play the third themself to block the opponent.
    # TODO Fork: Create an opportunity where the player has two threats to win (two non-blocked lines of 2).
    # Blocking an opponent's fork:
    # TODO Option 1: The player should create two in a row to force the opponent into defending, as long as it doesn't result in them creating a fork. For example, if "X" has a corner, "O" has the center, and "X" has the opposite corner as well, "O" must not play a corner in order to win. (Playing a corner in this scenario creates a fork for "X" to win.)
    # TODO Option 2: If there is a configuration where the opponent can fork, the player should block that fork.
    # Center: A player marks the center. (If it is the first move of the game, playing on a corner gives "O" more opportunities to make a mistake and may therefore be the better choice; however, it makes no difference between perfect players.)
    # TODO Opposite corner: If the opponent is in the corner, the player plays the opposite corner.
    # Empty corner: The player plays in a corner square.
    # Empty side: The player plays in a middle square on any of the 4 sides.
    # try to win
    cell = two_in_a_row(@o)
    return cell if cell
    # block winning move
    cell = two_in_a_row(@x)
    return cell if cell
    # take the center
    return pencil_in_o(5) if @t.include? '5'
    # take opposite corner
    cell = take_opposite_corner
    return cell if cell
    # take any corner
    cell = take_free_corner
    return cell if cell
    # take an edge
    return take_free_edge
    # Choose randomly:
    a = @t.select{ |t| t.to_i > 0 && t.to_i < 10 }
    m = rand(a.length-1)
    pencil_in_o( a[m].to_i )
  end

  def two_in_a_row( team )
    @winners.map do |w|
      if team.&(w).size > 1 # two in a row
        cell = w.-(team).first # the third
        if @t.include? cell.to_s # check if the third is free
          pencil_in_o(cell)
          return cell
        end
      end
    end
    return false
  end

  def take_opposite_corner
    @corner_cells.map do |c|
      if @x.include? c.to_i
        
      end
    end
    return false
  end

  def opposite_corner(c)
    @corner_cells.find(c)
  end

  def take_free_corner
    check_cells(@corner_cells)
  end
  
  def take_free_edge
    check_cells(['2','4','6','8'])
  end
  
  def check_cells( a )
    a.map do |c|
      if @t.include? c
        pencil_in_o(c.to_i)
        return c.to_i
      end
    end
    return false
  end

  def any_winners?( team )
    @winners.map do |w|
      if w.subset? team
        print_board
        p "Winner!"
        return true
      end
    end
    # if the board's full, tie
    if @x.length + @o.length >= 9
      p "Tie!"
      return true
    end
    return false # no winners and no tie
  end

  def pencil_in_o( cell )
    @t[cell-1] = "O"
    @o << cell
    cell
  end

  def pencil_in_x( cell )
    @t[cell-1] = "X"
    @x << cell
    p "X moves to #{cell}"
  end

  def print_board
    print " #{[@t[0..2].join(" | "),@t[3..5].join(" | "),@t[6..8].join(" | ")].join(" \n---+---+---\n ")} \n"
  end
end

TicTacToe.new()