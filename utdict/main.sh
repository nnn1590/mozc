#!/bin/bash
# License of this script: CC0 NNN1590
# Generate dictionary11.txt from UT Dictionary (http://linuxplayers.g1.xrea.com/mozc-ut.html)
# utdict = UT Dictionary
# You may need Parallel(Ruby library). To install it, run: "(sudo) gem install parallel"

set -e +f
declare _BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")"; pwd)"
cd "${_BASE_DIR}"

function main() {
	declare -r _MOZC_UT_VERSION="20210603"
	declare -r _MOZC_UT_DIR_NAME="mozcdic-ut-${_MOZC_UT_VERSION}"
	declare -r _MOZC_UT_ARCHIVE_FILE_NAME="${_MOZC_UT_DIR_NAME}.tar.bz2"
	declare -r _MOZC_UT_URL="https://osdn.net/users/utuhiro/pf/utuhiro/dl/${_MOZC_UT_ARCHIVE_FILE_NAME}"
	declare -r _MOZC_UT_PATCH_FILE="${_BASE_DIR}/patches/patch-${_MOZC_UT_VERSION}.diff"

	rm -rf "${_MOZC_UT_DIR_NAME}"
	wget -nc "${_MOZC_UT_URL}"
	tar xf "${_MOZC_UT_ARCHIVE_FILE_NAME}"
	cd "${_MOZC_UT_DIR_NAME}"
	[ -f "${_MOZC_UT_PATCH_FILE}" ] && patch -Np1 < "${_MOZC_UT_PATCH_FILE}"
	ln -s ../../.. mozc/mozc
	cd src
	setting_dictionary
	chmod +x make-dictionaries.sh
	./make-dictionaries.sh
	cd ..
	cat mozcdic-*-"${_MOZC_UT_VERSION}".txt > "${_BASE_DIR}/../src/data/dictionary_oss/dictionary11.txt"
}

function index_of() {
	[ "0${#}" -gt 2 ] && { echo ":: [ERROR] index_of: Too many arguments (${#}). This function must have 2 arguments" >&2; return 1; }
	[ "0${#}" -lt 2 ] && { echo ":: [ERROR] index_of: Too few arguments (${#}). This function must have 2 arguments" >&2; return 1; }
	local IFS=' '
	local -n array="${2}"
	for i in ${!array[*]}; do
		[[ "${array[${i}]}" == "${1}" ]] && { echo -n "${i}"; return 0; }
	done
	echo -n "-1"
	return 0
}

function setting_dictionary() {
	declare -r _CONFIG_FILE_NAME="utdict-config"
	declare -a _config_name=()
	declare -a _config_value=()
	declare -a _default_name=()
	declare -a _default_value=()
	declare i=""
	declare _tmp_name=""
	declare _tmp_index=""
	declare _tmp_value=""
	declare IFS_BACKUP="${IFS}"

	IFS=$'\n'
	for i in $(grep -E '^#?.+="true"$' make-dictionaries.sh); do
		_default_name+=("$(echo "${i}" | grep -Po '^(.+?=)' | sed -ze 's/^#//g; s/\n//g; s/=$//g')")
		if [[ "${i}" == "#"* ]]; then
			_default_value+=('false')
		else
			_default_value+=('true')
		fi
	done
	for i in $(grep -P '^(?!::)#?.+=.*$' "${_BASE_DIR}/${_CONFIG_FILE_NAME}"); do
		_tmp_name="$(echo "${i}" | grep -Po '^(.+?=)' | sed -ze 's/^#//g; s/\n//g; s/=$//g')"
		_tmp_index="$(index_of "${_tmp_name}" _config_name)"
		_tmp_value=""
		if ! [[ "${i}" == "#"* ]] && [[ "${i,,}" =~ .+'='.?(t(rue)?|1|y(es)?|enable).?$ ]]; then
			_tmp_value='true'
		elif ! [[ "${i}" == "#"* ]] && [[ "${i,,}" =~ .+'='.?(k(eep)?|2|same|c(opy)?|default).?$ ]]; then
			if [[ "$(index_of "${_tmp_name}" _default_name)" == "-1" ]]; then
				echo ":: [ERROR] There is no default value for '${_tmp_name}'" >&2
				return 1
			else
				_tmp_value="${_default_value["$(index_of "${_tmp_name}" _default_name)"]}"
			fi
		else
			_tmp_value='false'
		fi
		if [[ "${_tmp_index}" == "-1" ]]; then
			_config_name+=("${_tmp_name}")
			_config_value+=("${_tmp_value}")
		else
			_config_value["${_tmp_index}"]="${_tmp_value}"
		fi
	done
	IFS=" "
	declare _build=""
	declare _build_name=("${_default_name[@]}")
	declare _build_value=("${_default_value[@]}")
	declare _build_default_value="keep"
	for i in $(grep -P '^::complementwith=.*$' "${_BASE_DIR}/${_CONFIG_FILE_NAME}"); do
		if ! [[ "${i}" == "#"* ]] && [[ "${i,,}" =~ .+'='.?(t(rue)?|1|y(es)?|enable).?$ ]]; then
			_build_default_value='true'
		elif ! [[ "${i}" == "#"* ]] && [[ "${i,,}" =~ .+'='.?(f(alse)?|0|n(o)?|disable).?$ ]]; then
			_build_default_value='false'
		fi
	done
	[[ "${_build_default_value}" =~ (true|false) ]] && for i in ${!_build_value[*]}; do
		_build_value[${i}]="${_build_default_value}"
	done
	for i in ${!_config_name[*]}; do
		_tmp_index="$(index_of "${_config_name[${i}]}" _default_name)"
		if [[ "${_tmp_index}" == "-1" ]]; then
			_build_name+=("${_config_name[${i}]}")
			_build_value+=("${_config_value[${i}]}")
		else
			_build_value["${_tmp_index}"]="${_config_value[${i}]}"
		fi
	done
	for i in ${!_build_value[*]}; do
		_build+="${_build_name[$i]}=\"${_build_value[$i]}\"  # configured"'\n'
	done
	IFS="${IFS_BACKUP}"
	_build="${_build//\//\\\/}"
	_build="${_build%\\n}"
	sed -Ee '0,/^#?.+="true"$/s//'"${_build}"'/' make-dictionaries.sh > make-dictionaries.sh.tmp
	sed -i -Ee '/^#?.+="true"$/d' make-dictionaries.sh.tmp
	mv make-dictionaries.sh{.tmp,}
}

main ${@}
declare _EXIT_CODE="${?}"
[ ! "x${_EXIT_CODE}X" = "x0X" ] && exit "${_EXIT_CODE}"
unset _BASE_DIR _EXIT_CODE
