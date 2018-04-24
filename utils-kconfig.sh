#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

# This function is also available in Linux kernel code as scripts/config
kconfig_set_option() {
	local opt="$1"
	local val="$2"
	local dotc="${3:-.config}"
	local repl

	# whether $opt is present in $dotc
	if grep -q '^\(\# *\)\?\<'"$opt"'\>.*' "$dotc"; then
		if [ -z "$val" -o "$val" = "n" ]; then
			repl="# $opt is not set"
		else
			# Some sh doesn't support ${var/pattern/repl}
			repl="$opt=$(echo $val | sed 's/:/\:/g')"
		fi
		sed -i'' -e 's:^\(\# *\)\?\<'"$opt"'\>.*:'"$repl"':' "$dotc"
	else
		if [ -z "$val" -o "$val" = "n" ]; then
			repl="# $opt is not set"
		else
			repl="$opt=$val"
		fi
		echo "$repl" >>"$dotc"
	fi
}

kconfig_set_m_y() {
	local dotc="${1:-.config}"

	sed -i -e 's:^\(CONFIG_[^=]\+\)=m:\1=y:' "$dotc"
}

kconfig_set_m_n() {
	local dotc="${1:-.config}"

	sed -i -e 's:^\(CONFIG_[^=]\+\)=m:# \1 is not set:' "$dotc"
}
