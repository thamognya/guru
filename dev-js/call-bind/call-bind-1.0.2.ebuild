# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit node

DESCRIPTION="Robustly .call.bind() a function"
HOMEPAGE="
	https://github.com/ljharb/call-bind
	https://www.npmjs.com/package/call-bind
"

LICENSE="MIT"
KEYWORDS="~amd64"
RDEPEND="
	${NODEJS_RDEPEND}
	dev-js/function-bind
	dev-js/get-intrinsic
"