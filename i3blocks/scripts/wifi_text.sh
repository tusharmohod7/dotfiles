if [[ -z "$INTERFACE" ]] ; then
    INTERFACE="${BLOCK_INSTANCE:-wlp2s0}"
fi

if [ ! -d /sys/class/net/${INTERFACE}/wireless ] 
then
	exit
fi

if [ "$(cat /sys/class/net/$INTERFACE/operstate)" == 'down' ]
then
    echo "NO WIFI"
    exit
fi

SSID=$(iw "$INTERFACE" info | awk '/ssid/ {print $2}' | tr '[a-z]' '[A-Z]')

QUALITY=$(grep $INTERFACE /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')

echo WIFI $SSID [$QUALITY]
