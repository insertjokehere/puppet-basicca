class basicca::signcert($signkey, $csr, $saveto, $days=365) {

	exec { "${name}-cert":
		command => "/usr/bin/openssl x509 -req -days ${days} -in ${csr} -signkey ${signkey} -out ${saveto}",
		creates => $saveto
	}

}