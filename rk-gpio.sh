#! /bin/sh

in_gpio="${1^^}"
gpio_bank=0
gpio_group=0
gpio_pin=0

_chr2int() {
	LC_CTYPE=C printf '%d' "'$1"
}

chk_input() {
	local tmp=${in_gpio#GPIO}
	local bank="${tmp%_*}"
	local tmp=${tmp#*_}
	local group=${tmp:0:1}
	local group_num=0
	local pin=${tmp:1}

	case "$bank" in
		0|1|2|3|4)
			#echo "GPIO bank: $bank"
			gpio_bank=$bank
			;;
		*)
			echo "ERROR> unknown GPIO bank: $bank"
			exit 1 ;;
	esac

	case "$group" in
		A|B|C|D)
			group_num=`_chr2int "$group"`
			group_num=$((group_num-65))
			#echo "GPIO group: $group/$group_num"
			gpio_group=$group_num
			;;
		*)
			echo "ERROR> unknown GPIO group: $group"
			exit 1 ;;
	esac

	case "$pin" in
		0|1|2|3|4|5|6|7)
			#echo "GPIO pin: $pin"
			gpio_pin=$pin
			;;
		*)
			echo "ERROR> unknown GPIO pin: $pin"
			exit 1 ;;
	esac
}

get_sys_pin_num() {
	echo $(($gpio_bank*32+$gpio_group*8+$gpio_pin))
}

do_main() {
	chk_input
	get_sys_pin_num
}

do_main
