class basicca::selfsignedcert(days=365) inherets basicca::cert {

	exec { "${name}-cert":
		command => "/usr/bin/openssl x509 -req -days ${days} -in {$StoreDir}/${name}.csr -signkey {$StoreDir}/${name}.key -out {$StoreDir}/${name}.crt",
		creates => "{$StoreDir}/${name}.crt",
		require => [Basicca::Privatekey["${name}-private"],Basicca::Privatekey["${name}-csr"]],
	}

}