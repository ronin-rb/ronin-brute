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
require 'ronin/brute/mixins/login_timeout'
require 'ronin/brute/params/database'
require 'ronin/support/network/ip'
require 'ronin/support/network/dns'

require 'db/client'
require 'db/mariadb'

module Ronin
  module Brute
    #
    # A MySQL login bruteforcer.
    #
    class MySQL < TCPBruteforcer

      include Mixins::LoginTimeout
      include Params::Database

      register 'mysql'

      port 3306
      login_timeout 4

      #
      # Bruteforces a MySQL server.
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
        host     = ip_address
        port     = self.port
        database = self.database

        while (username, password = credentials.dequeue)
          client = DB::Client.new(
                     DB::MariaDB::Adapter.new(
                       database: database,
                       host:     host,
                       port:     port,
                       username: username,
                       password: password
                     )
                   )

          session = client.session

          result = login_timeout do
            session.query('SELECT (1);').call
          rescue DB::MariaDB::Error
          ensure
            session.close
          end

          if result
            yield username, password
          end
        end
      end

      #
      # Resolves the `host` param to an IP address.
      #
      # @return [String]
      #   The IP address for the `host` param, or the `host` param value if
      #   it's already an IP address.
      #
      # @raise [Ronin::Core::Params::ValidationError]
      #   Could not resolve the `host` param value.
      #
      def ip_address
        case (host = self.host)
        when Support::Network::IP::REGEX
          host
        else
          Support::Network::DNS.get_address(host) ||
            raise(Core::Params::ValidationError,"could not resolve hostname: #{host.inspect}")
        end
      end
    end
  end
end
