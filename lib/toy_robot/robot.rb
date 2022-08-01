module ToyRobot

  # Class to manage the tabletop constraints
  class Surface
    def initialize(min_x=0, max_x=4, min_y=0, max_y=4)
      @min_x = min_x
      @max_x = max_x
      @min_y = min_y
      @max_y = max_y
    end

    def valid_x?(x)
      (x >= @min_x) && (x <= @max_x)
    end

    def valid_y?(y)
     (y >= @min_y) && (y <= @max_y)
    end

    def x_range
      "#{@min_x}-#{@max_x}"
    end

    def y_range
      "#{@min_y}-#{@max_y}"
    end
  end

  # class to manage the robot
  class Robot
    attr_accessor :x, :y, :f
    attr_reader :surface

    def initialize(commander)
      @commander = commander
      @surface = Surface.new
    end

    # name of the commander
    def commander
      @commander
    end

    # takes a command string and tries to obey
    # returns a boolean success flag and an
    # explanation string describing what happened
    def obey(command_string)
      begin
        message = Parser.parse(command_string)
                        .execute(self, @surface)
        [true, acknowledgment(message)]
      rescue ToyRobot::Error => e
        [false, cant_do_message(e.message)]
      end
    end

    def say(message)
      puts message
    end

    def current_position
      [@x, @y, @f]
    end

    def current_position_string
      "#{@x},#{@y},#{@f&.capitalize}"
    end

    def place(x,y,f)
      @x = x
      @y = y
      @f = f
    end

    # Should be true if the robot has been placed
    def placed?
      @x && @y && @f
    end

    private

    def cant_do_message(reason)
      # A reference to HAL in 2001, A Space Odyssey. If not amusing,
      # then we might want to make it more concise.
      "I'm sorry #{commander}, I'm afraid I can't do that (#{reason})"
    end

    def acknowledgment(result)
      "Affirmative #{commander}, #{result}"
    end

    # Class to parse a string and returns a command
    # that can be executed (or throws an exception)
    class Parser
      def initialize(command_string)
        @command_string = (command_string&.strip) || ''
      end

      # syntactic sugar
      def self.parse(command_string)
        new(command_string).parse
      end

      def parse
        # Split by first whitespace into the command plus an optional argument string
        command_name, arg_string = @command_string.strip.downcase.split(' ',2)

        raise ParserError, "I don't understand \"#{@command_string}\"" unless valid_command?(command_name)
        build_command(command_name, arg_string)
      end

      private

      def build_command(command_name, arg_string)
        if command_name.nil?
          klass = NoopCommand
        else
          klass = Object.const_get("ToyRobot::Robot::#{command_name.capitalize}Command")
        end
        klass.new(command_name, arg_string)
      end

      def valid_command?(command_name)
        command_name.nil? ||
          %w[place move left right report].include?(command_name)
      end
    end

    # Abstract class - parent of all commands
    class Command
      def initialize(command_name, arg_string)
        @command_name = command_name
        @arg_string = arg_string&.strip || ''
        unless arg_string_valid?
          raise ToyRobot::InvalidArgumentError, "Invalid argument(s) \"#{arg_string}\" for #{command_name} command"
        end
      end

      def execute(robot, surface)
        # override
        raise NotImplementedError
      end

      private

      def arg_string_valid?
        # override if arguments are expected
        @arg_string.empty?
      end

      def check_placed(robot)
        unless robot.placed?
          raise ExecutionError, "You must place me before issuing a \"#{@command_name}\" command"
        end
      end
    end

    class NoopCommand < Command
      def execute(robot, surface)
        # do nothing
        "ignored blank command"
      end
    end

    class PlaceCommand < Command
      def execute(robot, surface)
        args = @arg_string.split(/\s*,\s*/)
        x = args[0].to_i
        y = args[1].to_i
        f = args[2].downcase

        unless surface.valid_x?(x)
          raise ExecutionError, "Invalid X parameter #{x}, must be #{surface.x_range}"
        end

        unless surface.valid_y?(y)
          raise ExecutionError, "Invalid Y parameter #{y}, must be #{surface.y_range}"
        end

        robot.place(x,y,f)
        "I'm now at #{x},#{y},#{f.capitalize}"
      end

      private

      def arg_string_valid?
        @arg_string.downcase.match?(/^\d+\s*,\s*\d+\s*,\s*(north|south|east|west)$/)
      end
    end

    class MoveCommand < Command
      def execute(robot, surface)
        check_placed(robot)

        x,y,f = robot.current_position
        case f.downcase
        when 'north'
          if surface.valid_y?(y+1)
            robot.y = y+1
            return moved_message('north', robot.current_position_string)
          end
        when 'south'
          if surface.valid_y?(y-1)
            robot.y = y-1
            return moved_message('south', robot.current_position_string)
          end
        when 'east'
          if surface.valid_x?(x+1)
            robot.x = x+1
            return moved_message('east', robot.current_position_string)
          end
        when 'west'
          if surface.valid_x?(x-1)
            robot.x = x-1
            return moved_message('west', robot.current_position_string)
          end
        end
        raise ExecutionError, cant_move_message(f.downcase)
      end

      private

      def moved_message(direction, current_position_string)
        "I have moved #{direction} to (#{current_position_string})"
      end

      def cant_move_message(direction)
        "can't move any further #{direction}"
      end
    end

    class LeftCommand < Command
      def execute(robot, surface)
        check_placed(robot)
        robot.f = {
          'north' => 'west',
          'south' => 'east',
          'east' => 'north',
          'west' => 'south'
        }[robot.f.downcase]
        "turned left toward the #{robot.f}"
      end
    end

    class RightCommand < Command
      def execute(robot, surface)
        check_placed(robot)
        robot.f = {
          'north' => 'east',
          'south' => 'west',
          'east' => 'south',
          'west' => 'north'
        }[robot.f.downcase]
        "turned right toward the #{robot.f}"
      end
    end

    class ReportCommand < Command
      def execute(robot, surface)
        check_placed(robot)
        x,y,f = robot.current_position
        robot.say "#{x},#{y},#{f.upcase}"
        "current position reported"
      end
    end
  end
end
