// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module scanner

import (
	v.token
)

fn test_scan() {
	text := 'println(2 + 3)'
	mut scanner := new_scanner(text)
	mut token_kinds := []token.Kind
	for {
		tok := scanner.scan()
		if tok.kind == .eof {
			break
		}
		token_kinds << tok.kind
	}
	assert token_kinds.len == 6
	assert token_kinds[0] == .name
	assert token_kinds[1] == .lpar
	assert token_kinds[2] == .number
	assert token_kinds[3] == .plus
	assert token_kinds[4] == .number
	assert token_kinds[5] == .rpar

	// test number costants input format
	mut c := 0xa_0
	assert c == 0xa0
	c = 0b10_01
	assert c == 9
	c = 1_000_000
	assert c == 1000000
	d := f64(23_000_000e-3)
	assert int(d) == 23000 
}

