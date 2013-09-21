#!/bin/bash
# Install fake erlang packages, then the ESL package
# Afterwards, installing packages that depend on erlang, like rabbitmq,
# will use the ESL packaged erlang without installing the older disto ones
#
apt-get install equivs
# Create fake erlang packages, since we are using esl-erlang instead
cd /tmp
apt-get install -y equivs

function make_dummy_package {
echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: $1
Version: 1:99
Maintainer: RJ <rj@metabrew.com>
Provides: erlang-nox
Description: fake erlang package 
 pretends $1 is installed" > $1

equivs-build $1
}

erlpkgs="erlang-abi-13.a erlang-appmon erlang-asn1 erlang-base erlang-base-hipe erlang-common-test erlang-corba erlang-crypto erlang-debugger erlang-dev erlang-dialyzer erlang-doc erlang-doc-html erlang-docbuilder erlang-edoc erlang-erl-docgen erlang-esdl erlang-esdl-dev erlang-esdl-doc erlang-et erlang-eunit erlang-examples erlang-gs erlang-ic erlang-ic-java erlang-inets erlang-inviso erlang-jinterface erlang-manpages erlang-megaco erlang-mnesia erlang-nox erlang-observer erlang-odbc erlang-os-mon erlang-parsetools erlang-percept erlang-pman erlang-public-key erlang-reltool erlang-runtime-tools erlang-snmp erlang-src erlang-ssh erlang-ssl erlang-syntax-tools erlang-test-server erlang-toolbar erlang-tools erlang-tv erlang-typer erlang-webtool erlang-wx erlang-x11 erlang-xmerl erlang-yaws"
## Argh, can't just make them all, esl-erlang Conflicts: with them.
for debian_package in erlang-nox
do
    make_dummy_package $debian_package
done

dpkg -i ./*.deb

# ESL Erlang
echo "deb http://binaries.erlang-solutions.com/debian quantal contrib" | tee /etc/apt/sources.list.d/erlang-esl.list
wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add -
# The public key they provide doesn't match, hence the unauth flag:
apt-get update
apt-get install esl-erlang=1:15.b.3-1~ubuntu~quantal

# Now stuff like this works without pulling in distro-erlang:
echo "deb http://www.rabbitmq.com/debian/ testing main" | tee /etc/apt/sources.list.d/rabbitmq-server.list
wget -O -  http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add -
echo "rabbitmq-server rabbitmq-server/upgrade_previous note" | debconf-set-selections
apt-get install rabbitmq-server
