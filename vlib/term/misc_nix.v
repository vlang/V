module term

import os

#include <sys/ioctl.h>

pub struct C.winsize {
pub:
	ws_row u16
	ws_col u16
  ws_xpixel u16
  ws_ypixel u16
}

fn C.ioctl(fd int, request u64, arg voidptr) int

pub fn get_terminal_size() (int, int) {
	w := C.winsize{}
	C.ioctl(0, C.TIOCGWINSZ, &w)
  eprintln('ws_row: $w.ws_row | ws_col: $w.ws_col | ws_xpixel: $w.ws_xpixel | ws_ypixel: $w.ws_ypixel')
  if cols := os.exec('tput cols') {
     eprintln('tput cols: $cols.output')
  }
  if lines := os.exec('tput lines') {
     eprintln('tput lines: $lines.output')
  }
  if stty := os.exec('stty -a') {
     eprintln('stty: $stty.output')
  }
	return int(w.ws_col), int(w.ws_row)
}
