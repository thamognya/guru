# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 perl-module

DESCRIPTION="User space software for Intel(R) Resource Director Technology"
HOMEPAGE="
	http://www.intel.com/content/www/us/en/architecture-and-technology/resource-director-technology.html
	https://github.com/intel/intel-cmt-cat
"
SRC_URI="https://github.com/intel/intel-cmt-cat/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="perl"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/jsonschema[${PYTHON_USEDEP}]

	perl? ( dev-lang/perl:= )
"
DEPEND="
	${RDEPEND}
	test? ( dev-python/mock[${PYTHON_USEDEP}] )
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
PATCHES=( "${FILESDIR}/${PN}-perl-makefile.patch" )

distutils_enable_tests unittest
distutils_enable_tests pytest

#TODO: install appqos

src_prepare() {
	mkdir -p "${T}/prefix" || die

	distutils-r1_python_prepare_all
}

src_compile() {
	emake all PREFIX="${T}/prefix"

	if use perl; then
		pushd "lib/perl" || die
		perl-module_src_configure
		perl-module_src_compile
		popd || die
	fi
	pushd "lib/python" || die
	python_foreach_impl distutils-r1_python_compile
	popd || die
}

src_install() {
	emake install PREFIX="${T}/prefix"

	dobin "${T}"/prefix/bin/*
	doheader "${T}"/prefix/include/*
	doman "${T}"/prefix/man/man*/*
	dolib.so "${T}"/prefix/lib/*

	dobin tools/membw/membw
	dobin snmp/rdt-agentx.pl

	dodoc ChangeLog README
	docinto membw
	dodoc tools/membw/README
	docinto pqos
	dodoc -r pqos/README pqos/configs
	docinto lib
	dodoc lib/README
	docinto lib/python
	dodoc lib/python/README.txt
	docinto snmp
	dodoc snmp/README
	docinto rdtset
	dodoc rdtset/README
	docinto appqos
	dodoc appqos/README.md

	unset DOCS
	python_foreach_impl python_install

	if use perl ; then
		pushd "lib/perl" || die
		unset DOCS
		myinst=( DESTDIR="${D}" )
		perl-module_src_install
		popd || die
		docinto lib/perl
		dodoc lib/perl/README
	fi
}

src_test() {
	python_foreach_impl python_test
}

python_install() {
	pushd "lib/python" || die
	distutils-r1_python_install
	popd || die

#	python_domodule appqos
}

python_test() {
	pushd "lib/python" || die
	eunittest
	popd || die

#	pushd "appqos" || die
#	epytest -vv tests
#	popd || die
}