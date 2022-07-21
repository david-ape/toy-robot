RSpec.describe ToyRobot do
  it "has a version number" do
    expect(ToyRobot::VERSION).not_to be nil
  end

  context 'when run with -h' do
    subject { ToyRobot.run(["-h"]) }
    it "displays usage and exits" do
      # TODO: Figure out how to check the usage message
      #       (the exit seems to stop us being able to do a check
      #       like "expect... .to output(msg).to_stdout")
      expect { subject }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(0)
      end
    end
  end

  context 'when commands are supplied' do
    subject { ToyRobot.run(argv, io) }

    let(:argv) { [] }
    # TODO: Ideally we'd test with STDIN rather with a StringIO
    #       (or at least by mocking STDIN with a StringIO)
    let(:io) { StringIO.new(commands) }

    context 'when the command is unrecognised' do
      let(:commands) do
        <<~EOS
          BadCommand
        EOS
      end

      it 'reports an error' do
        expect { subject }.to output("I'm sorry Commander, I'm afraid I can't do that (I don't understand \"BadCommand\")\n").to_stdout
      end
    end

    ['quit','QUIT','exit','EXIT','stop','STOP','bye','BYE'].each do |quit_command |
      context 'when a quit command is given' do
        let(:commands) { quit_command }

        it 'exits' do
          expect { subject }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(0)
          end
        end
      end
    end

    ['help','HELP','wtf','WTF','wtf?','WTF?'].each do |help_command |
      context 'when a help command is given' do
        let(:commands) { help_command }

        it 'displays the help message' do
          expect { subject }.to output(ToyRobot::HELP_MSG).to_stdout
        end
      end
    end

    context 'when an invalid place command is given' do
      let(:commands) { 'place' }

      it 'reports an error' do
        expect { subject }.to output("I'm sorry Commander, I'm afraid I can't do that (Expecting 3 arguments for the place command, got(0)\n").to_stdout
      end
    end

    context 'when verbose is set' do
      let(:argv) { ['-v'] }

      context 'when an valid place command is given' do
        let(:commands) { 'place 1,2,North' }

        it 'reports success' do
          expect { subject }.to output("Yes Commander, I'm now at 1,2,North\n").to_stdout
        end
      end
    end

    context 'when verbose and name are set' do
      let(:argv) { ['-v','-n','Dave'] }

      context 'when an invalid command is given' do
        let(:commands) { 'badcommand' }

        it 'reports an error addressing Commander with the specified name' do
          expect { subject }.to output("I'm sorry Dave, I'm afraid I can't do that (I don't understand \"badcommand\")\n").to_stdout
        end
      end
    end
  end
end
