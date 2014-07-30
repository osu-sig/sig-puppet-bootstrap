# sig-puppet bootstrap
#
# Set up git to work through the proxy, then clone sig-puppet repo

$proxy_host = 'proxy.oregonstate.edu'
$proxy_port = '3128'

package { 'git':
    ensure => 'installed',
}

package { 'gcc':
    ensure => 'installed',
}

package { 'wget':
    ensure => 'installed',
}

package { 'make':
    ensure => 'installed',
}

file { '/etc/profile.d/proxy.sh':
    ensure  => 'file',
    mode    => '0644',
    content => "export http_proxy=http://${proxy_host}:$proxy_port\nexport https_proxy=https://${proxy_host}:$proxy_port\n",
}

exec { 'get build_corkscrew script':
    command     => '/usr/bin/wget https://raw.githubusercontent.com/osu-sig/sig-puppet-bootstrap/master/build_corkscrew.sh',
    cwd         => '/root',
    environment => "https_proxy=https://${proxy_host}:$proxy_port",
    creates     => '/root/build_corkscrew.sh',
    require     => [ Package['wget'] ],
    before      => File['/root/build_corkscrew.sh'],
}

file { '/root/build_corkscrew.sh':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
}

exec { 'build corkscrew':
    command     => '/root/build_corkscrew.sh',
    cwd         => '/var/tmp',
    environment => "http_proxy=http://${proxy_host}:$proxy_port",
    creates     => '/usr/local/bin/corkscrew',
    require     => [ Exec['get build_corkscrew script'], Package['gcc'], Package['make'] ],
}

file { '/root/.ssh':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
}

file { '/root/.ssh/config':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    content => "Host github.com\nProxyCommand corkscrew $proxy_host $proxy_port %h %p\nPort 443\nHostname ssh.github.com\n",
    require => File['/root/.ssh'],
}

exec { 'create ssh key':
    command => '/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""',
    user    => 'root',
    group   => 'root',
    creates => '/root/.ssh/id_rsa',
    require => File['/root/.ssh'],
}

sshkey { 'github':
    name   => 'ssh.github.com',
    ensure => 'present',
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
    type   => 'ssh-rsa',
}

exec { 'get push_ssh_key script':
    command     => '/usr/bin/wget https://raw.githubusercontent.com/osu-sig/sig-puppet-bootstrap/master/push_ssh_key.sh',
    cwd         => '/root',
    environment => "https_proxy=https://${proxy_host}:$proxy_port",
    creates     => '/root/push_ssh_key.sh',
    require     => [ Package['wget'] ],
    before      => File['/root/push_ssh_key.sh'],
}

file { '/root/push_ssh_key.sh':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
}

exec { 'push ssh key to github':
    command     => '/root/push_ssh_key.sh',
    cwd         => '/root',
    environment => "https_proxy=https://${proxy_host}:$proxy_port",
    require     => [ Exec['get push_ssh_key script'], Exec['create ssh key'] ],
}

exec { 'clone sig-puppet git repo':
    command => '/usr/bin/git clone git@github.com:osu-sig/sig-puppet.git puppet',
    cwd     => '/opt',
    creates => '/opt/puppet/README.md',
    require => [ Exec['push ssh key to github'], Exec['build corkscrew'], Package['git'] ],
}

exec { 'git submodule init':
    command => '/usr/bin/git submodule init',
    cwd     => '/opt/puppet',
    require => Exec['clone sig-puppet git repo'],
}

exec { 'git submodule update':
    command     => '/usr/bin/git submodule update',
    cwd         => '/opt/puppet',
    environment => "https_proxy=https://${proxy_host}:$proxy_port",
    require     => Exec['git submodule init'],
}
