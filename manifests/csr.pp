class basicca::csr($subject, $key, $saveto, $owner="root", $group="root", $mode="0600") {

	exec { $name:
		command => "/usr/bin/openssl req -new -key ${key} -out ${saveto} -subj '${subject}'",
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