
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
