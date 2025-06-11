require 'spec_helper'
require 'ronin/brute/credentials'

describe Ronin::Brute::Credentials do
  let(:username) { "username" }
  let(:password) { "password" }

  subject { described_class.new(username, password) }

  describe "#to_s" do
    it "must return colon-separated String of username/email and password" do
      expect(subject.to_s).to eq("#{username}:#{password}")
    end
  end

  describe "#to_a" do
    it "must return Array of username/email and password" do
      expect(subject.to_a).to eq([username, password])
    end
  end

  describe "#to_ary" do
    it "must return Array of username/email and password" do
      expect(subject.to_ary).to eq([username, password])
    end
  end
end
