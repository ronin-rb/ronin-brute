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

module Ronin
  module Brute
    module Metadata
      #
      # Adds an `port` metadata attribute to a bruteforcer class.
      #
      # ## Example
      #
      #     include Metadata::Port
      #
      #     port 80
      #
      module Port
        #
        # Adds {ClassMethods} to the bruteforcer class including {Port}.
        #
        def self.included(bruteforcer_class)
          bruteforcer_class.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the SSL port.
          #
          # @param [Integer, nil] new_port
          #   The optional new SSL port number to set.
          #
          # @return [Integer]
          #   The SSL port.
          #
          # @raise [NotImplementedError]
          #   The class did not define an `port`.
          #
          # @example
          #   port 80
          #
          # @api public
          #
          def port(new_port=nil)
            if new_port
              @port = new_port
            else
              @port ||= if superclass.kind_of?(ClassMethods)
                          superclass.port
                        else
                          raise(NotImplementedError,"#{self} did not define a port")
                        end
            end
          end
        end
      end
    end
  end
end
