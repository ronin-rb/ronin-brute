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

require 'ronin/brute/network_bruteforcer'

require 'ronin/support/network/tcp/mixin'

module Ronin
  module Brute
    #
    # Base class for all TCP service bruteforcers.
    #
    class TCPBruteforcer < NetworkBruteforcer

      include Support::Network::TCP::Mixin

      #
      # Creates a new TCPSocket object connected to a given host and port.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#tcp_connect}.
      #
      # @option kwargs [String, nil] :bind_host
      #   The local host to bind to.
      #
      # @option kwargs [Integer, nil] :bind_port
      #   The local port to bind to.
      #
      # @yield [socket]
      #   If a block is given, it will be passed the newly created socket.
      #   Once the block returns the socket will be closed.
      #
      # @yieldparam [TCPsocket] socket
      #   The newly created TCPSocket object.
      #
      # @return [TCPSocket, nil]
      #   The newly created TCPSocket object. If a block is given a `nil`
      #   will be returned.
      #
      # @example
      #   @socket = tcp_connect
      #   # => TCPSocket
      #
      # @example
      #   tcp_connect do |socket|
      #     socket.write("GET /\n\n")
      #   end
      #
      # @see https://rubydoc.info/stdlib/socket/TCPSocket
      #
      def tcp_connect(**kwargs,&block)
        if debug?
          print_debug "Connecting to #{host}:#{port} ..."
        end

        super(host,port,**kwargs,&block)
      end

      alias connect tcp_connect

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
        :tcp
      end

    end
  end
end
