require "toy_robot/version"
require "toy_robot/robot"

module ToyRobot
  # This is the main entry point
  #
  # The io argument is a hack for testing. I'm
  # specifying a StringIO in my rspec tests
  # until I can figure out how to test
  # with STDIN
  def self.run(argv=[], io=STDIN)
    Cli.new(argv).run(io)
  end

  USAGE = <<~EOS
    toy_robot #{ToyRobot::VERSION}
    Usage: toy_robot [options] [<file]
      -h, --help             Show usage
      -n, --name YOUR NAME   How the robot should address you
      -v, --verbose          Enable verbose mode
  EOS

  HELP_MSG = <<~EOS
    This app lets you control a toy robot on a table top. The table top is broken
    into 25 locations with coordinates from (0,0) at the bottom left southwest
    corner, to (4,4) at the top right northeast corner. You start by placing the
    robot on the table grid facing a certain way, then you can tell it to move or
    turn or report its location. The robot will ignore commands that place it on an
    invalid location or which would cause it to move to an invalid location. You
    must place the robot before doing anything else (it will ignore other commands
    until you do).

    The commands are:

    PLACE X,Y,F (e.g. PLACE 0,1,NORTH)
    MOVE
    LEFT
    RIGHT
    REPORT

    There are additional commands as follows:

    HELP - show this message
    QUIT - shut down the app

    Enjoy :-)
  EOS

  class Error < StandardError; end

  class Cli
    def initialize(argv)
      process_args(argv)
    end

    def run(io)
      io.each do |command|
        execute_command(command)
      end
    end

    private

    def process_args(argv)
      argv.each_with_index do |option, i|
        case option.downcase
        when "-h", "--help"
          puts
          puts USAGE
          puts
          puts HELP_MSG
          exit
        when "-v", "--verbose"
          @verbose = true
        when '-n', '--name'
          @name = argv[i+1]
        else
          # TODO: Raise or report an unrecognised argument error.
          #       (Would need to make the arg processing a little
          #       more sophisticated - maybe use an arg processing
          #       gem.)
        end
      end
    end

    def execute_command(command_string)
      # Attempt to execute as a CLI command, otherwise
      # send the command to the robot
      unless CliCommand.new(command_string).execute
        success, explanation = robot.obey(command_string)
        puts explanation if verbose || !success
      end
    end

    # Create the robot if needed, otherwise just return it (i.e. create lazily)
    def robot
      @robot ||= Robot.new(name)
    end

    def name
      # If you want to risk being politically incorrect you could make the default
      # Master or Mistress (but one day the robots will rise up :-)
      @name ||= 'Commander'
    end

    def verbose
      @verbose
    end

    # A class for commands handled by the CLI (rather than the robot)
    class CliCommand
      def initialize(raw_command)
        @command = (raw_command || '').strip
      end

      def execute
        if valid?
          if quit?
            exit 0
          elsif help?
            puts HELP_MSG
          else
            # ignore empty commands
          end
          true
        else
          false
        end
      end

      private

      def valid?
        @valid ||= (empty? || quit? || help?)
      end

      def empty?
        @empty ||= @command.empty?
      end

      def quit?
        @quit ||= @command.downcase.match?(/^(quit|exit|stop|bye)$/)
      end

      def help?
        # help, wtf, or wtf?
        @help ||= @command.downcase.match?(/^(help|wtf\??)$/)
      end
    end
  end
end
