class basicca::privatekey($numbits=2048, $owner="root", $group="root", $mode="0600", $saveto) {

	exec { $name:
		command => "/usr/bin/openssl genrsa -out ${saveto} ${numbits}",
		creates => $saveto,
	}

	file { $saveto:
		ensure  => file,
		owner   => $owner,
		group   => $group,
		mode    => $mode,
		require => Exec[$name],
	}

}