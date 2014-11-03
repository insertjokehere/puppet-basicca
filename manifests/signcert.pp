define basicca::signcert($signkey, $csr, $saveto, $days=365, $owner="root", $group="root", $mode="0600") {

	exec { "${name}-cert":
		command => "/usr/bin/openssl x509 -req -sha256 -days ${days} -in ${csr} -signkey ${signkey} -out ${saveto}",
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
