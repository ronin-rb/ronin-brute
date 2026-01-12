# frozen_string_literal: true
#
# ronin-brute - A micro-framework and tool for bruteforcing credentials.
#
# Copyright (c) 2023-2026 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/brute/registry'
require 'ronin/brute/cli/command'

module Ronin
  module Brute
    class CLI
      #
      # Base class for all commands which load a bruteforcer.
      #
      class BruteforcerCommand < Command

        usage '[options] {-f FILE | NAME}'

        option :file, short: '-f',
                      value: {
                        type: String,
                        usage: 'FILE'
                      },
                      desc: 'The bruteforcer file to load'

        argument :name, required: false,
                        desc:     'The bruteforcer name to load'

        # The loaded bruteforcer class.
        #
        # @return [Class<Bruteforcer>, nil]
        attr_reader :bruteforcer_class

        # The initialized bruteforcer object.
        #
        # @return [Bruteforcer, nil]
        attr_reader :bruteforcer

        #
        # Loads the bruteforcer.
        #
        # @param [String, nil] name
        #   The optional bruteforcer name to load.
        #
        def run(name=nil)
          if    name           then load_bruteforcer(name)
          elsif options[:file] then load_bruteforcer_from(options[:file])
          else
            print_error "must specify --file or a NAME"
            exit(-1)
          end
        end

        #
        # Loads the bruteforcer and sets {#bruteforcer_class}.
        #
        # @param [String] id
        #   The bruteforcer name to load.
        #
        def load_bruteforcer(id)
          @bruteforcer_class = Brute.load_class(id)
        rescue Brute::ClassNotFound => error
          print_error(error.message)
          exit(1)
        rescue => error
          print_exception(error)
          print_error("an unhandled exception occurred while loading bruteforcer #{id}")
          exit(-1)
        end

        #
        # Loads the bruteforcer from the given file and sets
        # {#bruteforcer_class}.
        #
        # @param [String] file
        #   The file to load the bruteforcer from.
        #
        def load_bruteforcer_from(file)
          @bruteforcer_class = Brute.load_class_from_file(file)
        rescue Brute::ClassNotFound => error
          print_error(error.message)
          exit(1)
        rescue => error
          print_exception(error)
          print_error("an unhandled exception occurred while loading bruteforcer from file #{file}")
          exit(-1)
        end

        #
        # Initializes the bruteforcer and sets {#bruteforcer}.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for {Bruteforcer#initialize}.
        #
        def initialize_bruteforcer(**kwargs)
          @bruteforcer = @bruteforcer_class.new(**kwargs)
        rescue Core::Params::ParamError => error
          print_error(error.message)
          exit(1)
        rescue => error
          print_exception(error)
          print_error("an unhandled exception occurred while initializing bruteforcer #{@bruteforcer_class.id}")
          exit(-1)
        end

      end
    end
  end
end
