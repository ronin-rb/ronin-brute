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

require 'ronin/brute/metadata/port'

module Ronin
  module Brute
    module Params
      #
      # Adds the `port` param to a bruteforcer class. Defaults to the
      # {Metadata::Port::ClassMethods#port port} attribute of the bruteforcer
      # class.
      #
      # ## Example
      #
      #     include Params
      #
      #     port 80
      #
      module Port
        #
        # Includes {Metadata::Port} and adds the `port` param to the bruteforcer
        # class including {Params::Port}.
        #
        # @param [Class<Bruteforcer>] bruteforcer
        #   The bruteforcer class including {Params::Port}.
        #
        def self.included(bruteforcer)
          bruteforcer.include Metadata::Port
          bruteforcer.param :port, Integer, desc: 'The port to bruteforce'
        end

        #
        # The port to bruteforce.
        #
        # @return [Integer]
        #
        def port
          params.fetch(:port) { self.class.port }
        end
      end
    end
  end
end
