#! /bin/sh

in_gpio="${1^^}"
gpio_bank=0
gpio_group=0
gpio_pin=0

_chr2int() {
	LC_CTYPE=C printf '%d' "'$1"
}

show_usage() {
	local cmd=`basename $0`
	cat << EOF

Usage:
      $cmd <GPIO[bank]_[group][pin]>
      $cmd <pinnumber>

<GPIO[bank]_[group][pin]>
   bank:  0-4
   group: A-D
   pin:   0-7

<pinnumber>: 0-159

   ex: $cmd GPIO4_A3
       $cmd 131

EOF
}

gpio_to_sys_pin_num() {
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

	echo "$in_gpio => $(($gpio_bank*32+$gpio_group*8+$gpio_pin))"
}

sys_pin_num_to_gpio() {
	local bank=
	local group=
	local pin=
	local group_num=

	bank=$((${in_gpio}/32))
	group_num=$((${in_gpio}-${bank}*32))
	group=`echo $((${group_num}/8)) | tr "0123" "ABCD"`
	pin=$((${group_num}%8))

	echo "GPIO${bank}_${group}${pin} <= ${in_gpio}"
}

do_main() {
	if [ "$in_gpio" = "" ]; then
		show_usage
		exit 0
	fi
	if [[ "$in_gpio" =~ ^GPIO[0-4]_[A-D][0-7]$ ]]; then
		gpio_to_sys_pin_num
	else
		if [[ "$in_gpio" =~ ^[0-9]+$ ]]; then
			if [ "$in_gpio" -ge 0 -a "$in_gpio" -le 159 ]; then
				sys_pin_num_to_gpio
			else
				show_usage; exit 1
			fi
		else
			show_usage; exit 1
		fi
	fi
}

do_main
