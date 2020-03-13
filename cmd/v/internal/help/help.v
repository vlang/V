module help

import (
	os
	v.pref
)

const (
	unknown_topic = 'V Error: Unknown help topic provided. Use `v help` for usage information.'
)

pub fn print_and_exit(topic string) {
	vexe := pref.vexe_path()
	vroot := os.dir(vexe)

	for b in topic {
		if (b >= `a` && b <= `z`) || b == `-` {
			continue
		}
		println(unknown_topic)
		exit(1)
	}
	target_topic := os.join_path(vroot, 'cmd', 'v', 'internal', 'help', '${topic}.txt')
	content := os.read_file(target_topic) or {
		println(unknown_topic)
		exit(1)
	}
	println(content)
	exit(0)
}
