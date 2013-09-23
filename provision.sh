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
sudo apt-get install -y build-essential libncurses5-dev openssl libssl-dev

# if [ ! -e oab-java.sh ]; then
#   wget "https://github.com/flexiondotorg/oab-java6/raw/0.3.0/oab-java.sh"
#   chmod +x oab-java.sh
#   sudo ./oab-java.sh -7 -s
#   sudo apt-get install oracle-java7-jre
# fi

download_unless_exist "http://www.erlang.org/download/otp_src_R16B02.tar.gz"

verify_checksum "otp_src_R16B02.tar.gz" 5bd028771290eacbc075ca65a63749e6 || exit

if [ ! -d otp_src_R16B02 ]; then
  tar zxf otp_src_R16B02.tar.gz
  pushd otp_src_R16B02
  ./configure
  make
  sudo make install
  popd
fi

download_unless_exist "http://riak-ruby-vagrant.data.riakcs.net:8080/riak-2.0.0pre1.tar.gz"

verify_checksum "riak-2.0.0pre1.tar.gz" 74581e350b9631edc68bdf8799b7ea16 || exit

if [ ! -d riak-2.0.0pre1 ]; then
  tar zxf "riak-2.0.0pre1.tar.gz"
  pushd "riak-2.0.0pre1"
  make
  make rel
fi
