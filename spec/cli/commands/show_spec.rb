require 'spec_helper'
require 'ronin/brute/cli/commands/show'
require_relative 'man_page_example'

require 'ronin/brute/bruteforcer'
require 'ronin/brute/network_bruteforcer'
require 'ronin/brute/tcp_bruteforcer'
require 'ronin/brute/udp_bruteforcer'
require 'ronin/brute/ssl_bruteforcer'
require 'ronin/brute/tls_bruteforcer'
require 'ronin/brute/http_bruteforcer'

describe Ronin::Brute::CLI::Commands::Show do
  include_examples "man_page"

  module TestShowCommand
    class ExampleBruteforcer < Ronin::Brute::Bruteforcer

      id 'exaple_bruteforcer'

      param :foo, String, required: true, desc: 'Foo param'
      param :bar, Integer, required: true, desc: 'Bar param'
      param :baz, Integer, desc: 'Baz param'

    end
  end

  let(:bruteforcer_class) { TestShowCommand::ExampleBruteforcer }

  describe "#bruteforcer_type" do
    {
      Ronin::Brute::Bruteforcer        => 'Generic',
      Ronin::Brute::NetworkBruteforcer => 'Network',
      Ronin::Brute::TCPBruteforcer     => 'TCP',
      Ronin::Brute::UDPBruteforcer     => 'UDP',
      Ronin::Brute::SSLBruteforcer     => 'SSL',
      Ronin::Brute::TLSBruteforcer     => 'TLS',
      Ronin::Brute::HTTPBruteforcer    => 'HTTP'
    }.each do |bruteforcer_class,type|
      context "when the class inherits from #{bruteforcer_class}" do
        let(:klass) { Class.new(bruteforcer_class) }
        let(:type)  { type }

        it "must return '#{type}'" do
          expect(subject.bruteforcer_type(klass)).to eq(type)
        end
      end
    end
  end

  describe "#print_bruteforcer_usage" do
    it "must print 'Usage:' followed by an example 'ronin-brute run' command" do
      expect {
        subject.print_bruteforcer_usage(bruteforcer_class)
      }.to output(
        [
          "Usage:",
          "",
          "  $ ronin-brute run #{bruteforcer_class.id} -p foo=FOO -p bar=NUM",
          "",
          ""
        ].join($/)
      ).to_stdout
    end
  end

  describe "#example_run_command" do
    context "when given a bruteforcer class with no params" do
      module TestShowCommand
        class BruteforcerWithNoParams < Ronin::Brute::Bruteforcer

          id 'bruteforcer_with_no_params'

        end
      end

      let(:bruteforcer_class) { TestShowCommand::BruteforcerWithNoParams }

      it "must return 'ronin-brute run ...' with the bruteforcer class ID" do
        expect(subject.example_run_command(bruteforcer_class)).to eq(
          "ronin-brute run #{bruteforcer_class.id}"
        )
      end
    end

    context "but the bruteforcer class does have params" do
      context "and none of them are required" do
        module TestShowCommand
          class BruteforcerWithOptionalParams < Ronin::Brute::Bruteforcer

            id 'bruteforcer_with_optional_params'

            param :foo, String, desc: 'Foo param'
            param :bar, Integer, desc: 'Bar param'

          end
        end

        let(:bruteforcer_class) { TestShowCommand::BruteforcerWithOptionalParams }

        it "must not add any '-p' flags to the 'ronin-brute run' command" do
          expect(subject.example_run_command(bruteforcer_class)).to eq(
            "ronin-brute run #{bruteforcer_class.id}"
          )
        end
      end

      context "and they all have default values" do
        module TestShowCommand
          class BruteforcerWithDefaultParams < Ronin::Brute::Bruteforcer

            id 'bruteforcer_with_default_params'

            param :foo, String, default: 'foo',
                                desc:    'Foo param'

            param :bar, Integer, default: 42,
                                 desc:    'Bar param'

          end
        end

        let(:bruteforcer_class) { TestShowCommand::BruteforcerWithDefaultParams }

        it "must not add any '-p' flags to the 'ronin-brute run' command" do
          expect(subject.example_run_command(bruteforcer_class)).to eq(
            "ronin-brute run #{bruteforcer_class.id}"
          )
        end
      end

      context "and some are required" do
        context "but they also have default values" do
          module TestShowCommand
            class BruteforcerWithRequiredAndDefaultParams < Ronin::Brute::Bruteforcer

              id 'bruteforcer_with_required_and_default_params'

              param :foo, String, required: true,
                                  default:  'foo',
                                  desc:     'Foo param'

              param :bar, Integer, required: true,
                                   default:  42,
                                   desc:     'Bar param'

            end
          end

          let(:bruteforcer_class) { TestShowCommand::BruteforcerWithRequiredAndDefaultParams }

          it "must not add any '-p' flags to the 'ronin-brute run' command" do
            expect(subject.example_run_command(bruteforcer_class)).to eq(
              "ronin-brute run #{bruteforcer_class.id}"
            )
          end
        end

        context "but some are required and have no default values" do
          module TestShowCommand
            class BruteforcerWithRequiredParams < Ronin::Brute::Bruteforcer

              id 'bruteforcer_with_required_params'

              param :foo, String, required: true, desc: 'Foo param'
              param :bar, Integer, required: true, desc: 'Bar param'
              param :baz, Integer, desc: 'Baz param'

            end
          end

          let(:bruteforcer_class) { TestShowCommand::BruteforcerWithRequiredParams }

          it "must add '-p' flags followed by the param name and usage to the 'ronin-brute run' command" do
            expect(subject.example_run_command(bruteforcer_class)).to eq(
              "ronin-brute run #{bruteforcer_class.id} -p foo=FOO -p bar=NUM"
            )
          end
        end
      end
    end

    context "when the bruteforcer is loaded via the '--file' option" do
      let(:bruteforcer_file) { 'path/to/bruteforcer.rb' }

      before { subject.options[:file] = bruteforcer_file }

      it "must return a 'ronin-brute run --file ...' command with the bruteforcer file" do
        expect(subject.example_run_command(bruteforcer_class)).to eq(
          "ronin-brute run -f #{bruteforcer_file} -p foo=FOO -p bar=NUM"
        )
      end
    end
  end
end
