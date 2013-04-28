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

### Creating a simple certificate authority

This is slightly more involved, and is far from 'hands off'. Any suggestions as to making this more automated are welcome. For the purposes of this example, assume I have two servers; `ca.example.com` will act as the certificate authority, and will be responsible for signing certificates, and `www.example.com` that needs a SSL certificate signed by `ca.example.com`

#### Setting up the CA

	import "basicca"

	node "ca.example.com" {

		basicca::ca { "exampleCA":
			caroot => "/var/ca",
			ca_dn_commonName => "example Root Authority",
			ca_dn_stateOrProvinceName => "Canterbury",
			ca_dn_countryName => "NZ",
			ca_dn_emailAddress => "admin@example.com",
			ca_dn_organizationName => "example",
			issuelength => 3650,
		}

		ssh_authorized_key { "ca-admin":
			ensure 	=> present,
			key 	=> "AAAA...",
			user 	=> "ca",
			type	=> "rsa",
		}

	}

The ssh key will be needed later to sign certificate requests

#### Producing certificate requests

	import "basicca"

	node "www.example.com" {

		basicca::certrequest{ $fqdn:
	  		keypath => "/etc/apache2/${fqdn}.key",
	  		csrpath => "/etc/apache2/${fqdn}.csr",
	  		subject => { 	"CN" => $fqdn,
	  						"C"  => "NZ",
	  					},
	  	}

	}

#### Signing the request

On `www.example.com`, use scp to transfer the csr to `ca.example.com`:

	sudo -E scp www.example.com.csr ca@ca.example.com:/var/ca/

Then on `ca.example.com` as the ca user:

	openssl ca -in www.example.com.csr -config ca.cnf

openSSL will prompt you to confirm that you want to sign the request, then print details of the request. Take note of the serial number, as this is the file name of the signed certificate.

Back on `www.example.com`, pull the signed certificate back (assuming the serial number was '01'):

	sudo -E scp ca@ca.example.com:~/certs/01.pem www.example.com.crt

This certificate can now be used. Clients will need to retrieve a copy of the CA certificate (in the above example, it is stored in `/var/ca/certs/ca.crt`) and install it as a trusted root certificate

More details of the `openssl ca` command can be found at `ca(1)`

### Creating a multinamed certificate

SSLv3 supports certificates with multiple common names, using the `subjectAltName` extension. Producing a certificate request with this extension is slightly more complex then a standard request, as the extensions must be specified in a configuration file. For example, say that `www.example.com` also needs to be able to serve SSL requests for `example.com` and `img.example.com`. This could be achieved by issuing a certificate for `*.example.com`, but a better aproach would be:

	import "basicca"

	basicca::config { "/etc/apache2/www.example.com.cnf":
		config => { "req" => {	"distinguished_name" => "dn",
  								"default_md" => "sha1", 
  								"prompt" => "no",
  								"req_extensions" => "v3_req" }, 
  								"v3_req" => { 	"subjectAltName" => "DNS:www.example.com,DNS:example.com,DNS:img.example.com",
  												"basicConstraints" => "CA:false" },
  								"dn" => { 	"CN" => "www.example.com",
  											"C" => "NZ" } }
  		}

  	basicca::certrequest{ $fqdn:
		keypath => "/etc/apache2/${fqdn}.key",
		csrpath => "/etc/apache2/${fqdn}.csr",
		config  => "/etc/apache2/www.example.com.cnf",
		require => Basicca::Config["/etc/apache2/www.example.com.cnf"],
  	}


## TODO

 * Automate signing of certificates by the CA
 * Provide a means of installing the CA certificate on clients
 * Produce certificate revocation lists (crl's)

## Glossary

 * csr - Certificate Signing Request
 * ca - Certificate Authority
