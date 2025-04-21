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

require 'ronin/brute/network_bruteforcer'
require 'ronin/brute/mixins/ssl'

require 'ronin/support/network/http'

module Ronin
  module Brute
    #
    # Base class for all HTTP bruteforcers.
    #
    class HTTPBruteforcer < NetworkBruteforcer

      include Mixins::SSL

      port 80
      ssl_port 443

      param :http_proxy, desc: 'The HTTP proxy to use'

      # Possible values for the `user_agent` param.
      #
      # @api private
      HTTP_USER_AGENT_ALIASES = [
        :random,
        :chrome,
        :firefox,
        :safari,
        :linux,
        :macos,
        :windows,
        :iphone,
        :ipad,
        :android
      ] + Support::Network::HTTP::UserAgents::ALIASES.keys

      param :user_agent, Enum.new(HTTP_USER_AGENT_ALIASES), desc: 'The HTTP User-Agent to select'

      param :user_agent_string, desc: 'The raw HTTP User-Agent string to use'

      param :path, required: true,
                   default:  '/',
                   desc:     'The HTTP path to request'

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
                             default: :head,
                             desc:    'The HTTP request method to use'

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
        :http
      end

      #
      # The HTTP proxy to use for all HTTP requests.
      #
      # @return [String, nil]
      #
      # @api private
      #
      def http_proxy
        params[:http_proxy]
      end

      #
      # Additional default headers to send with every HTTP request.
      #
      # @return [Hash{Symbol,String => String,Array}]
      #
      # @api private
      #
      def http_headers
        {}
      end

      #
      # The `User-Agent` to use for HTTP requests.
      #
      # @return [String, Symbol, :random, nil]
      #   The `User-Agent` string or an alias name (ex: `:chrome_linux`).
      #
      # @api private
      #
      def http_user_agent
        params[:user_agent_string] || params[:user_agent]
      end

      #
      # @!macro request_kwargs
      #   @option kwargs [String, nil] :user
      #     The `Basic-Auth` user to authenticate as.
      #
      #   @option kwargs [String, nil] :password
      #     The `Basic-Auth` password to authenticate with.
      #
      #   @option kwargs [String, nil] :query
      #     The query-string to append to the request path.
      #
      #   @option kwargs [Hash, nil] :query_params
      #     The query-params to append to the request path.
      #
      #   @option kwargs [String, nil] :body
      #     The body of the request.
      #
      #   @option kwargs [Hash, String, nil] :form_data
      #     The form data that may be sent in the body of the request.
      #
      #   @option kwargs [Hash{Symbol,String => String}, nil] :headers (http_headers)
      #     Additional HTTP headers to use for the request.
      #

      #
      # Creates a new persistent HTTP connection to the {#host} and {#port}.
      #
      # @yield [http]
      #   If a block is given, it will be passed the newly created HTTP
      #   session object. Once the block returns, the HTTP session will be
      #   closed.
      #
      # @yieldparam [Ronin::Support::Network::HTTP] http
      #   The HTTP session object.
      #
      # @return [Ronin::Support::Network::HTTP, nil]
      #   The HTTP session object. If a block is given, then `nil` will be
      #   returned.
      #
      def http_connect(&block)
        Support::Network::HTTP.connect(
          host, port, ssl:        ssl?,
                      proxy:      http_proxy,
                      headers:    http_headers,
                      user_agent: http_user_agent, &block
        )
      end

      alias connect http_connect

      #
      # Builds URI from host, port, ssl? and given path.
      #
      # @param [String] path
      #   Path to append to the URI.
      #
      # @return [URI::HTTP, URI::HTTPS]
      #
      def url_for(path)
        scheme = ssl? ? URI::HTTPS : URI::HTTP
        scheme.build(host: host, port: port, path: path)
      end

    end
  end
end
