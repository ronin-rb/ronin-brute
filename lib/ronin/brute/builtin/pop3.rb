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

require 'ronin/brute/mailserver_bruteforcer'
require 'ronin/brute/mixins/login_timeout'

module Ronin
  module Brute
    #
    # A POP3 login bruteforcer.
    #
    class POP3 < MailserverBruteforcer

      include Mixins::LoginTimeout

      register 'pop3'

      port 110
      ssl_port 995
      login_timeout 5

      #
      # Bruteforces a POP3 server.
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
            # ignore the banner
            socket.gets

            socket.puts "USER #{username}@#{domain}"
            response = socket.gets

            if response.chomp == "+OK"
              socket.puts "PASS #{password}"

              response = login_timeout { socket.gets }

              if response && response.chomp == "+OK Logged in."
                yield username, password
              end
            end
          end
        end
      end

    end
  end
end
