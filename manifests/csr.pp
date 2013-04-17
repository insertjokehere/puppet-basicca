define basicca::csr($subject=undef, $key, $saveto, $owner="root", $group="root", $mode="0600", $config=undef) {

	if ($config != undef) {
		$config_cmd = "-config ${config}"
	}

	if ($subject != undef) {
		if (is_hash($subject)) {
			# { CN=>'a', DC=>'b'} => ["CN=a", "DC=b"] => "CN=a/DC=b" => "-subject '/CN=a/DC=b'"
			$dn = join(join_keys_to_values($subject,"="),"/")
			$subject_cmd = "-subject '/${dn}'"
		} else {
			$subject_cmd = "-subject '${subject}'"
		}
	} else {
		$subject_cmd = ""
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