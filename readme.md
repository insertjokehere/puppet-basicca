# BasicCA Puppet Module

## Overview

The purpose of this module is to simplify deploying SSL certificates to nodes, setting up a simple certificate authority for testing purposes, producing self-signed certificates, certificate requests and other related tasks.
Although this module has been tested to the best of my ability, I strongly advise against using it in a production environment. This module has only been tested on Debian Wheezy, patches to support other environments are welcome.

## Licence

This code is licensed under the BSD 3-clause licence unless noted otherwise. The text of this licence is available in the 'LICENCE' file

## Installation

This module requires the [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) module.

Once stdlib is installed, install basicca

	git clone git://github.com/insertjokehere/puppet-basicca.git modules/basicca

## Basic Usage

### Creating a self-signed certificate

	import "basicca"

	node "www.example.com" {
		basicca::selfsignedcert { "wwwcert":
			keypath		=> "/etc/apache2/server.key",
			csrpath		=> "/etc/apache2/server.csr",
			certpath	=> "/etc/apache2/server.crt",
			keysize		=> 2048,
			issuelength => 365,
			subject		=> { "CA" => $fqdn,
							 "C"  => "NZ",
							}
		}
	}

The subject can be specified as a hash (as above) or as a string (ie `/CA=www.example.com/C=NZ`), and the certificate will be valid for the number of days specified. Note that the certificate will not be reissued once it expires.
By default, all produced files are owned by root, the csr and key files are set to have mode 0600 (`rw-------`), and the certificate is set to mode 0644 (`rw-r--r--`)