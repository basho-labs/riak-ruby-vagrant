#!/usr/bin/env bash

# i took these from https://github.com/sstephenson/ruby-build/blob/master/bin/ruby-build
compute_md5() {
  if type md5 &>/dev/null; then
    md5 -q
  elif type openssl &>/dev/null; then
    local output="$(openssl md5)"
    echo "${output##* }"
  elif type md5sum &>/dev/null; then
    local output="$(md5sum -b)"
    echo "${output% *}"
  else
    return 1
  fi
}

verify_checksum() {
  # If there's no MD5 support, return success
  [ -n "$HAS_MD5_SUPPORT" ] || return 0

  # If the specified filename doesn't exist, return success
  local filename="$1"
  [ -e "$filename" ] || return 0

  # If there's no expected checksum, return success
  local expected_checksum=`echo "$2" | tr [A-Z] [a-z]`
  [ -n "$expected_checksum" ] || return 0

  # If the computed checksum is empty, return failure
  local computed_checksum=`echo "$(compute_md5 < "$filename")" | tr [A-Z] [a-z]`
  [ -n "$computed_checksum" ] || return 1

  if [ "$expected_checksum" != "$computed_checksum" ]; then
    { echo
      echo "checksum mismatch: ${filename} (file is corrupt)"
      echo "expected $expected_checksum, got $computed_checksum"
      echo
    } >&4
    return 1
  fi
}

download_unless_exist() {
  local filename=`basename $1`
  local url="$1"
  if [[ -e "$filename" ]]; then
      return 0
  fi
  `wget "$url"`
}


sudo apt-get update
sudo apt-get install -y build-essential m4 autoconf automake libncurses5-dev openssl libssl-dev git curl libpam0g-dev expect python-software-properties default-jdk
# sudo add-apt-repository ppa:webupd8team/java
# sudo apt-get update
# echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
# sudo apt-get install -y oracle-java7-installer
