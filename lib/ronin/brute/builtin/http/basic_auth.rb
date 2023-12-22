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

require 'ronin/brute/http_bruteforcer'

module Ronin
  module Brute
    module HTTP
      #
      # A HTTP Basic-Auth bruteforcer.
      #
      class BasicAuth < HTTPBruteforcer

        def bruteforce(credentials)
          http = http_connect

          request_method = params[:request_method]
          path = params[:path]

          while (username, password = credentials.dequeue)
            response = http.request(request_method,path, user:     username,
                                                         password: password)

            case response.code
            when '401'
              # keep trying
            else
              yield username, password
            end
          end
        end

      end
    end
  end
end
