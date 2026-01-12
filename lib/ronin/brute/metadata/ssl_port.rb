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

module Ronin
  module Brute
    module Metadata
      #
      # Adds an `ssl_port` metadata attribute to a bruteforcer class.
      #
      # ## Example
      #
      #     include Metadata::SSLPort
      #
      #     ssl_port 443
      #
      module SSLPort
        #
        # Adds {ClassMethods} to the bruteforcer class including {SSLPort}.
        #
        def self.included(bruteforcer_class)
          bruteforcer_class.extend ClassMethods
        end

        #
        # Class methods.
        #
        module ClassMethods
          #
          # Gets or sets the SSL port.
          #
          # @param [Integer, nil] new_port
          #   The optional new SSL port number to set.
          #
          # @return [Integer, nil]
          #   The SSL port.
          #
          # @example
          #   ssl_port 443
          #
          # @api public
          #
          def ssl_port(new_port=nil)
            if new_port
              @ssl_port = new_port
            else
              @ssl_port ||= if superclass.kind_of?(ClassMethods)
                              superclass.ssl_port
                            end
            end
          end
        end
      end
    end
  end
end
