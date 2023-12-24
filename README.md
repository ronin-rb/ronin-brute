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

* Uses asynchronous I/O and fibers.
* Supports defining new bruteforcer modules as plain old Ruby class.
* Supports builtin bruteforcers for:
  * HTTP Basic-Auth
  * HTTP login form
  * FTP
  * POP3
  * IMAP
  * SSH
* Supports loading additional bruteforcer modules from Ruby files or from
  installed [3rd-party git repositories][ronin-repos].

## Synopsis

```shell
$ ronin-brute
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

* [Ruby] >= 3.0.0
* [async-io] ~> 1.0
* [async-http] ~> 0.60
* [net-ssh] ~> 7.2
* [wordlist] ~> 1.0
* [ronin-support] ~> 1.0
* [ronin-core] ~> 0.1
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
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)

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
[async-io]: https://github.com/socketry/async-io#readme
[async-http]: https://github.com/socketry/async-http#readme
[net-ssh]: https://github.com/net-ssh/net-ssh#readme
[wordlist]: https://github.com/postmodern/wordlist.rb#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
[ronin-core]: https://github.com/ronin-rb/ronin-core#readme
[ronin-repos]: https://github.com/ronin-rb/ronin-repos#readme
