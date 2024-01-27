require 'spec_helper'
require 'ronin/brute/cli/commands/list'
require_relative 'man_page_example'

describe Ronin::Brute::CLI::Commands::List do
  include_examples "man_page"
end
