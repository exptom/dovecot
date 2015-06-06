# 90-plugin.conf *or*
# 90-sieve.conf
class dovecot::sieve (
  $username  = 'vmail',
  $groupname = 'vmail',
  ) {
  include dovecot

  file { ['/var/lib/dovecot/sieve',
          '/var/lib/dovecot/sieve/before',
          '/var/lib/dovecot/sieve/after']:
    ensure  => directory,
    owner   => $username,
    group   => $groupname,
    mode    => '0755',
    require => Package['dovecot-sieve'],
  }

  $package_name = $::osfamily ? {
    'Debian' => 'dovecot-sieve',
    'Redhat' => 'dovecot-pigeonhole',
    default  => 'dovecot-sieve',
  }
  $mailpackages = $::osfamily ? {
    default  => ['dovecot-imapd', 'dovecot-pop3d'],
    'Debian' => ['dovecot-imapd', 'dovecot-pop3d'],
    'Redhat' => ['dovecot',]
  }

  package { $package_name :
      ensure  => installed,
      before  => Exec['dovecot'],
      require => Package[$mailpackages],
      alias   => 'dovecot-sieve',
  }

  dovecot::config::dovecotcfmulti { 'plugin':
    config_file => 'conf.d/90-plugin.conf',
    changes     => [
      "set plugin/sieve '~/.dovecot.sieve'",
      "set plugin/sieve_dir '~/sieve'",
      "set plugin/sieve_before '/var/lib/dovecot/sieve/before'",
      "set plugin/sieve_after '/var/lib/dovecot/sieve/after'",
      ],
  }
}
