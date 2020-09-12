#!/bin/bash
set -e +f
declare _BASE_DIR="$(cd "$(dirname "${0}")"; pwd)"
cd "${_BASE_DIR}"

function main() {
	declare -r _MOZC_UTU_VERSION="20200821.1"
	declare -r _MOZC_UTU_DIR_NAME="mozcdic-ut-${_MOZC_UTU_VERSION}"
	declare -r _MOZC_UTU_ARCHIVE_FILE_NAME="${_MOZC_UTU_DIR_NAME}.tar.bz2"
	declare -r _MOZC_UTU_URL="https://osdn.dl.osdn.jp/users/26/26575/${_MOZC_UTU_ARCHIVE_FILE_NAME}"
	rm -r "${_MOZC_UTU_DIR_NAME}"
	wget -nc "${_MOZC_UTU_URL}"
	tar xf "${_MOZC_UTU_ARCHIVE_FILE_NAME}"
	cd "${_MOZC_UTU_DIR_NAME}"
	patch -Np1 < "${_BASE_DIR}/patch/patch-1.patch"
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
