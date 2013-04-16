define basicca::csr($subject=undef, $key, $saveto, $owner="root", $group="root", $mode="0600", $config=undef) {

	if ($config != undef) {
		$config = "-config ${config}"
	}

	if ($subject != undef) {
		$subject = "-subject '${subject}'"
	}

	exec { $name:
		command => "/usr/bin/openssl req -new -key ${key} -out ${saveto} ${subject} ${config}",
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