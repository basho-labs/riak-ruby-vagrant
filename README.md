riak-ruby-vagrant
=================

Vagrant environment for testing riak-ruby-client with Riak 2. This is better and easier than working
with the test-server support from older versions of riak-ruby-client.

This almost certainly works for testing other Riak clients, apps using Riak, and just playing around 
with. It's not designed for production use. **Do not use this in production.**

Getting Started
===============

0. If you haven't got it, install [Vagrant](http://vagrantup.com).
1. If you haven't got it or another Vagrant-supported virtualization
   package, install [VirtualBox](https://www.virtualbox.org).
1. Clone this repo: `git clone https://github.com/basho-labs/riak-ruby-vagrant.git`
2. `cd` into this repo: `cd riak-ruby-vagrant`
3. Run `vagrant up` to start the VM build process.
4. Wait a while. The last line of the `vagrant up` output should be `pong`.
3. Riak 2 is now running in a virtual machine, listening for protobuffs on localhost:17017 ,
   and HTTP at http://localhost:17018/ .

Configuration Notes
===================

The Riak instance has:

* [Yokozuna full-text search](https://github.com/basho/yokozuna) (or "yz") enabled. I use this to test
  the client's yz support, as well as [other gems](https://github.com/bkerley/riak-yz-query)
  that also use yz search. To support yz, the Oracle JVM is installed. Yokozuna uses the "yokozuna" bucket
  type.
* [Active Anti-Entropy](http://docs.basho.com/riak/latest/theory/concepts/glossary/#Active-Anti-Entropy-AAE-) 
  enabled. This has a bit of disk and IO overhead, but is necessary for yz.
* [LevelDB backend](http://docs.basho.com/riak/latest/ops/advanced/backends/leveldb/) configured;
  2i works, kv and yz data persist. The disk usage may grow, in which case, destroy and re-up the
  VM.
* [allow_mult](http://docs.basho.com/riak/latest/theory/concepts/Vector-Clocks/#Siblings) enabled
  by default, because I need to test how the client handles sibling resolution and CRDTs.
* Bucket types for Set, Counter, and Map CRDTs. They're called "sets", "counters", and "maps" respectively.
* [Security](http://docs.basho.com/riak/latest/ops/running/authz/) for protocol buffers is configured but
  not completely enabled. The configured user has the username "user" and the password "password". There's
  also "certuser" identified by a client cert (which ships with the 
  [ruby-client](https://github.com/basho/riak-ruby-client/tree/master/spec/support/certs) ).

Enabling and Disabling Security
===============================

Enabling:
```
your-machine> vagrant ssh
Welcome to Ubuntu 12.04.1 LTS (GNU/Linux 3.2.0-29-virtual x86_64)

vagrant@precise64:~$ sudo riak-admin security enable
Enabled
```

Disabling:
```sh
your-machine> vagrant ssh
Welcome to Ubuntu 12.04.1 LTS (GNU/Linux 3.2.0-29-virtual x86_64)

vagrant@precise64:~$ sudo riak-admin security disable
Disabled
```

Support and Contributions
=========================

**This tool is provided without support.** Definitely do not ever use this in production, it's strictly
a development tool.

If you'd like to contribute, fork and make a pull request.

Thanks!
