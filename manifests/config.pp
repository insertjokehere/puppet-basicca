define basicca::config($file=$name, $config, $owner="root", $group="root",$mode="0644") {

	file { $file:
		ensure => present,
		content => template("basicca/openssl.cnf.erb"),
		owner => $owner,
		group => $group,
		mode => $mode,
	}

}