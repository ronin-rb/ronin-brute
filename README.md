# ronin-brute

[![CI](https://github.com/ronin-rb/ronin-brute/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-brute/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-brute.svg)](https://codeclimate.com/github/ronin-rb/ronin-brute)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-brute)
* [Issues](https://github.com/ronin-rb/ronin-brute/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-brute)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-brute is a micro-framework and tool for bruteforcing network services.

## Features

* Uses asynchronous I/O and fibers for concurrent bruteforcing.
* Supports defining new bruteforcer modules as plain old Ruby class.
* Supports builtin bruteforcers for:
  * HTTP Basic-Auth
  * HTTP login form
  * FTP
  * POP3
  * IMAP
  * MySQL
  * PostgreSQL
  * Telnet
  * SSH
* Supports loading additional bruteforcer modules from Ruby files or from
  installed [3rd-party git repositories][ronin-repos].

## Synopsis

```shell
$ ronin-brute
Usage: ronin-brute [options] [COMMAND [ARGS...]]

Options:
    -V, --version                    Prints the version and exits
    -h, --help                       Print help information

Arguments:
    [COMMAND]                        The command name to run
    [ARGS ...]                       Additional arguments for the command

Commands:
    completion
    help
    list
    run
    show
```

List available bruteforcers:

```
$ ronin-brute list
  ftp
  http/basic_auth
  http/login
  imap
  mysql
  pop3
  ssh
  telnet
```

Install a 3rd-party repository of bruteforcers:

```shell
$ ronin-repos install https://github.com/user/bruteforcers.git
```

Print additional information about a specific bruteforcer:

```shell
$ ronin-brute show NAME
```

Run a bruteforcer against a host:

```shell
ronin-brute run ftp -U usernames.txt -P passwords.txt -p host=example.com
```

## Examples

Start the [bruteforceable `http/basic_auth` docker
container][bruteforceable/http/basic_auth] in another terminal. The valid
credentials are `admin` and `password1234`.

[bruteforceable/http/basic_auth]: https://github.com/ronin-rb/bruteforceable/tree/main/http/basic_auth

Finds the first valid username and password:

```ruby
require 'ronin/brute/builtin/http/basic_auth'

Ronin::Brute::HTTP::BasicAuth.find_first(
  usernames: Wordlist.open('usernames.txt'),
  passwords: Wordlist.open('passwords.txt'),
  params: {
    host: '0.0.0.0',
    port: 8000
  }
)
# => ["admin", "password1234"]
```

## Requirements

* [Ruby] >= 3.1.0
* [async] ~> 2.0
* [async-io] ~> 1.0
* [async-http] ~> 0.60
* [net-telnet] ~> 0.2
* [net-ssh] ~> 7.2
* [ruby-mysql] ~> 4.1
* [postgres-pr] ~> 0.7
* [wordlist] ~> 1.0
* [ronin-support] ~> 1.0
* [ronin-core] ~> 0.2
* [ronin-repos] ~> 0.1

## Install

```shell
$ gem install ronin-brute
```

### Gemfile

```ruby
gem 'ronin-brute', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-brute', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-brute/fork)
2. Clone It!
3. `cd ronin-brute/`
4. `./scripts/setup`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-brute is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-brute is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-brute.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[async]: https://github.com/socketry/async#readme
[async-io]: https://github.com/socketry/async-io#readme
[async-http]: https://github.com/socketry/async-http#readme
[net-telnet]: https://github.com/ruby/net-telnet#readme
[net-ssh]: https://github.com/net-ssh/net-ssh#readme
[ruby-mysql]: https://gitlab.com/tmtms/ruby-mysql#readme
[postgres-pr]: https://github.com/mneumann/postgres-pr#readme
[wordlist]: https://github.com/postmodern/wordlist.rb#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
[ronin-core]: https://github.com/ronin-rb/ronin-core#readme
[ronin-repos]: https://github.com/ronin-rb/ronin-repos#readme
