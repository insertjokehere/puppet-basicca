define basicca::csr($subject=undef, $key, $saveto, $owner="root", $group="root", $mode="0444", $config=undef) {

	if ($subject == undef and $config == undef) {
		fail("Must specify one of subject or config")
	}

	if ($config != undef) {
		$config_cmd = "-config ${config}"
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
		command => "/usr/bin/openssl req -new -key ${key} -out ${saveto} -sha256 ${subject_cmd} ${config_cmd}",
		creates => $saveto,
		require => $req,
	}

	file { $saveto:
		ensure  => file,
		owner   => $owner,
		group   => $group,
		mode    => $mode,
		require => Exec[$name],
	}

}
