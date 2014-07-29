# sig-puppet-bootstrap

Set up git to work through a proxy, then clone the sig-puppet repo.

Requires Puppet 3. Tested only on Centos6 for now.

## Usage

Copy `bootstrap.pp` onto the server.

```
[root@somebox ~]# puppet apply bootstrap.pp
```
