require 'spec_helper'
require 'ronin/brute/cli/commands/run'
require_relative 'man_page_example'

describe Ronin::Brute::CLI::Commands::Run do
  include_examples "man_page"
end
