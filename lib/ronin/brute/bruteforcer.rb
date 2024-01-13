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

require 'ronin/brute/registry'
require 'ronin/core/metadata/id'
require 'ronin/core/metadata/authors'
require 'ronin/core/metadata/summary'
require 'ronin/core/metadata/description'
require 'ronin/core/metadata/references'
require 'ronin/core/params/mixin'
require 'ronin/support/cli/printing'

require 'async'
require 'async/queue'
require 'async/barrier'
require 'async/waiter'
require 'wordlist'

module Ronin
  module Brute
    #
    # Base class for all bruteforcers.
    #
    class Bruteforcer

      include Core::Metadata::ID
      include Core::Metadata::Authors
      include Core::Metadata::Summary
      include Core::Metadata::Description
      include Core::Metadata::References
      include Core::Params::Mixin
      include Support::CLI::Printing

      #
      # Registers the bruteforcer with the given name.
      #
      # @param [String] bruteforcer_id
      #   The bruteforcer's `id`.
      #
      # @api public
      #
      def self.register(bruteforcer_id)
        id(bruteforcer_id)
        Brute.register(bruteforcer_id,self)
      end

      # The usernames to bruteforce.
      #
      # @return [Enumerable]
      attr_reader :usernames

      # The passwords to bruteforce.
      #
      # @return [Enumerable]
      attr_reader :passwords

      # The concurrency of the bruteforcer.
      #
      # @return [Integer]
      attr_reader :concurrency

      #
      # Initializes the bruteforcer.
      #
      # @param [Enumerable] usernames
      #
      # @param [Enumerable] passwords
      #
      # @param [Integer] concurrency
      #   The number of bruteforcer workers to spawn.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments.
      #
      # @option kwargs [Hash{Symbol => Object}] :params
      #   The param values for the bruteforcer.
      #
      def initialize(usernames: , passwords: , concurrency: 100, **kwargs)
        super(**kwargs)

        @usernames = usernames
        @passwords = passwords

        @concurrency = concurrency
      end

      #
      # Finds the first valid username and password combination.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#initialize}.
      #
      # @option kwargs [Wordlist, Enumerable] :usernames
      #   The list of usernames to test.
      #
      # @option kwargs [Wordlist, Enumerable] :passwords
      #   The list of passwords to test.
      #
      # @option kwargs [Integer] :concurrency (100)
      #   The number of bruteforcer workers to spawn.
      #
      # @option kwargs [Hash{Symbol => Object}] :params
      #   Additional params for the bruteforcer.
      #
      # @return [(String, String), nil]
      #   The first valid username and password combination.
      #
      # @api public
      #
      def self.find_first(**kwargs,&block)
        bruteforcer = new(**kwargs)

        bruteforced_credentials = nil

        Async do |task|
          bruteforced_credentials = bruteforcer.find_first(task)
        end

        return bruteforced_credentials
      end

      #
      # Finds all valid usernames and passwords.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#initialize}.
      #
      # @option kwargs [Wordlist, Enumerable] :usernames
      #   The list of usernames to test.
      #
      # @option kwargs [Wordlist, Enumerable] :passwords
      #   The list of passwords to test.
      #
      # @option kwargs [Integer] :concurrency (100)
      #   The number of bruteforcer workers to spawn.
      #
      # @option kwargs [Hash{Symbol => Object}] :params
      #   Additional params for the bruteforcer.
      #
      # @yield [username, password]
      #   If a block is given, it will be yielded the valid usernames and
      #   passwords.
      #
      # @yieldparam [String] username
      #   A valid username.
      #
      # @yieldparam [String] password
      #   A valid password.
      #
      # @return [Array<(String, String)>]
      #   The valid usernames and passwords.
      #
      # @api public
      #
      def self.find_all(**kwargs,&block)
        bruteforcer = new(**kwargs)

        bruteforced_credentials = []

        Async do |task|
          bruteforced_credentials = bruteforcer.find_all(task,&block)
        end

        return bruteforced_credentials
      end

      #
      # Runs a bruteforcing job with the given credentials.
      #
      # @param [Async::LimitedQueue] credentials
      #   The queue of credentials to test. Credentials are pulled by other
      #   bruteforcing jobs on a first-come first-serve basis.
      #
      # @yield [username, password]
      #   The method must yield discovered valid usernames and passwords.
      #
      # @yieldparam [String] username
      #   A valid username.
      #
      # @yieldparam [String] password
      #   A valid password.
      #
      # @abstract
      #
      def bruteforce(credentials)
        raise(NotImplementedError,"#{self} did not define a #bruteforce method")
      end

      #
      # Finds the first valid username and password.
      #
      # @yieldparam [String] username
      #   A valid username.
      #
      # @yieldparam [String] password
      #   A valid password.
      #
      # @return [(String, String), nil]
      #   The first valid username and password.
      #
      # @api private
      #
      def find_first(task=Async::Task.current)
        credentials = Async::LimitedQueue.new(@concurrency)

        barrier = Async::Barrier.new
        waiter  = Async::Waiter.new(parent: barrier)

        bruteforced_credentials = nil

        barrier.async do |producer_task|
          @usernames.each do |username|
            @passwords.each do |password|
              credentials << [username,password]
            end
          end

          # send the stop messages
          @concurrency.times do
            credentials << nil
          end
        end

        @concurrency.times.map do
          waiter.async do |worker_task|
            bruteforce(credentials) do |username,password|
              bruteforced_credentials = [username, password]
              barrier.stop
              break
            end
          end
        end

        # wait for all workers to complete
        waiter.wait(@concurrency)

        return bruteforced_credentials
      end

      #
      # Finds the all valid username and password.
      #
      # @yield [username, password]
      #   The given block will be passed the valid username and password.
      #
      # @yieldparam [String] username
      #   A valid username.
      #
      # @yieldparam [String] password
      #   A valid password.
      #
      # @return [Array<(String, String)>]
      #   The list of valid usernames and passwords.
      #
      # @api private
      #
      def find_all(task=Async::Task.current)
        credentials = Async::LimitedQueue.new(@concurrency)

        barrier = Async::Barrier.new
        waiter  = Async::Waiter.new(parent: barrier)

        bruteforced_credentials = []
        bruteforced_usernames   = Set.new

        task.async do |producer_task|
          @usernames.each do |username|
            @passwords.each do |password|
              # skip the username if it's already been bruteforced
              break if bruteforced_usernames.include?(username)

              credentials << [username,password]
            end
          end

          # send the stop messages
          @concurrency.times do
            credentials << nil
          end
        end

        @concurrency.times do
          waiter.async do |worker_task|
            bruteforce(credentials) do |username,password|
              yield username, password if block_given?

              bruteforced_credentials << [username, password]
              bruteforced_usernames   << username
            end
          end
        end

        return bruteforced_credentials
      end

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
        :bruteforcer
      end

    end
  end
end
