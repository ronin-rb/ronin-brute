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

require 'ronin/brute/params/ssl'
require 'ronin/support/network/ssl/mixin'

module Ronin
  module Brute
    module Mixins
      #
      # Mixin which adds SSL support.
      #
      module SSL
        include Support::Network::SSL::Mixin

        #
        # Includes {Metadata::SSLPort} and {Params::SSL} into the bruteforcer
        # class that is including {SSL}.
        #
        # @param [Class<Bruteforcer>] bruteforcer
        #   The bruteforcer class including {SSL}.
        #
        # @api private
        #
        def self.included(bruteforcer)
          bruteforcer.include Metadata::SSLPort
          bruteforcer.include Params::SSL
        end

        #
        # Opens a new SSL connection to the {Params::Host#host host} and
        # {Params::Port#port port}.
        #
        # @yield [ssl_socket]
        #   The given block will be passed the new SSL socket. Once the block
        #   returns the SSL socket will be closed.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] ssl_socket
        #   The new SSL Socket.
        #
        # @return [OpenSSL::SSL::SSLSocket, nil]
        #   The new SSL Socket. If a block is given, then `nil` will be
        #   returned.
        #
        def ssl_connect(&block)
          super(host,port,&block)
        end

        #
        # Opens either a TCP or SSL connection to {Params::Host#host host} and
        # {Params::Port#port port}. If {Params::Port#port port} is the SSL port,
        # then an SSL connection will be opened.
        #
        # @yield [ssl_socket]
        #   The given block will be passed the new SSL socket. Once the block
        #   returns the SSL socket will be closed.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] ssl_socket
        #   The new SSL Socket.
        #
        # @return [OpenSSL::SSL::SSLSocket, nil]
        #   The new SSL Socket. If a block is given, then `nil` will be
        #   returned.
        #
        def connect(&block)
          if ssl? then ssl_connect(&block)
          else         tcp_connect(&block)
          end
        end
      end
    end
  end
end
