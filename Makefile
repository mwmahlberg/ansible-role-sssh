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

.PHONY: test up provision generate clean

test: up provision

provision:
	vagrant provision --provision-with ansible

up:
	@vagrant up --no-provision

upgrade:
	vagrant box update

generate: up
	ANSIBLE_ARGS='--extra-vars "moduli_generate=true moduli_size=512"' vagrant provision

clean:
	@vagrant destroy -f
