#!/bin/bash
ansible-playbook site.yml --syntax-check
ansible-lint --exclude build/ site.yml
