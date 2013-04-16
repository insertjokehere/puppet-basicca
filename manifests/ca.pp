define basicca::ca($caroot, $ca_dn_commonName, $ca_dn_stateOrProvinceName, $ca_dn_countryName, $ca_dn_emailAddress, $ca_dn_organizationName, $issuelength=365, $keysize=2048) {

	user { "ca":
		home => "${caroot}",
		ensure => present,
		shell => "/bin/false",
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

	file { "${caroot}/ca.cnf":
		ensure => file,
		content => template("basicca/ca.cnf.erb"),
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

	basicca::privatekey { "caKey":
		numbits=>$keysize,
		owner=>"ca",
		group=>"ca",
		mode=>"0600",
		saveto=>"${caroot}/private/ca.key",
		require => File["${caroot}/private"],
	}

	basicca::csr { "caCsr":
		key => "${caroot}/private/ca.key", 
		saveto => "${caroot}/private/ca.csr", 
		owner => "ca", 
		group => "ca",
		config => "${caroot}/ca.cnf",
		require => Basicca::Privatekey["caKey"],
	}

	basicca::signcert { "caCrt":
		signkey => "${caroot}/private/ca.key",
		csr     => "${caroot}/private/ca.csr",
		saveto  => "${caroot}/certs/ca.crt",
		days    => $issuelength,
		owner   => "ca",
		group   => "ca",
		mode    => "0644",
		require => Basicca::Csr["caCsr"],
	}

	Ssh_authorized_key <<| 	user == "ca",
							tag  == "ca-${fqdn}" |>>

}