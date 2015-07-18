#!/bin/sh
set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL http://get.iron.io/cli | sh'
# or:
#   'wget -qO- http://get.iron.io/cli | sh'
#

# UPDATE RELEASE HERE AFTER A NEW VERSION IS RELEASED
# TODO latest ?
release='v0.0.15'

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

case "$(uname -m)" in
  *64)
    ;;
  *)
    echo >&2 'Error: you are not using a 64bit platform.'
    echo >&2 'Iron CLI currently only supports 64bit platforms.'
    exit 1
    ;;
esac

if command_exists iron ; then
  echo >&2 'Warning: "iron" command appears to already exist.'
  echo >&2 'If you are just upgrading your iron cli client, ignore this and wait a few seconds.'
  echo >&2 'You may press Ctrl+C now to abort this process.'
  ( set -x; sleep 5 )
fi

user="$(id -un 2>/dev/null || true)"

sh_c='sh -c'
if [ "$user" != 'root' ]; then
  if command_exists sudo; then
    sh_c='sudo -E sh -c'
  elif command_exists su; then
    sh_c='su -c'
  else
    echo >&2 'Error: this installer needs the ability to run commands as root.'
    echo >&2 'We are unable to find either "sudo" or "su" available to make this happen.'
    exit 1
  fi
fi

curl=''
if command_exists curl; then
  curl='curl -sSL -o'
elif command_exists wget; then
  curl='wget -qO'
elif command_exists busybox && busybox --list-modules | grep -q wget; then
  curl='busybox wget -qO'
else
    echo >&2 'Error: this installer needs the ability to run wget or curl.'
    echo >&2 'We are unable to find either "wget" or "curl" available to make this happen.'
    exit 1
fi

url='https://github.com/iron-io/ironcli/releases/download'

# perform some very rudimentary platform detection
case "$(uname)" in
  Linux)
    $sh_c "$curl /usr/local/bin/iron $url/$release/ironcli_linux"
    $sh_c "chmod +x /usr/local/bin/iron"
    iron --version
    exit 0
    ;;
  Darwin)
    $sh_c "$curl /usr/local/bin/iron $url/$release/ironcli_mac"
    $sh_c "chmod +x /usr/local/bin/iron"
    iron --version
    exit 0
    ;;
  WindowsNT)
    $sh_c "$curl $url/$release/ironcli.exe"
    # TODO how to make executable? chmod?
    iron --version
    exit 0
    ;;
esac

cat >&2 <<'EOF'

  Either your platform is not easily detectable or is not supported by this
  installer script (yet - PRs welcome! [install.sh]).
  Please visit the following URL for more detailed installation instructions:

    https://github.com/iron-io/ironcli

EOF
exit 1
