require 'spec_helper'
require 'ronin/brute/cli/bruteforcer_command'
require 'ronin/brute/bruteforcer'

describe Ronin::Brute::CLI::BruteforcerCommand do
  module TestBruteforcerCommand
    class TestBruteforcer < Ronin::Brute::Bruteforcer
      register 'test_bruteforcer_command'
    end

    class TestCommand < Ronin::Brute::CLI::BruteforcerCommand
    end
  end

  let(:bruteforcer_class) { TestBruteforcerCommand::TestBruteforcer }
  let(:command_class) { TestBruteforcerCommand::TestCommand }
  subject { command_class.new }

  describe "#load_bruteforcer" do
    let(:id) { bruteforcer_class.id }

    before do
      expect(Ronin::Brute).to receive(:load_class).with(id).and_return(bruteforcer_class)
    end

    it "must load the bruteforcer class and return the bruteforcer class" do
      expect(subject.load_bruteforcer(id)).to be(bruteforcer_class)
    end

    it "must also set #bruteforcer_class" do
      subject.load_bruteforcer(id)

      expect(subject.bruteforcer_class).to be(bruteforcer_class)
    end
  end

  describe "#load_bruteforcer_from" do
    let(:file) { "path/to/bruteforcer/file.rb" }

    before do
      expect(Ronin::Brute).to receive(:load_class_from_file).with(file).and_return(bruteforcer_class)
    end

    it "must load the bruteforcer class and return the bruteforcer class" do
      expect(subject.load_bruteforcer_from(file)).to be(bruteforcer_class)
    end

    it "must also set #bruteforcer_class" do
      subject.load_bruteforcer_from(file)

      expect(subject.bruteforcer_class).to be(bruteforcer_class)
    end
  end

  describe "#initialize_bruteforcer" do
    let(:usernames) { %w[admin root] }
    let(:passwords) { %w[secret password1] }

    before { subject.load_bruteforcer(bruteforcer_class.id) }

    it "must initialize a new bruteforcer object using #bruteforcer_class" do
      bruteforcer = subject.initialize_bruteforcer(usernames: usernames, passwords: passwords)

      expect(bruteforcer).to be_kind_of(bruteforcer_class)
    end

    it "must also set #bruteforcer" do
      subject.initialize_bruteforcer(usernames: usernames, passwords: passwords)

      expect(subject.bruteforcer).to be_kind_of(bruteforcer_class)
    end
  end
end
