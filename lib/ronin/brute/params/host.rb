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

module Ronin
  module Brute
    module Params
      #
      # Adds a `host` param.
      #
      module Host
        #
        # Adds the `host` param to the bruteforcer class including
        # {Params::Host}.
        #
        # @param [Class<Bruteforcer>] bruteforcer
        #   The bruteforcer class that is including {Params::Host}.
        #
        def self.included(bruteforcer)
          bruteforcer.param :host, required: true,
                                   desc:     'The host to bruteforce'
        end

        #
        # The host to bruteforce.
        #
        # @return [String]
        #
        def host
          params[:host]
        end
      end
    end
  end
end
