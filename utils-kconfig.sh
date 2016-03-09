#
# Copyright 2015-2016 (c) Yousong Zhou
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
set_option() {
	local opt="$1"
	local val="$2"
	local dotc="${3:-.config}"
	local repl

	if [ -z "$val" -o "$val" = "n" ]; then
		repl="# $opt is not set"
	else
		# Some sh doesn't support ${var/pattern/repl}
		repl="$opt=$(echo $val | sed 's/:/\:/g')"
	fi
	sed -i'' -e 's:^\(\# *\)\?\<'"$opt"'\>.*:'"$repl"':' "$dotc"
}
