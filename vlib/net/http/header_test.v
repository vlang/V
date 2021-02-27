import net.http

fn test_header_new() {
	h := http.new_header(
		{key: .accept, value: 'nothing'},
		{key: .expires, value: 'yesterday'}
	)
	assert h.contains_str('accept')
	assert h.contains(.expires)
	accept := h.get(.accept) or { '' }
	expires := h.get(.expires) or { '' }
	assert accept == 'nothing'
	assert expires == 'yesterday'
}

fn test_header_invalid_key() {
	mut h := http.new_header()
	h.add_str('space is invalid', ':(') or { return }
	panic('should have returned')
}

fn test_header_adds_multiple() {
	mut h := http.new_header()
	h.add(.accept, 'one')
	h.add(.accept, 'two')

	assert h.values(.accept) == ['one' 'two']
}

fn test_header_set() {
	mut h := http.new_header(
		{key: .to, value: 'one'},
		{key: .to, value: 'two'}
	)
	assert h.values(.to) == ['one' 'two']
	h.set_str('to', 'three')
	assert h.values(.to) == ['three']
}

fn test_header_delete() {
	mut h := http.new_header(
		{key: .to, value: 'one'},
		{key: .to, value: 'two'}
	)
	assert h.values(.to) == ['one' 'two']
	h.delete_str('to')
	assert h.values(.to) == []
}
