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

require 'ronin/brute/metadata/ssl_port'
require 'ronin/brute/params/port'

module Ronin
  module Brute
    module Params
      #
      # Adds a `ssl` param. Will default to true if the `port` param matches
      # the {Metadata::SSLPort::ClassMethods#ssl_port ssl_port} attribute of the
      # bruteforcer class.
      #
      # ## Example
      #
      #     include Params::SSL
      #
      #     ssl_port 443
      #
      module SSL
        #
        # Includes {Metadata::SSLPort}, {Params::Port}, and adds the `ssl`
        # param to the bruteforcer class including {Params::SSL}.
        #
        # @param [Class<Bruteforcer>] bruteforcer
        #   The bruteforcer class including {Params::SSL}.
        #
        def self.included(bruteforcer)
          bruteforcer.include Metadata::SSLPort
          bruteforcer.include Params::Port
          bruteforcer.param :ssl, Core::Params::Types::Boolean, desc: 'Indicates whether to force SSL/TLS'
        end

        #
        # Indicates whether to use SSL/TLS for bruteforcing connections.
        #
        # @return [Boolean]
        #
        def ssl?
          params.fetch(:ssl) do
            port == self.class.ssl_port
          end
        end

        #
        # The port to bruteforce.
        #
        # @return [Integer]
        #
        def port
          params.fetch(:port) do
            if params[:ssl]
              # explicitly specified to use SSL.
              self.class.ssl_port
            else
              self.class.port
            end
          end
        end
      end
    end
  end
end
