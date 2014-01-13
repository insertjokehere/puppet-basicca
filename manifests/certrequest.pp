define basicca::certrequest($keypath, $csrpath, $subject=undef, $config=undef, $keysize=4096, $owner="root", $group="root") {

	basicca::privatekey { "${name}-private":
		saveto  => $keypath,
		owner   => $owner,
		group   => $group,
		numbits => $keysize,
	}

	basicca::csr { "${name}-csr":
		saveto   => $csrpath,
		key	     => $keypath,
		subject  => $subject,
		config   => $config,
		owner    => $owner,
		group    => $group,
		require  => Basicca::Privatekey["${name}-private"],
	}

}
