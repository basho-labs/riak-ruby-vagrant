service riak stop
rm -rf /var/lib/riak/anti_entropy
rm -rf /var/lib/riak/leveldb
rm -rf /var/lib/riak/kv_vnode
rm -rf /var/lib/riak/yz
rm -rf /var/lib/riak/yz_anti_entropy
service riak start
