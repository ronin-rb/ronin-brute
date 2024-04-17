require 'spec_helper'
require 'ronin/brute/http_bruteforcer'

describe Ronin::Brute::HTTPBruteforcer do
  it "must inherit from Ronin::Brute::NetworkBruteforcer" do
    expect(described_class).to be < Ronin::Brute::NetworkBruteforcer
  end

  it "must set .port to 80" do
    expect(described_class.port).to eq(80)
  end

  it "must set .ssl_port to 443" do
    expect(described_class.ssl_port).to eq(443)
  end

  describe ".bruteforcer_type" do
    subject { described_class }

    it "must return :http" do
      expect(subject.bruteforcer_type).to eq(:http)
    end
  end

  describe "params" do
    subject { described_class }

    it "must define a 'http_proxy' param" do
      expect(subject.params[:http_proxy]).to_not be_nil
      expect(subject.params[:http_proxy].desc).to eq("The HTTP proxy to use")
    end

    it "must define a 'user_agent' param" do
      expect(subject.params[:user_agent]).to_not be_nil
      expect(subject.params[:user_agent].type).to be_kind_of(Ronin::Core::Params::Types::Enum)
      expect(subject.params[:user_agent].type.values).to eq(
        [
          :random,
          :chrome,
          :firefox,
          :safari,
          :linux,
          :macos,
          :windows,
          :iphone,
          :ipad,
          :android
        ] + Ronin::Support::Network::HTTP::UserAgents::ALIASES.keys
      )
      expect(subject.params[:user_agent].desc).to eq("The HTTP User-Agent to select")
    end

    it "must define a 'user_agent_string' param" do
      expect(subject.params[:user_agent_string]).to_not be_nil
      expect(subject.params[:user_agent_string].desc).to eq("The raw HTTP User-Agent string to use")
    end
  end

  module TestHTTPBruteforcer 
    class TestBruteforcer < Ronin::Brute::HTTPBruteforcer
    end
  end

  let(:test_class) { TestHTTPBruteforcer::TestBruteforcer }

  let(:host) { 'example.com' }
  let(:port) { 80 }
  let(:params) do
    {host: host, port: port}
  end

  let(:usernames) { %w[bob alice eve] }
  let(:passwords) { %w[password test123 hunter2] }

  subject do
    test_class.new(
      params:    params,
      usernames: usernames,
      passwords: passwords
    )
  end

  describe "#http_proxy" do
    let(:proxy) { 'http://example.com:8080' }

    subject do
      test_class.new(
        params:    params.merge(http_proxy: proxy),
        usernames: usernames,
        passwords: passwords
      )
    end

    it "must return params[:http_proxy]" do
      expect(subject.http_proxy).to be(subject.params[:http_proxy])
    end
  end

  describe "#http_headers" do
    it "must return an empty Hash by default" do
      expect(subject.http_headers).to eq({})
    end
  end

  describe "#http_user_agent" do
    context "when params[:user_agent] is set" do
      let(:user_agent) { :random }

      subject do
        test_class.new(
          params: params.merge(user_agent: user_agent),
          usernames: usernames,
          passwords: passwords
        )
      end

      it "must return params[:user_agent]" do
        expect(subject.http_user_agent).to be(subject.params[:user_agent])
      end
    end

    context "when params[:user_agent_string] is set" do
      let(:user_agent_string) { 'Mozilla/5.0 Foo Bar' }

      subject do
        test_class.new(
          params:    params.merge(user_agent_string: user_agent_string),
          usernames: usernames,
          passwords: passwords
        )
      end

      it "must return params[:user_agent_string]" do
        expect(subject.http_user_agent).to be(
          subject.params[:user_agent_string]
        )
      end
    end

    context "when both params[:user_agent] and params[:user_agent_string] are set" do
      let(:user_agent)        { :random }
      let(:user_agent_string) { 'Mozilla/5.0 Foo Bar' }

      subject do
        test_class.new(
          params: params.merge(
            user_agent:        user_agent,
            user_agent_string: user_agent_string
          ),
          usernames: usernames,
          passwords: passwords
        )
      end

      it "must return params[:user_agent_string]" do
        expect(subject.http_user_agent).to be(
          subject.params[:user_agent_string]
        )
      end
    end
  end

  describe "#http_connect"
end
