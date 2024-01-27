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
require 'ronin/core/cli/printing/metadata'
require 'ronin/core/cli/printing/arch'
require 'ronin/core/cli/printing/os'
require 'ronin/core/cli/printing/params'

require 'command_kit/printing/fields'

module Ronin
  module Brute
    class CLI
      module Commands
        #
        # Prints information about a bruteforcer.
        #
        # ## Usage
        #
        #     ronin-brute show [options] {--file FILE | NAME}
        #
        # ## Options
        #
        #     -f, --file FILE                  The optional file to load the bruteforcer from
        #     -v, --verbose                    Enables verbose output
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     NAME                             The name of the bruteforcer to load
        #
        class Show < BruteforcerCommand

          include Core::CLI::Printing::Metadata
          include Core::CLI::Printing::Arch
          include Core::CLI::Printing::OS
          include Core::CLI::Printing::Params
          include CommandKit::Printing::Fields

          description 'Prints information about a bruteforcer'

          man_page 'ronin-brute-show.1'

          #
          # Runs the `ronin-list show` command.
          #
          # @param [String] name
          #   The optional name of the bruteforcer to load and print metadata
          #   about.
          #
          def run(name=nil)
            super(name)

            print_bruteforcer(bruteforcer_class)
          end

          #
          # Prints the metadata for a bruteforcer class.
          #
          # @param [Class<Bruteforcer>] bruteforcer
          #   The bruteforcer class.
          #
          def print_bruteforcer(bruteforcer)
            puts "[ #{bruteforcer.id} ]"
            puts

            indent do
              fields = {}

              fields['Type']    = bruteforcer_type(bruteforcer)
              fields['Summary'] = bruteforcer.summary if bruteforcer.summary

              print_fields(fields)
              puts

              print_authors(bruteforcer)
              print_description(bruteforcer)
              print_references(bruteforcer)
              print_params(bruteforcer)
              print_bruteforcer_usage(bruteforcer)
            end
          end

          # Mapping of `bruteforcer_types` and their printable names.
          BRUTEFORCER_TYPES = {
            bruteforcer: 'Generic',
            network:     'Network',

            tcp: 'TCP',
            udp: 'UDP',

            ssl: 'SSL',
            tls: 'TLS',

            http: 'HTTP'
          }

          #
          # The bruteforcer type of the bruteforcer class.
          #
          # @param [Class<Bruteforcer>] bruteforcer
          #   The bruteforcer class.
          #
          # @return [String]
          #   The printable name of the bruteforcer type.
          #
          def bruteforcer_type(bruteforcer)
            BRUTEFORCER_TYPES.fetch(bruteforcer.bruteforcer_type,'Unknown')
          end

          #
          # Prints an example `ronin-bruteforcers build` command for the bruteforcer.
          #
          # @param [Class<Bruteforcer>] bruteforcer
          #   The bruteforcer class.
          #
          def print_bruteforcer_usage(bruteforcer)
            puts "Usage:"
            puts
            puts "  $ #{example_run_command(bruteforcer)}"
            puts
          end

          #
          # Builds an example `ronin-brute run` command for the bruteforcer.
          #
          # @param [Class<Bruteforcer>] bruteforcer
          #   The bruteforcer class.
          #
          # @return [String]
          #   The example `ronin-brute run` command.
          #
          def example_run_command(bruteforcer)
            command = ['ronin-brute', 'run']

            if options[:file]
              command << '-f' << options[:file]
            else
              command << bruteforcer.id
            end

            bruteforcer.params.each_value do |param|
              if param.required? && !param.default
                command << '-p' << "#{param.name}=#{param_usage(param)}"
              end
            end

            return command.join(' ')
          end

        end
      end
    end
  end
end
