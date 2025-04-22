ansible-role-sssh
=================

[![GitHub license](https://img.shields.io/github/license/mwmahlberg/ansible-role-sssh.svg)](https://github.com/mwmahlberg/ansible-role-sssh/blob/master/LICENSE) [![Build Status](https://travis-ci.org/mwmahlberg/ansible-role-sssh.svg?branch=master)](https://travis-ci.org/mwmahlberg/ansible-role-sssh) ![GitHub issues](https://img.shields.io/github/issues-raw/mwmahlberg/ansible-role-sssh)

Ansible role for a Secure OpenSSH configuration.

> :warning: All versions prior to 1.2.2 contain a [bug which causes both the ED25519 and RSA key files to contain ED25519 keys](https://github.com/mwmahlberg/ansible-role-sssh/issues/8).
>
> You should update immediately.

---

<!-- @import "[TOC]" {cmd="toc" depthFrom=2 depthTo=3 orderedList=false} -->

<!-- code_chunk_output -->

- [Motivation](#motivation)
- [What does the role configure?](#what-does-the-role-configure)
  - [Protocol version](#protocol-version)
  - [Key Exchange algorithms](#key-exchange-algorithms)
  - [Ciphers](#ciphers)
  - [Message Authentication Codes](#message-authentication-codes)
  - [Server Authentication](#server-authentication)
  - [Client Authentication](#client-authentication)
  - [Optional: `/etc/ssh/moduli`](#optional-etcsshmoduli)
- [Supported Operating Systems and Versions](#supported-operating-systems-and-versions)
- [Test matrix](#test-matrix)
- [Installation](#installation)
- [Role variables](#role-variables)
  - [Overview](#overview)
  - [Notes on variables](#notes-on-variables)
    - [sssh\_moduli\_generate](#sssh_moduli_generate)
    - [sssh\_moduli\_size](#sssh_moduli_size)
- [Usage](#usage)
  - [Instructions](#instructions)
  - [Screencast](#screencast)

<!-- /code_chunk_output -->
---

## Motivation

While SSH offers quite some security, its security heavily depends on its configuration.

Generally speaking, SSH aims to provide

1. The ability for the user to make sure he is talking to the endpoint he wants to talk to (server authentication)
2. Encrypted communication, so that the user can be sure that his or her credentials and command are sent to the server securely
3. the ability for the server to authenticate the user who wants to communicate.

This is achieved through a variety of mechanisms discussed in depth elsewhere.
But the bottom line is: if the ssh server is not configured correctly,
the security provided by the use of SSH may be reduced or even be eliminated.

This repository contains an [ansible][wp:ansible] role based on[@stribika][gh:stribika]'s
excellent [blog post on securely configuring the OpenSSH server][gh:sssh].
If you have not read it yet, I strongly recommend doing so.

## What does the role configure?

The role configures various aspects of OpenSSH, explained below.

### Protocol version

The SSH protocol version is limited to version 2, as there are
[several problems with protocol version 1][wp:ssh-vulnerabilities-v1]

### Key Exchange algorithms

In the initial stages of an SSH connection, the client and the server negotiate
a random session key to encrypt the communication. If an attacker can get hold
of the session key, he or she can eavesdrop the remaining communication.
Therefor it is important to secure the initial key exchange. This means using
only the most trustworthy algorithms with proper key sizes.

Per [default](#overview), only the libssh.org implementation of curve25519-sha256
and diffie-hellman-group-exchange-sha256 are allowed.

### Ciphers

The ciphers are used to encrypt the actual communication between
the client and the server. Since there is a
[known vulnerability on the CBC cipher mode][wp:ssh-vulnerabilities-cbc],
all ciphers using this mode are excluded by default.

The DES and and RC4 ciphers are not deemed suffciently secured any more and therefor
are excluded by default.

> **Note**<br/>
> You might wonder why `aes128-gcm@openssh.com` and `aes128-ctr` are included
> by default. Since they are run in [Counter Mode (ctr)][wp:ctr] or [Galois/Counter Mode(gcm)][wp:gcm]
> they are considered suffciently secure, despite its relative small key size.

### Message Authentication Codes

The Message Authentication Codes (MACs) are used to ensure that a message has not been
modified by a third party and that the message was actually sent by the communication partner.

> *There are multiple ways to combine ciphers and MACs - not all of these are useful. The 3 most common:<br/>
> Encrypt-then-MAC: encrypt the message, then attach the MAC of the ciphertext.<br/>
> MAC-then-encrypt: attach the MAC of the plaintext, then encrypt everything.<br/>
> Encrypt-and-MAC: encrypt the message, then attach the MAC of the plaintext.<br/>
> <br/>*
> excerpt from [@stribika's blog post on Secure SSH][gh:sssh]

Only MACs which attach the MAC of the cyphertext ("Encrypt-then-MAC") are permitted
by default.

### Server Authentication

The server authenticates itself to the client so that the client can be sure
to communicate with the correct endpoint. The authentication is done via public
key algotithms.

When the client could not authenticate that he or she is communicating with the
intended server, a man-in-the-middle attack could easily  be mounted.

As of the time of this writing, there are four public key algorithms  available:

 - DSA
 - RSA
 - ECDSA
 - ED25519

The DSA algorithm has a fixed keylength of 1024, which is not considered secure nowadays.

The ECDSA relies on questionable elliptic curves and should therefor not be used.

Hence, only the RSA and ED25519 algorithms are permitted and the DSA and ECDSA keys
are removed.

### Client Authentication

The client authentication will be limited to Public Key Authentication.

> **WARNING** <br/>
> After applying this role on a server, you will not be able to log into
> that server via SSH using passwords  any more!<br/>
> Make ***sure*** you have Public Key Authentication ***tested*** for your administrative
> account.

### Optional: `/etc/ssh/moduli`

The file `/etc/ssh/moduli` file is used by the diffie-hellman-group-exchange-sha256 key
exchange algorithm to provide suffciently large prime numbers.

If you set `sssh_moduli_generate` to true and `sssh_kex_algorithms` contains
"diffie-hellman-group-exchange-sha256", new moduli will be generated with a bit size
of `sssh_moduli_size`.

The generation is a two-step process. First, a large number of large numbers are generated.
In the second step, those numbers are tested wether they are actually suffciently large
prime numbers.

Note that with the default setting of 4096 for `sssh_moduli_size` this process
will take at least hours, if not days to finish. This is a failsafe default,
so that when you accidentally activate the regeneration of `/etc/ssh/moduli`,
you end up with a rock solid state.

As of the time of this writing, a `sssh_moduli_size` of 1024 is considered secure
by todays standards. A size of 2048 bit is considered secure for the foreseeable
future.

## Supported Operating Systems and Versions

Since I am limited in the time I can put into this project, this role will support the last two releases of the following operating systems.

* CentOS and RedHat Enterprise Linux
* Debian
* Ubuntu (last two LTS releases)

As for the exact versions, please see [the role information on Galaxy](https://galaxy.ansible.com/mwmahlberg/sssh).

## Test matrix

The role is tested against a complete matrix consisting of the following:

* Python Versions 3.6, 3.7 and 3.8
* Ansible Versions 2.9.2, 2.9.8, 2.9.9 and 2.9.10
* OS Versions:
  * AmazonLinux 2023
  * RockLinux 9
  * Debian 11 and 12
  * Ubuntu 20.04 and 22.04

Before using the role in production, I strongly suggest to [look up whether your specific setup
was successfully tested](https://travis-ci.org/github/mwmahlberg/ansible-role-sssh).

## Installation

Simply drop

    $ ansible-galaxy install mwmahlberg.sssh

into your shell.

## Role variables

Below you will find the variables used in this role.

### Overview
---

| Name                 | Default  | Description                                   |
| -------------------- | -------- | --------------------------------------------- |
| sssh_moduli_generate | false    | wether a new modulus file should be generated |
| sssh_moduli_size     | 4096     | size of each individual modulus               |
| sssh_kex_algorithms  | - `curve25519-sha256@libssh.org`<br/> - `diffie-hellman-group-exchange-sha256` | key exchange algorithms permitted |
| sssh_ciphers         |<br/> - `aes256-gcm@openssh.com`<br/> - `aes256-ctr`<br/> - `chacha20-poly1305@openssh.com`<br/> - `aes192-ctr`<br/> - `aes128-gcm@openssh.com`<br/> - `aes128-ctr` | sssh_ciphers supported for encryption |
| sssh_macs            |- `hmac-sha2-512-etm@openssh.com`<br/>- `hmac-sha2-256-etm@openssh.com`<br/>- `umac-128-etm@openssh.com`<br/>- `hmac-sha2-512`<br/>- `hmac-sha2-256`<br/>- `umac-128@openssh.com`<br/>| Message Authentication Codes supported |

---
### Notes on variables
#### sssh_moduli_generate
If set to `true`, the file [`/etc/ssh/moduli`][man:moduli] will be regenerated.

> **Warning** <br/>
> With the default `sssh_moduli_size` of 4096, the generated moduli will be *very* secure.<br/>
> The downside of it is that the generation will take hours to even *days*.<br/>
> You should choose a proper [modulus size](#sssh_moduli_size) carefully.

It should only be set to `true` via commandline. If you set this to `true` in a playbook or inventory,
`/etc/ssh/moduli` will be generated _each time_ the role is applied.

This setting is useless when you exclude `diffie-hellman-group-exchange-sha256`
from `ssh_kex_algotithms` and will be ignored in this case.

#### sssh_moduli_size

The minimum modulus size is 1024 and is considered suffciently secure as of the time of this writing.
However, the suggested modulus size is 2048, which is considered secure in the foreseeable future.

The default value for `sssh_moduli_size` is 4096. This roughly translates to "Should be secure for all practical purposes".

## Usage

### Instructions

0. **Make sure you have Public Key Authentication tested on all target hosts!**
   Otherwise, you will not be able to log in to the target hosts via SSH any more
   after applying the role.
   See [Client authentication](#client-authentication) for details.
1. Add the role to the requirements of your playbook
    ```
    $ cd ~/path/to/playbook/dir
    $ echo "- src: mwmahlberg.sssh" >> requirements.yml
    ```
1. Install your requirements
    ```
    $ ansible-galaxy install -r requirements.yml
    ```
1. Assign the role to a host or a group and [configure it](#configure-it-to-your-needs).
    ```
    - hosts: all
      vars:
        sssh_kex_algorithms:
          - "curve25519-sha256@libssh.org"
      roles:
        - mwmahlberg.sssh
    ```
1. Run your playbook

### Screencast

[![asciicast](https://asciinema.org/a/187545.svg)](https://asciinema.org/a/187545?autoplay=1)


[wp:ansible]: https://en.wikipedia.org/wiki/Ansible_(software) "Wikipedia article on ansible"
[wp:ssh-vulnerabilities-v1]: https://en.wikipedia.org/wiki/Secure_Shell#SSH-1
[wp:ssh-vulnerabilities-cbc]: https://en.wikipedia.org/wiki/Secure_Shell#CBC_plaintext_recovery
[wp:ctr]: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#CTR
[wp:gcm]: https://en.wikipedia.org/wiki/Galois/Counter_Mode
[gh:stribika]: https://stribika.github.io
[gh:sssh]: https://stribika.github.io/2015/01/04/secure-secure-shell.html

[man:moduli]: https://linux.die.net/man/5/moduli
[se:moduli]: https://security.stackexchange.com/questions/41941/consequences-of-tampered-etc-ssh-moduli

[ansible:requirements.yml]: https://docs.ansible.com/ansible/latest/reference_appendices/galaxy.html#installing-multiple-roles-from-a-file
