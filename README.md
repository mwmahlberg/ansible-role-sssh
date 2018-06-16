# ansible-role-sssh [![Build Status](https://travis-ci.org/mwmahlberg/ansible-role-sssh.svg?branch=master)](https://travis-ci.org/mwmahlberg/ansible-role-sssh)

Ansible role for a Secure Secure Shell

---
<!-- TOC START min:2 max:3 link:true update:true -->
- [Motivation](#motivation)
- [Installation](#installation)

<!-- TOC END -->
---

## Motivation

While SSH offers quite some security, its security heavily depends on its configuration.

Generally speaking, SSH aims to provide

1. The ability for the user to make sure he is talking to the endpoint he wants to talk to (server authentication)
2. Encrypted communication, so that the user can be sure that his or her credentials and command are sent to the server securely
3. the ability for the server to authenticate the user who wants to communicate.

This is achieved through a variety of mechanisms discussed in depth elsewhere. But the bottom line is: if the ssh server is not configured correctly, the security provided by the use of SSH may be reduced or even be eliminated.

This repositoy contains an [ansible][wp:ansible] role based on [@stribika][gh:stribika]'s excellent [blog post on securely configuring the OpenSSH server][gh:sssh]. If you have not read it yet, I strongly recommend doing so.

## Installation



<a href="https://asciinema.org/a/8KMZN2sPiSIfC29bqMqvBacFD?speed=2&theme=monokai&autoplay=1" target="_blank"><img src="https://asciinema.org/a/8KMZN2sPiSIfC29bqMqvBacFD.png"  width="250"/></a>



[wp:ansible]: https://en.wikipedia.org/wiki/Ansible_(software) "Wikipedia article on ansible"

[gh:stribika]: https://stribika.github.io

[gh:sssh]:https://stribika.github.io/2015/01/04/secure-secure-shell.html
