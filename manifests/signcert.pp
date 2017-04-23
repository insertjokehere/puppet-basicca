define basicca::signcert($signkey, $csr, $saveto, $days=365, $owner="root", $group="root", $mode="0600", $sign_algo='sha256') {

  exec { "${name}-cert":
    command => "/usr/bin/openssl x509 -req -${sign_algo} -days ${days} -in ${csr} -signkey ${signkey} -out ${saveto}",
    creates => $saveto
  }

  file { $saveto:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Exec["${name}-cert"],
  }
}
