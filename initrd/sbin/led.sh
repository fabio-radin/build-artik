#!/bin/sh

ARTIK5=`cat /proc/cpuinfo | grep -i EXYNOS3`

if [ "$ARTIK5" != "" ]; then
	# ARTIK-5
	FORWARD_GPIO="12 13 121 122 123 32 33 124 125 126 127 129 134 135 34 35"
	REVERSE_GPIO="35 34 135 134 129 127 126 125 124 33 32 123 122 121 13 12"
else
	FORWARD_GPIO="175 176 8 9 10 203 204 11 12 13 14 16 21 22"
	REVERSE_GPIO="22 21 16 14 13 12 11 204 203 10 9 8 176 175"
fi

FLOW=${FORWARD_GPIO}

gpio_out()
{
	echo $1 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$1/direction
	echo $2 > /sys/class/gpio/gpio$1/value
	echo $1 > /sys/class/gpio/unexport
}

led_on_off()
{
	for gn in ${FORWARD_GPIO}
	do
		gpio_out $gn $1
	done
}

led_on()
{
	led_on_off 1
}

led_off()
{
	led_on_off 0
}

led_loop()
{
	if [ $1 == "1" ] ; then
		flow=${FORWARD_GPIO}
	else
		flow=${REVERSE_GPIO}
	fi

	for n in ${flow}
	do
		led_off
		gpio_out $n 1
		sleep 0.5
	done
}

led_start()
{
	while true
	do
		led_loop 1
		led_loop 0
	done
}

led_end()
{
	while true
	do
		led_on
		sleep 1
		led_off
		sleep 1
	done
}

case "$1" in

	start)
		led_start
		;;
	restart|reload|force-reload)
		echo "Error: argument '$1' not supported" >&2
		exit 3
		;;
	end)
		led_end
		;;
	*)
		echo "Usage: $0 start|stop" >&2
		exit 3
		;;
esac
