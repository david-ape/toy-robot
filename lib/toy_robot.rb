require "toy_robot/version"
require "toy_robot/robot"

module ToyRobot
  class Error < StandardError; end

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

  # This is the main entry point
  #
  # The io argument is a hack for testing. I'm
  # specifying a StringIO in my rspec tests
  # until I can figure out how to test
  # with STDIN
  def self.run(argv=[], io=STDIN)
    # Clear instance vars in case we are running multiple times
    @robot = nil
    @name = nil
    @verbose = nil

    process_args(argv)

    io.each do |command|
      # Add some quit commands (^D will also work)
      # If we wanted it tighter, then we'd just have one quit command
      if ['quit','exit','stop','bye'].include? command.strip.downcase
        exit 0
      end
      # And give the user a way to get help
      # Again if we wanted it tighter, then we'd lose the wtfs and just have help
      if ['help','wtf','wtf?'].include? command.strip.downcase
        puts HELP_MSG
      else
        # Otherwise we start commanding the robot to do stuff
        # if their is a non-empty command.
        unless command.strip.empty?
          success, explanation = robot.obey(command)
          puts explanation if verbose || !success
        end
      end
    end
  end

  def self.process_args(argv)
    argv.each_with_index do |option, i|
      case option.downcase
      when "-h", "--help"
        puts
        puts "toy_robot #{ToyRobot::VERSION}"
        puts "Usage: toy_robot [options] [<file]"
        puts "  -h, --help             Show usage"
        puts "  -n, --name YOUR NAME   How the robot should address you"
        puts "  -v, --verbose          Enable verbose mode"
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
        #       sophisticated.)
      end
    end
  end

  # Create the robot if needed, otherwise just return it (i.e. create lazily)
  def self.robot
    @robot ||= Robot.new(name)
  end

  def self.name
    # If you want to risk being politically incorrect you could make the default
    # Master or Mistress (but one day the robots will rise up :-)
    @name ||= 'Commander'
  end

  def self.verbose
    @verbose
  end

end
