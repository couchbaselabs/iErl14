# iERL14 - Erlang for iOS

Welcome to the build of Erlang Couchbase has constructed for use on iOS devices.

This package should be suitable for use with most Erlang code bases. However, our focus is on getting CouchDB to run on iOS, so this build contains some things that are Couch-specific. 

In the future we plan to cut the build down to the absolutely minimum necessary to support CouchDB, so that Mobile Couchbase uses fewer resources, download bandwidth, etc. Some of these changes may make iErl less suitable for other Erlang programs. If it starts to be a big divergence, we'll perhaps maintain two branches, one optimized for CouchDB, and another suitable for more general applications.

## iOS Specific Changes

There are also a bunch of constraints on iOS. Some of these require us to change Erlang significantly.

### No Dynamic Linking 

iOS Erlang is statically linked, breaking the NIF system. Couchbase Mobile uses the emonk branch of CouchDB, as written by Paul Davis. However, since emonk usually works as a NIF, we had to hack it in statically. See `erl_unix_sys_ddll.c` for how we did that.

This also means the source code for Spidermonkey is embedded in the project and built into the static library, I think. (TODO, verify with Aaron)

### No Subprocesses

The Erlang VM is spawned inside a thread. I guess that's not evident in this source tree, but if you look at the Mobile Couchbase project, you can see how we spawn it. (Look for the call to `erl_start()`)

Due to the no `fork()` rule, DNS lookups can’t use a separate OS process. So we disable `inet_gethost.c` and do it in Erlang code.

A CouchDB-specific note: The query server uses emonk, not `couchjs`, since we can't launch subprocesses.

### Writeable memory can’t be executed 

This means no JIT compilers. I think there are plans for Erlang to do more JIT stuff, that means we're gonna have trouble keeping up with new releases unless it's easy to disable JIT.

## Contributions Welcome

Our #1 goal is to shrink the size of the final static library package. This goal overrides many others, so for instance we might end up changing the CouchDB source so that it doesn't require certain features (would be great to drop PCRE, and probably more.)

Another important goal is cleaning up the build. For instance, if someone were to get this gnarly beast working as a git fork of the official Erlang codebase, it would make keeping up with new releases easier. It would also be easier for Erlangers to see what we've done here.

The best way to communicate with us about this codebase is via our [Google Group  for Mobile Couchbase](https://groups.google.com/group/mobile-couchbase). You can also reach us directly at <mobile@couchbase.com>.

## License information

Erlang is released under the Erlang license. Spidermonkey is under the MPL license. See individual source headers for more information.

Our intention is to release the compilation of all of this under the Apache license, to the extent possible. If folks have input about license compatibility, please communicate them with us.


