class basicca::cert($StoreDir="/var/ssl", $subject) {

	basicca::privatekey { "${name}-private":
		saveto => "{$StoreDir}/${name}.key",
	}

	basicca::csr { "${name}-csr":
		saveto => "{$StoreDir}/${name}.csr",
		key	   => "{$StoreDir}/${name}.key",
		subject => $subject,
		require => Basicca::Privatekey["${name}-private"],
	}

}