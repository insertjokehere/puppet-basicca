define basicca::certrequest($keypath, $csrpath, $subject=undef, $config=undef, $keysize=2048, $owner="root", $group="root") {

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