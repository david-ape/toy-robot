module ToyRobot
  class Robot

    # The requirements are simple enough to manage the table
    # info within this class, but if/when these become more
    # complex then it would make sense to have a separate
    # Table or Surface class (for example, to tell you if
    # a certain move was possible)
    MIN_X = 0
    MAX_X = 4
    MIN_Y = 0
    MAX_Y = 4

    def initialize(commander)
      super()
      @commander = commander
    end

    def commander
      @commander
    end

    # takes a command string and tries to obey
    # returns a boolean success flag and an
    # explanation string describing what happened
    def obey(full_command)
      # TODO: Consider using a regex to do a syntax check here
      #       (might remove some edge cases and simplify code lower down)
      command, args = full_command.downcase.split(' ', 2)
      case command
      when 'place'
        place(args)
      when 'move','left','right','report'
        if placed?
          case command
          when 'move'
            return move
          when 'left'
            return left
          when 'right'
            return right
          when 'report'
            return report
          end
        else
          return false, cant_do_message("You must place me before issuing \"#{command}\" command")
        end
      else
        return false, cant_do_message("I don't understand \"#{full_command.strip}\"")
      end
    end

    private

    def place(arg_string)
      args = (arg_string || '').split(',')
      arg_quantity = args.length
      unless arg_quantity == 3
        return false, cant_do_message("Expecting 3 arguments for the place command, got #{arg_quantity}")
      end

      # Because the table surface is so simple and so small, we can
      # use a regex to validate x and y as integers and also their
      # range (0-4). If we wanted something more flexible, then we'd
      # use a regex to validate them as integers (e.g. \d) and then
      # check the range separately.

      unless args[0].strip.match(/^[01234]$/)
        return false, cant_do_message("Invalid X parameter #{args[0]}, must be 0-4")
      end
      x = args[0].to_i

      unless args[1].strip.match(/^[01234]$/)
        return false, cant_do_message("Invalid Y parameter #{args[1]}, must be 0-4")
      end
      y = args[1].to_i

      f_regex = /^([Nn][Oo][Rr][Tt][Hh]|[Ss][Oo][Uu][Tt][Hh]|[Ee][Aa][Ss][Tt]|[Ww][Ee][Ss][Tt])$/
      f = args[2].strip
      unless f.match(f_regex)
        return false, cant_do_message("Invalid F parameter #{f.capitalize}, expecting North, South, East or West")
      end

      @x = x
      @y = y
      @f = f.downcase
      return true, acknowledgment("I'm now at #{@x},#{@y},#{@f.capitalize}")
    end

    def move
      case @f
      when 'north'
        if @y < MAX_Y
          @y = @y+1
          return true, moved_message('north')
        else
          return false, cant_move_message('north')
        end
      when 'south'
        if @y > MIN_Y
          @y = @y-1
          return true, moved_message('south')
        else
          return false, cant_move_message('south')
        end
      when 'east'
        if @x < MAX_X
          @x = @x+1
          return true, moved_message('east')
        else
          return false, cant_move_message('east')
        end
      when 'west'
        if @x > MIN_X
          @x = @x-1
          return true, moved_message('west')
        else
          return false, cant_move_message('west')
        end
      end
    end

    def left
      new_direction = {
        'north' => 'west',
        'south' => 'east',
        'east' => 'north',
        'west' => 'south'
      }[@f]
      @f = new_direction
      return true, acknowledgment("turned left toward the #{@f}")
    end

    def right
      new_direction = {
        'north' => 'east',
        'south' => 'west',
        'east' => 'south',
        'west' => 'north'
      }[@f]
      @f = new_direction
      return true, acknowledgment("turned right toward the #{@f}")
    end

    def report
      # TODO: Is there are better way? It works writing to STDOUT here but feels wrong.
      puts "#{@x},#{@y},#{@f.upcase}"
      return true, acknowledgment("current position reported")
    end

    # Should be true if the robot has been properly placed
    def placed?
      !(@x.nil? || @y.nil? || @f.nil?)
    end

    def moved_message(direction)
      acknowledgment("moved #{direction}")
    end

    def cant_move_message(direction)
      cant_do_message("can't move any further #{direction}")
    end

    def cant_do_message(reason)
      # A reference to HAL in 2001, A Space Odyssey. If not amusing,
      # then we might want to make it more concise.
      "I'm sorry #{commander}, I'm afraid I can't do that (#{reason})"
    end

    def acknowledgment(result)
      "Affirmative #{commander}, #{result}"
    end
  end
end
