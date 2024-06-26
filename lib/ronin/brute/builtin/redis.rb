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

require 'ronin/brute/tcp_bruteforcer'
require 'ronin/brute/mixins/ssl'

module Ronin
  module Brute
    #
    # A Redis server authentication bruteforcer.
    #
    class Redis < TCPBruteforcer

      include Mixins::SSL

      register 'redis'
      port 6379

      #
      # Initializes the Redis bruteforcer.
      #
      # @param [Enumerable] usernames
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments.
      #
      # @option kwargs [Enumerable] :passwords
      #
      # @option kwargs [Integer] :concurrency
      #   The number of bruteforcer workers to spawn.
      #
      # @option kwargs [Hash{Symbol => Object}] :params
      #   The param values for the bruteforcer.
      #
      def initialize(usernames: %w[default], **kwargs)
        super(usernames: usernames, **kwargs)
      end

      #
      # Bruteforces a Redis server.
      #
      # @param [Async::LimitedQueue] credentials
      #   The credentials to test.
      #
      # @yield [username, password]
      #   The given block will be passed each valid username and password
      #   combination from the credentials list.
      #
      # @yieldparam [String] username
      #   A valid username.
      #
      # @yieldparam [String] password
      #   A valid password.
      #
      def bruteforce(credentials)
        while (username, password = credentials.dequeue)
          connect do |socket|
            if username
              socket.puts "AUTH #{username} #{password}"
            else
              socket.puts "AUTH #{password}"
            end

            response = socket.gets

            if response.chomp == "+OK"
              yield username, password
            end
          end
        end
      end

    end
  end
end
