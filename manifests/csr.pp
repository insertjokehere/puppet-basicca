define basicca::csr($subject=undef, $key, $saveto, $owner="root", $group="root", $mode="0600", $config=undef, $altNames=undef, $altNamesEnv="ALTNAME") {

	if ($subject == undef and $config == undef) {
		fail("Must specify one of subject or config")
	}

	if ($altNames != undef and $config == undef) {
		fail("Must specify a config file for altNames to work")
	}

	if ($config != undef) {
		$config_cmd = "-config ${config}"
	}

	if ($altNames != undef) {
		if(is_array($altNames)) {
			# ["a","b"] => "a,DNS:b" => "DNS:a,DNS:b"
			$st = join($altNames,",DNS:")
			$altNameStr = "DNS:${st}"
		} else {
			$altNameStr=$altNames
		}
	} else {
		$altNameStr=""
	}

	if ($subject != undef) {
		if (is_hash($subject)) {
			# { CN=>'a', DC=>'b'} => ["CN=a", "DC=b"] => "CN=a/DC=b" => "-subject '/CN=a/DC=b'"
			$dn = join(join_keys_to_values($subject,"="),"/")
			$subject_cmd = "-subj '/${dn}'"
		} else {
			$subject_cmd = "-subj '${subject}'"
		}
	} else {
		$subject_cmd = ""
	}

	exec { $name:
		command => "/usr/bin/openssl req -new -key ${key} -out ${saveto} ${subject_cmd} ${config_cmd}",
		creates => $saveto,
		environment => "${altNamesEnv}=$altNameStr",
	}

	file { $saveto:
		ensure  => file,
		owner   => $owner,
		group   => $group,
		mode    => $mode,
		require => Exec[$name],
	}

}