class basicca::cert($storedir="/var/ssl", $subject) {

	class { "basicca::privatekey":
		saveto => "{$storedir}/${name}.key",
	}

	class { "basicca::csr":
		saveto => "{$storedir}/${name}.csr",
		key	   => "{$storedir}/${name}.key",
		subject => $subject,
		require => Basicca::Privatekey["${name}-private"],
	}

}