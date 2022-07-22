# Toy Robot

#### What is this ?

Toy Robot is a ruby coding exercise that the nice people at [Mable](https://mable.com.au/) ask their potential candidates to do. The original repository is [here](https://github.com/bettercaring/toy-robot).

The application is a simulation of a toy robot moving on a square tabletop, of dimensions 5 units x 5 units. You control the robot by giving it commands.  The table top is broken into 25 locations with coordinates from (0,0) at the bottom left southwest corner, to (4,4) at the top right northeast corner. You start by placing the  robot on the table grid facing a certain direction (North, South, East or West). Then you can tell it to move or turn or report its location. The robot will ignore commands that place it on an invalid location or which would cause it to move to an invalid location. You must place the robot before doing anything else (it will ignore other commands until you do).

The commands are:

* PLACE X,Y,F (e.g. PLACE 0,1,NORTH)
* MOVE
* LEFT
* RIGHT
* REPORT
* HELP
* QUIT

PLACE will put the toy robot on the table in position X,Y and facing NORTH, SOUTH, EAST or WEST. The origin (0,0) can be considered to be the SOUTH WEST most corner. The first valid command to the robot is a PLACE command (other commands will be ignored until a valid PLACE command is given).

MOVE will move the toy robot one unit forward in the direction it is currently
  facing.

LEFT and RIGHT will rotate the robot 90 degrees in the specified direction
  without changing the position of the robot.

REPORT will announce the X,Y and F of the robot.

HELP will display usage information and the list of commands.

QUIT will exit the app.

### Example Input and Output
a)
```
PLACE 0,0,NORTH
MOVE
REPORT
```
Output: `0,1,NORTH`

b)
```
PLACE 0,0,NORTH
LEFT
REPORT
```
Output: `0,0,WEST`

c)
```
PLACE 1,2,EAST
MOVE
MOVE
LEFT
MOVE
REPORT
```
Output: `3,3,NORTH`

## Installation

1. It is recommended that you have ruby 2.7.3 and bundler 2.1.4 installed

2. Clone or pull the latest version of the git repository.

3. cd to the repository

4. Run:

    `bin/setup`

5. If you want to install the gem (optional), then also run:

    `bundle exec rake install`

## Usage

    toy_robot [options] # if gem installed

      or

    ruby -Ilib ./exe/toy_robot [options]

The options are:

    -h, --help             Show usage
    -n, --name YOUR NAME   How the robot should address you
    -v, --verbose          Enable verbose mode

It is recommended that new users use the verbose and name options. Verbose provides more feedback and name personalises the experience. E.g.

    ruby -Ilib ./exe/toy_robot -v -n Dave

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Because it is a gem, there are a lot of boilerplate files. The interesting ones are in the exe, lib, and spec directories.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Suggested further work

- Add integration tests with [Cucumber and/or Aruba](https://bundler.io/guides/creating_gem.html#testing-a-command-line-interface)
- Mark up for RDoc or Yard documentation
- Push the gem to rubygems

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/david-ape/toy_robot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/david-ape/toy_robot/blob/master/CODE_OF_CONDUCT.md).

## License

See [license](https://github.com/david-ape/toy-robot/blob/main/LICENSE.txt).

## Code of Conduct

Everyone interacting in the ToyRobot project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/david-ape/toy-robot/blob/main/CODE_OF_CONDUCT.md).
