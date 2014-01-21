class TicTacToe
  require 'set'
  def initialize()
    @winners = [Set[1,2,3],Set[1,4,7],Set[1,5,9],Set[2,5,8],Set[3,5,7],Set[3,6,9],Set[4,5,6],Set[7,8,9]]
    @board = ['1','2','3','4','5','6','7','8','9']
    @corner_cells = ['1','3','9','7'] # the order here is important for opposite_corner
    @edge_cells = ['2','4','8','6']
    @o = Set.new
    @x = Set.new

    print_board
    print "X goes first, enter a cell number:\n"
    move(gets.chomp)
  end

  def move( cell )
    # check if this is valid input and this cell is available
    if @board.include? cell
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
    # Opposite corner: If the opponent is in the corner, the player plays the opposite corner.
    # Empty corner: The player plays in a corner square.
    # Empty side: The player plays in a middle square on any of the 4 sides.

    # AI Algorithm

    # try to win
    cell = two_in_a_row(@o)
    # block winning move
    cell ||= two_in_a_row(@x)
    # create a fork
    cell ||= take_fork(@o)
    # block a fork
    cell ||= block_fork
    # take the center
    cell ||= pencil_in_o(5) if @board.include? '5'
    # take opposite corner
    cell ||= take_opposite_corner
    # take any corner
    cell ||= take_free_corner
    # take an edge
    cell ||= take_free_edge

    # Choose randomly:
    # a = @board.select{ |t| t.to_i > 0 && t.to_i < 10 }
    # m = rand(a.length-1)
    # pencil_in_o( a[m].to_i )
  end

  def block_fork
    # this method will return the cell required to create a fork for @o or nil
    fork_cells = Set.new
    @board.map do |c|
      if !(c=="O" || c=="X")
        test_set = @o.|(Set[c.to_i])
        # check for opportunities (two in a row)
        opportunities = 0
        @winners.map do |w|
          if test_set.&(w).size > 1 # two in a row
            third = w.-(test_set).first # the third
            if @board.include? third.to_s # check if the third is free
              opportunities += 1
            end
          end
        end
        if opportunities > 1
          p "FORK DETECTED...."
          fork_cells << c.to_i
        end
      end
    end
    
    candidate = force_away_from fork_cells
    # if forcing using 2-in-a-row fails, try to take the fork cell
    if candidate
      return candidate
    else
      take_fork(@x)
    end
  end

  def force_away_from( cells )
    # the goal is to create two-in-a-row so that your opponent has to move to a non-fork cell to prevent you from winning
    @board.map do |c|
      if !(c=="O" || c=="X")
        test_set = @o.|(Set[c.to_i])
        @winners.map do |w|
          if test_set.&(w).size > 1 # two in a row
            cell = w.-(test_set).first # the third
            if @board.include?(cell.to_s) && !cells.include?(cell) # check if the third is on the board AND not one of the bad cells
              p "FORK AVOIDED"
              pencil_in_o(cell)
              return cell
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
        @winners.map do |w|
          if test_set.&(w).size > 1 # two in a row
            third = w.-(test_set).first # the third
            if @board.include? third.to_s # check if the third is free
              opportunities += 1
            end
          end
        end
        if opportunities > 1
          p "FORK"
          pencil_in_o(c.to_i)
          return c.to_i
        end
      end
    end
    nil
  end
  
  def has_fork( test_set )
    
  end

  def two_in_a_row( team )
    @winners.map do |w|
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
    @corner_cells.map do |c|
      if @x.include? c.to_i
        cell = opposite_corner(c)
        if @board.include? cell
          pencil_in_o(cell.to_i)
          return cell.to_i
        end
      end
    end
    return nil
  end

  def opposite_corner( c )
    i = @corner_cells.index(c)
    opp_index = i + 2 > 3 ? i - 2 : i + 2
    @corner_cells[opp_index]
  end

  def take_free_corner
    check_cells(@corner_cells)
  end
  
  def take_free_edge
    check_cells(@edge_cells)
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
      print_board
      p "Tie!"
      return true
    end
    return false # no winners and no tie
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

  def print_board
    print " #{[@board[0..2].join(" | "),@board[3..5].join(" | "),@board[6..8].join(" | ")].join(" \n---+---+---\n ")} \n"
  end
end

TicTacToe.new()