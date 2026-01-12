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
      module Commands
        #
        # Lists all available bruteforcers.
        #
        # ## Usage
        #
        #     ronin-brute list [options] [DIR]
        #
        # ## Options
        #
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [DIR]                            The optional bruteforcer directory to list
        #
        class List < Command

          usage '[options] [DIR]'

          argument :dir, required: false,
                         desc:     'The optional bruteforcer directory to list'

          description 'Lists the available bruteforcers'

          man_page 'ronin-brute-list.1'

          #
          # Runs the `ronin-brute list` command.
          #
          # @param [String, nil] dir
          #   The optional bruteforcer directory to list.
          #
          def run(dir=nil)
            files = if dir
                      dir = "#{dir}/" unless dir.end_with?('/')

                      Brute.list_files.select do |file|
                        file.start_with?(dir)
                      end
                    else
                      Brute.list_files
                    end

            files.each do |file|
              puts "  #{file}"
            end
          end

        end
      end
    end
  end
end
