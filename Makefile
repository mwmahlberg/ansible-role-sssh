# ansible-role-sssh - Role for configuring your sshd according to https://stribika.github.io/2015/01/04/secure-secure-shell.html
#
# Copyright (C) 2018  Markus Mahlberg <markus.mahlberg@icloud.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# VAGRANT := $(which vagrant)
#
# ifndef VAGRANT
#     $(error vagrant is not available. Please install vagrant)
# endif

.PHONY: test prepare provision up upgrade generate clean

MODULI_SIZE ?= 1024

test: up provision

prepare: up
	vagrant provision --provision-with shell

provision: prepare
	vagrant provision --provision-with ansible

up:
	@vagrant up --no-provision

upgrade:
	vagrant box update

generate: prepare
	$(info Generating new modulus files with $(MODULI_SIZE) bit moduli)
	d=$$(date +%s)\
	; ANSIBLE_ARGS='--extra-vars "sssh_moduli_generate=true sssh_moduli_size=$(MODULI_SIZE)"' vagrant provision --provision-with ansible \
	&& echo "Build took $$(($$(date +%s)-d)) seconds"


clean:
	@vagrant destroy -f
