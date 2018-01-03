# ansible-demo

Ansible scripts for Cisco Live Barcelona Demo

## Build requirements

### General

 * [Python 2.7](https://www.python.org/)
   * Installed by default on OS X
 * [Virtualenv][]
   * `pip install virtualenv`

## Basic usage

There are a set of `.sh` scripts in the root directory, which wrap calls to
`ansible-playbook`, so that we are calling it consistently. Each script has a
`--help` option for more details.

Each script also honors a `--` option, for passing options directly to
`ansible-playbook`. This allows you to pass additional options for running the
playbook.

    $ ./deploy.sh -- --limit mariadb


## Deploy

    $ ./deploy.sh --env test

### `-- [ansible-options]`

    $ ./deploy.sh --env test -- --limit distribution

As mentioned above, to pass arbitrary option to the `ansible-playbook` call, you
can set them after the `--` option. This is especially useful for passing along
`--tags`, `--limit` or `--check`.

## Development

The infrastructure scripts must be idempotent. It should be safe to simple run
`./deploy.sh` at any time, without any ill effects or unexpected behavior.

The automation scripts are primarily [Ansible][] scripts. A [Virtualenv][] is
used to ensure that the proper version of Ansible and its dependencies are used.
The contents of the virtualenv are in `requirements.txt`. The `activate.sh`
manages the virtualenv, and activates it for the shell.

Please see [Simply Ansible][] for Ansible best practices for writing new
roles/playbooks.

# License

MIT license

 [ansible galaxy]: https://galaxy.ansible.com/
 [ansible]: https://www.ansible.com/
 [simply ansible]: https://github.com/building5/simply-ansible/tree/master/docs
 [virtualenv]: https://virtualenv.pypa.io/en/stable/
