# frozen_string_literal: true
#
# ronin-brute - A micro-framework and tool for bruteforcing credentials.
#
# Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-brute is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-brute is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-brute.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/brute/cli/bruteforcer_command'
require 'ronin/brute/network_bruteforcer'
require 'ronin/brute/http_bruteforcer'

require 'ronin/core/cli/options/param'
require 'ronin/core/cli/logging'
require 'wordlist'

module Ronin
  module Brute
    class CLI
      module Commands
        #
        # Loads and runs a bruteforcer.
        #
        # ## Usage
        #
        #     ronin-brute run [options] {-f FILE | NAME}
        #
        # ## Options
        #
        #     -f, --file FILE                  The bruteforcer file to load
        #     -p, --param NAME=VALUE           Sets a param
        #     -U, --usernames FILE             The usernames wordlist file
        #     -P, --passwords FILE             The passwords wordlist file
        #     -c, --concurrency WORKERS        Sets the bruteforcer concurrency
        #     -F, --first                      Find the first valid username:password pair
        #     -A, --all                        Find all valid username:password pair
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [NAME]                           The bruteforcer name to load
        #
        class Run < BruteforcerCommand

          include Core::CLI::Options::Param
          include Core::CLI::Logging

          option :usernames, short: '-U',
                             value: {
                               type:  String,
                               usage: 'FILE'
                             },
                             desc: 'The usernames wordlist file'

          option :passwords, short: '-P',
                             value: {
                               type:  String,
                               usage: 'FILE'
                             },
                             desc: 'The passwords wordlist file'

          option :concurrency, short: '-c',
                               value: {
                                 type:  Integer,
                                 usage: 'WORKERS'
                               },
                               desc: 'Sets the bruteforcer concurrency'

          option :first, short: '-F',
                         desc:  'Find the first valid username:password pair' do
                           @mode = :first
                         end

          option :all, short: '-A',
                       desc:  'Find all valid username:password pair' do
                         @mode = :all
                       end

          description 'Loads and runs a bruteforcer'

          man_page 'ronin-brute-run.1'

          # The bruteforcer mode.
          #
          # @return [:first, :all]
          #   * `:first` - stops bruteforcing once the first valid username and
          #     password combination is found.
          #   * `:all` - finds all valid username and password combinations.
          attr_reader :mode

          # The usernames wordlist.
          #
          # @return [Wordlist, nil]
          attr_reader :usernames

          # The passwords wordlist.
          #
          # @return [Wordlist, nil]
          attr_reader :passwords

          #
          # Initializes the `ronin-brute run` command.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @mode = :first
          end

          #
          # Runs the `ronin-brute run` command.
          #
          # @param [String, nil] name
          #   The optional bruteforcer name to load.
          #
          def run(name=nil)
            super(name)

            load_usernames
            load_passwords
            initialize_bruteforcer
            run_bruteforcer
          end

          #
          # Loads a wordlist of usernames from the `--usernames` option.
          #
          def load_usernames
            unless options[:usernames]
              print_error "must specify -U,--usernames option"
              exit(1)
            end

            @usernames = Wordlist.open(options[:usernames])
          end

          #
          # Loads a wordlist of passwords from the `--passwords` option.
          #
          def load_passwords
            unless options[:passwords]
              print_error "must specify -P,--passwords option"
              exit(1)
            end

            @passwords = Wordlist.open(options[:passwords])
          end

          #
          # Initializes the bruteforcer and sets `@bruteofrcer`.
          #
          def initialize_bruteforcer
            kwargs = {
              usernames: @usernames,
              passwords: @passwords,
              params:    @params
            }

            if options[:concurrency]
              kwargs[:concurrency] = options[:concurrency]
            end

            super(**kwargs)
          end

          #
          # Runs the bruteforcer class.
          #
          # @raise [NotImplementedError]
          #   {#mode} was not `:first` or `:all`.
          #
          def run_bruteforcer
            log_info "Bruteforcing #{target} ..."

            case @mode
            when :first
              Async do
                if (username, password = @bruteforcer.find_first)
                  log_info "Found credentials #{username}:#{password}"
                end
              end
            when :all
              Async do
                @bruteforcer.find_all do |username,password|
                  log_info "Found credentials #{username}:#{password} ..."
                end
              end
            else
              raise(NotImplementedError,"mode not supported: #{@mode.inspect}")
            end
          end

          #
          # Builds a printable target string based on the bruteforcer type and
          # settings.
          #
          # @return [String]
          #
          def target
            case @bruteforcer
            when HTTPBruteforcer
              uri_class = if @bruteforcer.ssl? then URI::HTTPS
                          else                      URI::HTTP
                          end

              uri_class.new(
                host: @bruteforcer.host,
                port: @bruteforcer.port,
                path: @bruteforcer.path
              ).to_s
            when NetworkBruteforcer
              "#{@bruteforcer.host}:#{@bruteforcer.port}"
            else
              'target'
            end
          end

        end
      end
    end
  end
end
