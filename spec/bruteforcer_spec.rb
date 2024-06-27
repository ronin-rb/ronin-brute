require 'spec_helper'
require 'ronin/brute/bruteforcer'

describe Ronin::Brute::Bruteforcer do
  let(:usernames) { %w[foo bar baz] }
  let(:passwords) { %w[test password password123] }

  subject do
    described_class.new(usernames: usernames, passwords: passwords)
  end

  describe "#each_credential" do
    it "must yield every combination of username and password from #usernames and #passwords" do
      expect { |b|
        subject.each_credential(&b)
      }.to yield_successive_args(
        ['foo', 'test'],
        ['foo', 'password'],
        ['foo', 'password123'],
        ['bar', 'test'],
        ['bar', 'password'],
        ['bar', 'password123'],
        ['baz', 'test'],
        ['baz', 'password'],
        ['baz', 'password123']
      )
    end
  end
end
