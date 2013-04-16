define basicca::caadmin($ca=$name, $keyfile="/root/.ssh/ca.ssh", $pubkeyfile="/root/.ssh/ca.pub") {

	@@ssh_authorized_key {
		ensure => present,
		key    => file($pubkeyfile),
		name   => "ca-key-${fqdn}"
		user   => "ca",
		tag    => "ca-${ca}",
	}

	exec { "ssh-private-${fqdn}":
		command => "/usr/bin/ssh-keygen -b 2048 -t rsa -f ${keyfile}",
		creates => $keyfile,
	}

	exec { "ssh-public-${fqdn}":
		command => "/usr/bin/ssh-keygen -y -f ${keyfile} > ${pubkeyfile}"
		creates => $pubkeyfile,
		require => Exec["ssh-private-${fqdn}"],
	}

}