# frozen_string_literal: true
#
# ronin-brute - A micro-framework for bruteforcing credentials.
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
      # A HTTP login bruteforcer.
      #
      class Login < HTTPBruteforcer

        param :request_method, Enum[
                                 :copy,
                                 :delete,
                                 :get,
                                 :head,
                                 :lock,
                                 :mkcol,
                                 :move,
                                 :options,
                                 :patch,
                                 :post,
                                 :propfind,
                                 :proppatch,
                                 :put,
                                 :trace,
                                 :unlock
                               ],
                               default: :post,
                               desc:    'The HTTP request method to use'

        param :username_param, default: 'username',
                               desc:    'The username form param name'

        param :password_param, default: 'password',
                               desc:    'The password form param name'

        param :failure_status, Integer, desc: 'The HTTP status code for a failed login response'

        param :failure_redirect, desc: 'The HTTP path or URL that is redirected back to'

        param :failure_string, desc: 'The string that indicates a failed login response'

        #
        # Bruteforces the HTTP server's Basic-Auth.
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
          http = http_connect

          request_method = params[:request_method]
          path           = params[:path]

          username_param = params[:username_param]
          password_param = params[:password_param]

          failure_status   = params[:failure_status]
          failure_redirect = params.fetch(:failure_redirect) do
                              if ssl? then URI::HTTPS
                              else         URI::HTTP
                              end

                              # default the failed login redirect to the login
                              # form's own URL.
                              uri_class.build(
                                host: host,
                                port: port,
                                path: path
                              ).to_s
                            end
          failure_string   = params[:failure_string]

          initial_response = http.get(path)
          session_cookie   = initial_response['Set-Cookie']

          while (username, password = credentials.dequeue)
            response = http.request(
              request_method, path, cookie:    session_cookie,
                                    form_data: {
                                      username_param => username,
                                      password_param => password
                                    }
            )

            if (failure_status && response.code.to_i != failure_status) ||
               (failure_string && !response.body.include?(failure_string)) ||
               (response.kind_of?(Net::HTTPRedirection) && response['Location'] != failure_redirect)
              yield username, password
            end

            if (new_cookie = response['Set-Cookie'])
              # update the session cookie
              session_cookie = new_cookie
            end
          end
        end

      end
    end
  end
end
