define basicca::csr($subject=undef, $key, $saveto, $owner="root", $group="root", $mode="0600", $config=undef) {

	if ($config != undef) {
		$config_cmd = "-config ${config}"
	}

	if ($subject != undef) {
		$subject_cmd = "-subject '${subject}'"
	}

	exec { $name:
		command => "/usr/bin/openssl req -new -key ${key} -out ${saveto} ${subject_cmd} ${config_cmd}",
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