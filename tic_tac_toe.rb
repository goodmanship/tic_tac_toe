require 'set'
WINNERS = [Set[1,2,3],Set[1,4,7],Set[1,5,9],Set[2,5,8],Set[3,5,7],Set[3,6,9],Set[4,5,6],Set[7,8,9]]
CORNER_CELLS = ['1','3','9','7'] # the order here is important for opposite_corner
EDGE_CELLS = ['2','4','8','6']

class Board < Array
  def initialize()
    self.replace ['1','2','3','4','5','6','7','8','9']
  end

  def print_board
    print " #{[self[0..2].join(" | "),self[3..5].join(" | "),self[6..8].join(" | ")].join(" \n---+---+---\n ")} \n"
  end

  def any_winners?( team )
    WINNERS.map do |w|
      if w.subset? team
        self.print_board
        p "Winner!"
        return true
      end
    end
    # if the board's full, tie
    if self.count('O') + self.count('X') >= 9
      self.print_board
      p "Tie!"
      return true
    end
    return false # no winners and no tie
  end

  def opposite_corner( c )
    i = CORNER_CELLS.index(c)
    opp_index = i + 2 > 3 ? i - 2 : i + 2
    CORNER_CELLS[opp_index]
  end
end

class TicTacToe
  def initialize(computer_goes_first=false)
    @board = Board.new
    @o = Set.new
    @x = Set.new

    computer_move if computer_goes_first
    @board.print_board
    print "Your turn, enter a cell number:\n"
    move(gets.chomp)
  end

  private

  # game mechanics

  def move( cell )
    # check if this is valid input and this cell is available
    if @board.include? cell
      pencil_in_x(cell.to_i)
      return if @board.any_winners?( @x )

      p "O moves to #{computer_move}"
      return if @board.any_winners?( @o )
    else
      p "invalid move, try again"
    end

    @board.print_board
    move(gets.chomp)
  end

  def pencil_in_o( cell )
    @board[cell-1] = "O"
    @o << cell
    cell
  end

  def pencil_in_x( cell )
    @board[cell-1] = "X"
    @x << cell
    p "X moves to #{cell}"
  end

  # AI methods

  def computer_move
    # Main AI algorithm method

    # Wikipedia:
    # Win: If the player has two in a row, they can place a third to get three in a row.
    # Block: If the opponent has two in a row, the player must play the third themself to block the opponent.
    # Fork: Create an opportunity where the player has two threats to win (two non-blocked lines of 2).
    # Blocking an opponent's fork:
    # Option 1: The player should create two in a row to force the opponent into defending, as long as it doesn't result in them creating a fork. For example, if "X" has a corner, "O" has the center, and "X" has the opposite corner as well, "O" must not play a corner in order to win. (Playing a corner in this scenario creates a fork for "X" to win.)
    # Option 2: If there is a configuration where the opponent can fork, the player should block that fork.
    # Center: A player marks the center. (If it is the first move of the game, playing on a corner gives "O" more opportunities to make a mistake and may therefore be the better choice; however, it makes no difference between perfect players.)
    # Opposite corner: If the opponent is in the corner, the player plays the opposite corner.
    # Empty corner: The player plays in a corner square.
    # Empty side: The player plays in a middle square on any of the 4 sides.

    cell = two_in_a_row(@o) # try to win
    cell ||= two_in_a_row(@x) # block winning move
    cell ||= take_fork(@o) # create a fork
    cell ||= block_fork # block a fork
    cell ||= pencil_in_o(5) if @board.include? '5' # take the center
    cell ||= take_opposite_corner # take opposite corner
    cell ||= check_cells(CORNER_CELLS) # take any corner
    cell ||= check_cells(EDGE_CELLS) # take an edge
  end

  def block_fork
    # this method will return the cell required to block opponent's fork or nil
    fork_cells = Set.new
    @board.map do |c|
      if !(c=="O" || c=="X")
        test_set = @x.|(Set[c.to_i])
        # check for opportunities (two in a row)
        opportunities = 0
        WINNERS.map do |w|
          if test_set.&(w).size > 1 # two in a row
            third = w.-(test_set).first # the third
            if @board.include? third.to_s # check if the third is free
              opportunities += 1
            end
          end
        end
        if opportunities > 1
          fork_cells << c.to_i
        end
      end
    end
    return nil if fork_cells.empty? # if there are no forks to block, move on
    candidate = force_away_from fork_cells
    if candidate
      return candidate
    else
      take_fork(@x) # if forcing using 2-in-a-row fails, try to take the fork cell
    end
  end

  def force_away_from( cells )
    # the goal is to create two-in-a-row so that your opponent has to move to a non-fork cell to prevent you from winning
    @board.map do |c|
      if !(c=="O" || c=="X") && !cells.include?(c.to_i) # don't block the fork directly (yet)
        test_set = @o.|(Set[c.to_i])
        WINNERS.map do |w|
          if test_set.&(w).size > 1 # two in a row
            third = w.-(test_set).first # the third
            if @board.include?(third.to_s) && !cells.include?(third) # check if the third is on the board AND not one of the bad cells
              pencil_in_o(third)
              return third
            end
          end
        end
      end
    end
    nil
  end

  def take_fork( team )
    # this method will return the cell required to create a fork for team or nil
    @board.map do |c|
      if !(c=="O" || c=="X")
        test_set = team.|(Set[c.to_i])
        # check for opportunities (two in a row)
        opportunities = 0
        WINNERS.map do |w|
          if test_set.&(w).size > 1 # two in a row
            third = w.-(test_set).first # the third
            if @board.include? third.to_s # check if the third is free
              opportunities += 1
            end
          end
        end
        if opportunities > 1
          pencil_in_o(c.to_i)
          return c.to_i
        end
      end
    end
    nil
  end

  def two_in_a_row( team )
    WINNERS.map do |w|
      if team.&(w).size > 1 # two in a row
        cell = w.-(team).first # the third
        if @board.include? cell.to_s # check if the third is free
          pencil_in_o(cell)
          return cell
        end
      end
    end
    return nil
  end

  def take_opposite_corner
    CORNER_CELLS.map do |c|
      if @x.include? c.to_i
        cell = @board.opposite_corner(c)
        if @board.include? cell
          pencil_in_o(cell.to_i)
          return cell.to_i
        end
      end
    end
    return nil
  end
  
  def check_cells( a )
    a.map do |c|
      if @board.include? c
        pencil_in_o(c.to_i)
        return c.to_i
      end
    end
    return nil
  end
end

TicTacToe.new(true)