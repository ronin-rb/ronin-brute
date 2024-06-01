# ronin-brute-run 1 "2024-01-01" Ronin Brute "User Manuals"

## NAME

ronin-brute-run - Loads and runs a bruteforcer

## SYNOPSIS

`ronin-brute run` [*options*] {`-f` *FILE* \| *NAME*}

## DESCRIPTION

Loads a bruteforcer and runs it against a target.

## ARGUMENTS

*NAME*
: The name of the bruteforcer to load and run.

## OPTIONS

`-f`, `--file` *FILE*
: The file to load the bruteforcer from.

`-p`, `--param` *NAME*`=`*VALUE*
: Sets a param for the bruteforcer.

`-U`, `--usernames` *FILE*
: Bruteforces the usernames listed in the text *FILE*.

`-P`, `--passwords` *FILE*
: Bruteforces the passwords listed in the text *FILE*.

`-c`, `--concurrency` *WORKERS*
: Sets the number of bruteforcer workers to run in parallel.

`-F`, `--first`
: Stops bruteforcing once the first valid username and password combination is
  found.

`-A`, `--all`
: Finds all valid username and password combinations.

`-h`, `--help`
: Prints help information.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-brute-list](ronin-brute-list.1.md) [ronin-brute-show](ronin-brute-show.1.md)
