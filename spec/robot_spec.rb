RSpec.describe ToyRobot::Robot do
  subject(:robot) { ToyRobot::Robot.new('Commander') }

  it 'has a commander' do
    expect(robot.commander).to eq('Commander')
  end

  context 'when given an unrecognised command' do
    it 'returns false with an explanation' do
      success,explanation = robot.obey('Jump in the lake')
      expect(success).to be false
      expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (I don't understand \"Jump in the lake\")")
    end
  end

  ['Place', 'place 1', 'PLACE 1,3', 'Place 9,9,northwest'].each do |command|
    context 'when given a place command with invalid arguments' do
      it 'returns false with an explanation' do
        success,explanation = robot.obey(command)
        expect(success).to be false
        arg_string = command.split(' ')[1] || ''
        expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (Invalid argument(s) \"#{arg_string}\" for place command)")
      end
    end
  end

  context 'when given place command with a bad x' do
    it 'returns false with an explanation' do
      success,explanation = robot.obey('Place 9,2,North')
      expect(success).to be false
      expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (Invalid X parameter 9, must be 0-4)")
    end
  end

  context 'when given place command with a bad y' do
    it 'returns false with an explanation' do
      success,explanation = robot.obey('Place 0,50,South')
      expect(success).to be false
      expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (Invalid Y parameter 50, must be 0-4)")
    end
  end

  context 'when given place command with a bad f' do
    it 'returns false with an explanation' do
      success,explanation = robot.obey('Place 0,1,Southwest')
      expect(success).to be false
      expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (Invalid argument(s) \"0,1,southwest\" for place command)")
    end
  end

  context 'when given a valid place command' do
    it 'returns true with an acknowledgement' do
      success,explanation = robot.obey('Place 0,1,West')
      expect(success).to be true
      expect(explanation).to eq("Affirmative Commander, I'm now at 0,1,West")
    end
  end

  ['move','left','right','report'].each do |command |
    context 'when given a command before the robot is placed' do
      it 'returns false with an explanation' do
        success,explanation = robot.obey(command)
        expect(success).to be false
        expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (You must place me before issuing a \"#{command}\" command)")
      end
    end
  end

  ['0,0,South','0,0,West','4,4,North','4,4,East'].each do | placement |
    context 'when a requested move is not possible' do
      before do
        robot.obey("place #{placement}")
      end

      it 'returns false with an explanation' do
        direction = placement.split(',')[2].downcase
        success,explanation = robot.obey('move')
        expect(success).to be false
        expect(explanation).to eq("I'm sorry Commander, I'm afraid I can't do that (can't move any further #{direction})")
      end
    end
  end

  ['0,0,North','0,0,East','4,4,South','4,4,West'].each do | placement |
    context 'when a requested move is possible' do
      before do
        robot.obey("place #{placement}")
      end

      it 'returns true with an acknowledgement' do
        direction = placement.split(',')[2].downcase
        success,explanation = robot.obey('move')
        expect(success).to be true
        expect(explanation).to eq("Affirmative Commander, I have moved #{direction} to (#{robot.current_position_string})")
      end
    end
  end

  [['0,0,North','west'],['0,0,East','north'],['0,0,South','east'],['0,0,West','south']].each do | placement_and_new_direction |
    context 'when a left turn is commanded' do
      before do
        robot.obey("place #{placement_and_new_direction[0]}")
      end

      it 'returns true with an acknowledgement' do
        new_direction = placement_and_new_direction[1]
        success,explanation = robot.obey('left')
        expect(success).to be true
        expect(explanation).to eq("Affirmative Commander, turned left toward the #{new_direction}")
      end
    end
  end

  [['0,0,North','east'],['0,0,East','south'],['0,0,South','west'],['0,0,West','north']].each do | placement_and_new_direction |
    context 'when a right turn is commanded' do
      before do
        robot.obey("place #{placement_and_new_direction[0]}")
      end

      it 'returns true with an acknowledgement' do
        new_direction = placement_and_new_direction[1]
        success,explanation = robot.obey('right')
        expect(success).to be true
        expect(explanation).to eq("Affirmative Commander, turned right toward the #{new_direction}")
      end
    end
  end

  ['0,0,North','0,0,East','4,4,South','4,4,West'].each do | placement |
    context 'when a report is requested' do
      before do
        robot.obey("place #{placement}")
      end

      it 'returns true with an acknowledgement' do
        success = explanation = nil # instantiate so they are in scope for subsequent tests
        expect { success,explanation = robot.obey('report') }.to output("#{placement.upcase}\n").to_stdout
        expect(success).to be true
        expect(explanation).to eq("Affirmative Commander, current position reported")
      end
    end
  end

  ['',' ',"\t",nil].each do | command |
    context 'when a blank command is issued' do
      before do
        robot.obey("#{command}")
      end

      it 'returns true with an acknowledgement' do
        success,explanation = robot.obey(command)
        expect(success).to be true
        expect(explanation).to eq("Affirmative Commander, ignored blank command")
      end
    end
  end

  # Miscellaneous tests (the first three are from the spec)
  [[['PLACE 0,0,NORTH',
      'MOVE'],
     '0,1,NORTH'],
    [['PLACE 0,0,NORTH',
      'LEFT'],
     '0,0,WEST'],
    [['PLACE 1,2,EAST',
      'MOVE','MOVE','LEFT','MOVE'],
     '3,3,NORTH'],
   [['PLACE 0,0,NORTH',
     'MOVE','MOVE','MOVE','MOVE','MOVE'],
    '0,4,NORTH'],
   [['PLACE 0,0,EAST',
     'MOVE','MOVE','MOVE','MOVE','MOVE'],
    '4,0,EAST'],
   [['PLACE 4,4,SOUTH',
     'MOVE','MOVE','MOVE','MOVE','MOVE'],
    '4,0,SOUTH'],
   [['PLACE 4,4,WEST',
     'MOVE','MOVE','MOVE','MOVE','MOVE'],
    '0,4,WEST'],
  ].each do |commands_and_expected_position |
    context 'when multiple commands are issued' do
      before do
        commands_and_expected_position[0].each do |command|
          robot.obey(command)
        end
      end
      let(:expected) { commands_and_expected_position[1] }

      it 'reports the correct location after the last command' do
        expect { robot.obey('report') }.to output("#{expected}\n").to_stdout
      end
    end
  end
end
