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

require 'ronin/brute/bruteforcer'
require 'ronin/brute/metadata/port'
require 'ronin/brute/metadata/ssl_port'
require 'ronin/brute/params/host'
require 'ronin/brute/params/port'
require 'ronin/brute/params/ssl'

module Ronin
  module Brute
    #
    # Base class for all network service bruteforcers.
    #
    class NetworkBruteforcer < Bruteforcer

      include Metadata::Port

      include Params::Host
      include Params::Port

      #
      # Returns the type or kind of bruteforcer.
      #
      # @return [Symbol]
      #
      # @note
      #   This is used internally to map an bruteforcer class to a printable
      #   type.
      #
      # @api private
      #
      def self.bruteforcer_type
        :network
      end

    end
  end
end
