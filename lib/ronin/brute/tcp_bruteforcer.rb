# frozen_string_literal: true
#
# ronin-brute - A micro-framework and tool for bruteforcing credentials.
#
# Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/support/network/tcp/mixin'

module Ronin
  module Brute
    #
    # Base class for all TCP service bruteforcers.
    #
    class TCPBruteforcer < NetworkBruteforcer

      include Support::Network::TCP::Mixin

      #
      # Tests whether a remote TCP port is open.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
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
      # @option kwargs [Integer] :timeout (5)
      #   The maximum time to attempt connecting.
      #
      # @return [Boolean, nil]
      #   Specifies whether the remote TCP port is open.
      #   If the connection was not accepted, `nil` will be returned.
      #
      # @example
      #   tcp_open?
      #   # => true
      #
      # @example Using a timeout:
      #   tcp_open?(timeout: 5)
      #   # => nil
      #
      def tcp_open?(host=params[:host],port=params[:port],**kwargs)
        if debug?
          print_debug "Testing if #{host}:#{port} is open ..."
        end

        super(host,port,**kwargs)
      end

      #
      # Creates a new TCPSocket object connected to a given host and port.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
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
      def tcp_connect(host=params[:host],port=params[:port],**kwargs,&block)
        if debug?
          print_debug "Connecting to #{host}:#{port} ..."
        end

        super(host,port,**kwargs,&block)
      end

      #
      # Creates a new TCPSocket object, connected to a given host and port.
      # The given data will then be written to the newly created TCPSocket.
      #
      # @param [String] data
      #   The data to send through the connection.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#tcp_connect_and_send}.
      #
      # @option kwargs [String, nil] :bind_host
      #   The local host to bind to.
      #
      # @option kwargs [Integer, nil] :bind_port
      #   The local port to bind to.
      #
      # @yield [socket]
      #   If a block is given, it will be passed the newly created socket.
      #
      # @yieldparam [TCPSocket] socket
      #   The newly created TCPSocket object.
      #
      # @return [TCPSocket]
      #   The newly created TCPSocket object.
      #
      # @example
      #   @socket = tcp_connect_and_send(@buffer)
      #
      def tcp_connect_and_send(data,host=params[:host],port=params[:port],**kwargs,&block)
        if debug?
          print_debug "Connecting to #{host}:#{port} and sending #{data.inspect} ..."
        end

        super(data,host,port,**kwargs,&block)
      end

      #
      # Reads the banner from the service running on the given host and
      # port.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#tcp_banner}.
      #
      # @option kwargs [String, nil] :bind_host
      #   The local host to bind to.
      #
      # @option kwargs [Integer, nil] :bind_port
      #   The local port to bind to.
      #
      # @yield [banner]
      #   If a block is given, it will be passed the grabbed banner.
      #
      # @yieldparam [String] banner
      #   The grabbed banner.
      #
      # @return [String]
      #   The grabbed banner.
      #
      # @example
      #   tcp_banner
      #   # => "220 mx.google.com ESMTP c20sm3096959rvf.1"
      #
      def tcp_banner(host=params[:host],port=params[:port],**kwargs)
        if debug?
          print_debug "Fetching the banner for #{host}:#{port} ..."
        end

        super(host,port,**kwargs)
      end

      #
      # Connects to a specified host and port, sends the given data and then
      # closes the connection.
      #
      # @param [String] data
      #   The data to send through the connection.
      #
      # @param [String] host
      #   The host to connect to.
      #
      # @param [Integer] port
      #   The port to connect to.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#tcp_send}.
      #
      # @option kwargs [String, nil] :bind_host
      #   The local host to bind to.
      #
      # @option kwargs [Integer, nil] :bind_port
      #   The local port to bind to.
      #
      # @return [true]
      #   The data was successfully sent.
      #
      # @example
      #   @buffer = "GET /" + ('A' * 4096) + "\n\r"
      #   # ...
      #   tcp_send(@buffer)
      #   # => true
      #
      def tcp_send(data,host=params[:host],port=params[:port],**kwargs)
        if debug?
          print_debug "Sending #{data.inspect} to #{host}:#{port} ..."
        end

        super(data,host,port,**kwargs)
      end

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
