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
sudo apt-get install -y build-essential libncurses5-dev openssl libssl-dev git curl libpam0g-dev expect python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java7-installer

curl https://packagecloud.io/install/repositories/basho/riak/script.deb | sudo bash

sudo apt-get install -y riak

sudo apt-get install -f

echo 'search = on' >> /etc/riak/riak.conf
echo 'storage_backend = leveldb' >> /etc/riak/riak.conf
echo 'listener.http.internal = 0.0.0.0:8098' >> /etc/riak/riak.conf
echo 'listener.protobuf.internal = 0.0.0.0:8087' >> /etc/riak/riak.conf
echo 'ssl.certfile = /vagrant/certs/server.crt' >> /etc/riak/riak.conf
echo 'ssl.keyfile = /vagrant/certs/server.key' >> /etc/riak/riak.conf
echo 'ssl.cacertfile = /vagrant/certs/ca.crt' >> /etc/riak/riak.conf
echo 'buckets.default.allow_mult = true' >> /etc/riak/riak.conf
echo 'tls_protocols.tlsv1.1 = on' >> /etc/riak/riak.conf
echo 'check_crl = off' >> /etc/riak/riak.conf

ulimit -n 65536
ulimit -n
riak start

riak-admin bucket-type create counters '{"props":{"datatype":"counter", "allow_mult":true}}'
riak-admin bucket-type create other_counters '{"props":{"datatype":"counter", "allow_mult":true}}'
riak-admin bucket-type create maps '{"props":{"datatype":"map", "allow_mult":true}}'
riak-admin bucket-type create sets '{"props":{"datatype":"set", "allow_mult":true}}'
riak-admin bucket-type create yokozuna '{"props":{}}'

riak-admin security add-user user password=password
riak-admin security add-user certuser

riak-admin security add-source user 0.0.0.0/0 password
riak-admin security add-source certuser 0.0.0.0/0 certificate

riak-admin security grant riak_kv.get,riak_kv.put,riak_kv.delete,riak_kv.index,riak_kv.list_keys,riak_kv.list_buckets,riak_core.get_bucket,riak_core.set_bucket,riak_core.get_bucket_type,riak_core.set_bucket_type,search.admin,search.query,riak_kv.mapreduce on any to user

# wait for bucket types to settle
sleep 10

riak-admin bucket-type activate other_counters
riak-admin bucket-type activate counters
riak-admin bucket-type activate maps
riak-admin bucket-type activate sets
riak-admin bucket-type activate yokozuna

riak ping
