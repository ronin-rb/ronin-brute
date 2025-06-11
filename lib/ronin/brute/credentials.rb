# frozen_string_literal: true
#
# ronin-brute - A micro-framework and tool for bruteforcing credentials.
#
# Copyright (c) 2023-2025 Hal Brodigan (postmodern.mod3@gmail.com)
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

module Ronin
  module Brute
    #
    #  Represents a username/email and password credential pair.
    #
    class Credentials
      #
      # Initializes the credential.
      #
      # @param [String] username
      #   The username or email for the credential.
      #
      # @param [String] password
      #   The password for the credential.
      #
      def initialize(username, password)
        @username = username
        @password = password
      end

      #
      # Converts the credential to a colon-separated String.
      #
      # @return [String]
      #   The credential's username/email and password.
      #
      def to_s
        "#{@username}:#{@password}"
      end

      #
      # Returns an Array containing username and password.
      #
      # @return [Array]
      #
      def to_a
        [@username, @password]
      end
      alias to_ary to_a

    end
  end
end
