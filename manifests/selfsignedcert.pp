define basicca::selfsignedcert($subject=undef, $config=undef, $keypath, $csrpath, $certpath, $owner="root", $group="root", $keysize=4096, $certmode="0644", $issuelength=365) {

	basicca::privatekey { "${name}-private":
		saveto  => $keypath,
		owner   => $owner,
		group   => $group,
		numbits => $keysize,
	}

	basicca::csr { "${name}-csr":
		saveto  => $csrpath,
		key	    => $keypath,
		subject => $subject,
		config  => $config,
		owner   => $owner,
		group   => $group,
		require => Basicca::Privatekey["${name}-private"],
	}

	basicca::signcert { "${name}-cert":
		signkey => $keypath,
		csr     => $csrpath,
		saveto  => $certpath,
		days    => $issuelength,
		owner   => $owner,
		group   => $group,
		mode    => $certmode,
		require => Basicca::Csr["${name}-csr"],
	}

}
