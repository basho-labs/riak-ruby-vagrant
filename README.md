riak-ruby-vagrant
=================

Vagrant environment for testing riak-ruby-client with Riak 2. This is better and easier than working
with the test-server support from older versions of riak-ruby-client.

This almost certainly works for testing other Riak clients, apps using Riak, and just playing around 
with. It's not designed for production use. **Do not use this in production.**

Getting Started
===============

1. Clone this repo: `git clone https://github.com/basho-labs/riak-ruby-vagrant.git`
2. Read and do this: http://docs.vagrantup.com/v2/getting-started/index.html
3. Riak 2 should now be running in a virtual machine, listening for protobuffs on localhost:17017 ,
   and HTTP at http://localhost:17018/ .

Configuration Notes
===================

The Riak instance has:

* [Yokozuna full-text search](https://github.com/basho/yokozuna) enabled. I use this to test
  the client's Yokozuna support, as well as [other gems](https://github.com/bkerley/riak-yz-query)
  that also use Yokozuna search. To support Yokozuna, the Oracle JVM is installed.
* [Active Anti-Entropy](http://docs.basho.com/riak/latest/theory/concepts/glossary/#Active-Anti-Entropy-AAE-) 
  disabled. AAE ads a bunch of overhead, no real APIs we need to test, and I manually control entropy
  by deleting the data directory when it gets big.
* [Memory backend](http://docs.basho.com/riak/latest/ops/advanced/backends/memory/) configured;
  2i works, rebooting the vagrant instance clears the kv data (but not yz), and it makes the disk footprint 
  grow slower.
* [allow_mult](http://docs.basho.com/riak/latest/theory/concepts/Vector-Clocks/#Siblings) enabled
  by default, because I need to test how the client handles sibling resolution and CRDTs.
* Bucket types for Set, Counter, and Map CRDTs. They're called "sets", "counters", and "maps" respectively.

Support and Contributions
=========================

**This tool is provided without support.** Definitely do not ever use this in production, it's strictly
a development tool.

If you'd like to contribute, fork and make a pull request.

Thanks!
