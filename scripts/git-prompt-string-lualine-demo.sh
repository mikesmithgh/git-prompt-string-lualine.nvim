#!/usr/bin/env bash

# Utility script to execute demo steps via Kitty

# recorded and exported with Screen Studio
# gif generated with
# ffmpeg -i git-prompt-string-lualine.mp4 -r 4 frame%04d.png
# gifski --quality 100 --motion-quality 100 --lossy-quality 100 -o git-prompt-string-lualine.gif frame*.png

win="$1" # kitty window ID
char_delay='0.2'
feed_delay='2.5'

if [[ -z "$win" ]]; then
	printf "Please povide kitty window ID"
	exit 1
fi

function kitty_send_text() {
	kitty @ send-text "--match=id:$win" "$@"
}

function feed_no_newline() {
	str=""
	for word in "$@"; do
		str="$str $word"
	done
	str="${str:1}" # trim leading space
	for ((i = 0; i < ${#str}; i++)); do
		char="${str:i:1}"
		kitty_send_text "$char"
		sleep "$char_delay"
	done
}

function feed() {
	feed_no_newline "$@"
	feed_str '\n'
	sleep "$feed_delay"
}

function feed_str() {
	str="$1"
	kitty_send_text "$str"
	sleep "$char_delay"
}

feed clear
feed nvim README.md
feed :Git reset --hard 7e47962
feed_no_newline 16G
feed_no_newline O
feed_str '# TODO: add demo'
feed_str '\x1b'
feed :w
feed :Git commit -a
feed_no_newline i
feed_str 'chore: add TODO message'
feed_str '\x1b'
feed :wq
feed_no_newline '  t'
sleep "$feed_delay"
feed git merge
feed 'git checkout --theirs README.md && git add .'
feed 'git reset --hard @{u}'
feed_str '\x1b'
feed ':qa!'
feed clear
