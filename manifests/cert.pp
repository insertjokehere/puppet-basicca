define basicca::cert($storedir="/var/ssl", $subject) {

	basicca::privatekey { "${name}-private":
		saveto => "{$storedir}/${name}.key",
	}

	basicca::csr { "${name}-csr":
		saveto => "{$storedir}/${name}.csr",
		key	   => "{$storedir}/${name}.key",
		subject => $subject,
		require => Basicca::Privatekey["${name}-private"],
	}

}