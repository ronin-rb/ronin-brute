require 'ronin/brute/root'
require 'ronin/core/cli/completion_command'

module Ronin
  module Brute
    class CLI
      module Commands
        #
        # Manages the shell completion rules for `ronin-brute`.
        #
        # ## Usage
        #
        #     ronin-brute completion [options]
        #
        # ## Options
        #
        #         --print                      Prints the shell completion file
        #         --install                    Installs the shell completion file
        #         --uninstall                  Uninstalls the shell completion file
        #     -h, --help                       Print help information
        #
        # ## Examples
        #
        #     ronin-payloads brute --print
        #     ronin-payloads brute --install
        #     ronin-payloads brute --uninstall
        #
        class Completion < Core::CLI::CompletionCommand

          completion_file File.join(ROOT,'data','completions','ronin-brute')

          man_dir File.join(ROOT,'man')
          man_page 'ronin-brute-completion.1'

          description 'Manages the shell completion rules for ronin-brute'

        end
      end
    end
  end
end
