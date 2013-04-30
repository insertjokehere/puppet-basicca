define basicca::ca($caroot, $cadistinguisedname, $caconfig={}, $issuepolicy = {}, $issuelength=365, $keysize=2048) {

	user { "ca":
		home => "${caroot}",
		ensure => present,
		shell => "/bin/bash",
		gid => "ca",
		require => Group["ca"],
	}

	group { "ca":
		ensure => present,
	}

	file { $caroot:
		ensure => directory,
		owner => "ca",
		group => "ca",
		mode => "0750",
		require => User["ca"],
	}

	$defaultconfig = { 	"ca" => { "default_ca" => "puppetca", },
						"req" => { 	"default_keyfile" 	=> "${caroot}/private/ca.key",
									"default_md" 		=> "sha1",
									"prompt"			=> "no",
									"req_extensions" 	=> "v3_req",
									"subjectKeyIdentifier" => "hash",
									"authorityKeyIdentifier" => "keyid:always,issuer",
									"string_mask" 		=> "utf8only",
									"basicConstraints" 	=> "CA:true",
									"distinguished_name"=> "ca_dn",
									"x509_extensions" 	=> "ca_extensions", },
						"ca_extensions" => { "basicConstraints" => "CA:true", },
	 }

	$defaultcacfg = { 	"dir" 			=> $caroot,
						"certs" 		=> "${caroot}/certs",
						"crl_dir" 		=> "${caroot}/crl",
						"database"		=> "${caroot}/index.txt",
						"new_certs_dir" => "${caroot}/certs",
						"certificate"	=> "${caroot}/certs/ca.crt",
						"serial"		=> "${caroot}/serial",
						"crl"			=> "${caroot}/crl/crl.pem",
						"private_key"	=> "${caroot}/private/ca.key",
						"RANDFILE"		=> "${caroot}/private/.rand",
						"default_days"	=> $issuelength,
						"default_crl_days" => "30",
						"default_md"	=> "sha1",
						"preserve"		=> "no",
						"policy"		=> "capolicy",
						"copy_extensions" => "copy", }


	$defaultpolicy = {
		"commonName" 			=> "supplied",
		"stateOrProvinceName"	=> "optional",
		"countryName" 			=> "optional",
		"emailAddress" 			=> "optional",
		"organizationName" 		=> "optional",
		"organizationalUnitName"=> "optional",
	}

	$config = merge($defaultconfig, { "puppetca" => merge($defaultcacfg, $caconfig) }, {'ca_dn' => $cadistinguisedname}, { "capolicy" => merge($defaultpolicy, $issuepolicy)})

	file { "${caroot}/ca.cnf":
		ensure => file,
		content => template("basicca/openssl.cnf.erb"),
		owner => "ca",
		group => "ca",
		mode => "0640",
		require => File[$caroot],
	}

	file { "${caroot}/certs":
		ensure => directory,
		owner => "ca",
		group => "ca",
		mode => "0750",
		recurse => true,
		require => File[$caroot],
	}

	file { "${caroot}/private":
		ensure => directory,
		owner => "ca",
		group => "ca",
		mode => "0700",
		recurse => true,
		require => File[$caroot],
	}

	file { "${caroot}/crl":
		ensure => directory,
		owner => "ca",
		group => "ca",
		mode => "0750",
		recurse => true,
		require => File[$caroot],
	}

	exec { "serial_set":
		command => "/bin/echo 01 > ${caroot}/serial",
		creates => "${caroot}/serial",
		require => File[$caroot],
	}

	file { "${caroot}/index.txt":
		ensure => present,
		owner  => "ca",
		group  => "ca",
		mode   => "0600",
		require => File[$caroot],
	}

	basicca::selfsignedcert { "cacert":
		keypath		=> "${caroot}/private/ca.key",
		csrpath		=> "${caroot}/private/ca.csr",
		certpath	=> "${caroot}/certs/ca.crt",
		owner		=> "ca",
		group 		=> "ca",
		config		=> "${caroot}/ca.cnf",
		keysize		=> $keysize,
		issuelength => $issuelength,
	}

}