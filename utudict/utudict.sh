#!/bin/bash
# Generate dictionary11.txt from UT Dictionary (http://linuxplayers.g1.xrea.com/mozc-ut.html)
# utudict = UT unified dictionary

set -e +f
declare _BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")"; pwd)"
cd "${_BASE_DIR}"

function main() {
	declare -r _MOZC_UTU_VERSION="20210123.1"
	declare -r _MOZC_UTU_DIR_NAME="mozcdic-ut-${_MOZC_UTU_VERSION}"
	declare -r _MOZC_UTU_ARCHIVE_FILE_NAME="${_MOZC_UTU_DIR_NAME}.tar.bz2"
	declare -r _MOZC_UTU_URL="https://osdn.net/users/utuhiro/pf/utuhiro/dl/${_MOZC_UTU_ARCHIVE_FILE_NAME}"
	declare -r _MOZC_UTU_PATCH_FILE="${_BASE_DIR}/patches/patch-${_MOZC_UTU_VERSION}.diff"

	rm -rf "${_MOZC_UTU_DIR_NAME}"
	wget -nc "${_MOZC_UTU_URL}"
	tar xf "${_MOZC_UTU_ARCHIVE_FILE_NAME}"
	cd "${_MOZC_UTU_DIR_NAME}"
	[ -f "${_MOZC_UTU_PATCH_FILE}" ] && patch -Np1 < "${_MOZC_UTU_PATCH_FILE}"
	ln -s ../../.. mozc/mozc
	cd src
	chmod +x make-dictionaries.sh
	./make-dictionaries.sh
	cd ..
	cat mozcdic-*-"${_MOZC_UTU_VERSION}".txt > "${_BASE_DIR}/../src/data/dictionary_oss/dictionary11.txt"
}

main
declare _EXIT_CODE="${?}"
[ ! "x${_EXIT_CODE}X" = "x0X" ] && exit "${_EXIT_CODE}"
unset _BASE_DIR _EXIT_CODE
