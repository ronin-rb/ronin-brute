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
    module Mixins
      #
      # Adds methods for dealing with login timeouts.
      #
      # ## Params
      #
      # * `login_timeout` (`Integer`) - the maximum limit to wait for a login
      #   response. Defaults to 2.
      #
      # ## Example
      #
      #     include Mixins::LoginTimeout
      #
      #     def bruteforce(credentials)
      #       while (username, password = credentials.dequeue)
      #         connect do |socket|
      #           # ignore the banner
      #           socket.gets
      #
      #           socket.puts "USER #{username}"
      #           response = socket.gets.chomp
      #
      #           socket.puts "PASS #{password}"
      #
      #           response = login_timeout { socket.gets.chomp }
      #
      #           if response && response == "230 Login successful."
      #             yield username, password
      #           else
      #             next
      #           end
      #         end
      #       end
      #     end
      #
      module LoginTimeout
        #
        # Adds the `login_timeout` param to the bruteforcer class including
        # {LoginTimeout}.
        #
        # @param [Class<Bruteforcer>] bruteforcer
        #   The bruteforcer class including {LoginTimeout}.
        #
        # @api private
        #
        def self.included(bruteforcer)
          bruteforcer.extend ClassMethods
          bruteforcer.param :login_timeout, Integer, default: -> { bruteforcer.login_timeout },
                                                     desc:    'The invalid login timeout in seconds'
        end

        #
        # Class methods that will be added to the class that includes
        # {Mixins::LoginTimeout}.
        #
        module ClassMethods
          #
          # Gets or sets the maximum login timeout.
          #
          # @param [Integer, nil] new_timeout
          #   The optional new login timeout.
          #
          # @return [Integer]
          #   The login timeout.
          #
          # @api public
          #
          def login_timeout(new_timeout=nil)
            if new_timeout
              @login_timeout = new_timeout
            else
              @login_timeout ||= if superclass.kind_of?(ClassMethods)
                                   superclass.login_timeout
                                 else
                                   2
                                 end
            end
          end
        end

        #
        # Executes the given block with a timeout limit.
        #
        # @param [Integer] duration
        #   The timeout limit in seconds.
        #
        # @param [Async::Task] task
        #   The async task.
        #
        # @yield []
        #   The given block that will be executed.
        #
        # @return [Object, nil]
        #   The return value of the block, or `nil` if the timeout was exceeded.
        #
        # @example
        #   response = login_timeout { socket.gets.chomp }
        #
        #   if response && response == "..."
        #     yield username, password
        #   end
        #
        # @api public
        #
        def login_timeout(duration=params[:login_timeout],task=Async::Task.current)
          task.with_timeout(duration) do
            yield
          rescue Async::TimeoutError
          end
        end
      end
    end
  end
end
