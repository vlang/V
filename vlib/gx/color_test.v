import gx

fn test_hex() {
	// valid colors
	a := gx.hex(0x6c5ce7ff)
	b := gx.rgba(108, 92, 231, 255)
	assert a.eq(b)
	// doesn't give right value with short hex value
	short := gx.hex(0xfff)
	assert !short.eq(gx.white)
}

fn test_add() {
	a := gx.rgba(100, 100, 100, 100)
	b := gx.rgba(100, 100, 100, 100)
	r := gx.rgba(200, 200, 200, 200)
	assert (a + b).eq(r)
}

fn test_sub() {
	a := gx.rgba(100, 100, 100, 100)
	b := gx.rgba(100, 100, 100, 100)
	r := gx.rgba(0, 0, 0, 0)
	assert (a - b).eq(r)
}

fn test_mult() {
	a := gx.rgba(10, 10, 10, 10)
	b := gx.rgba(10, 10, 10, 10)
	r := gx.rgba(100, 100, 100, 100)
	assert (a * b).eq(r)
}

fn test_div() {
	a := gx.rgba(100, 100, 100, 100)
	b := gx.rgba(10, 10, 10, 10)
	r := gx.rgba(10, 10, 10, 10)
	assert (a / b).eq(r)
}

fn test_rgba() {
	assert gx.white.rgba() == -1
	assert gx.black.rgba() == 255
	assert gx.red.rgba() == -16776961
	assert gx.green.rgba() == 16711935
	assert gx.blue.rgba() == 65535
}

fn test_abgr() {
	assert gx.white.abgr() == -1
	assert gx.black.abgr() == -16777216
	assert gx.red.abgr() == -16776961
	assert gx.green.abgr() == -16711936
	assert gx.blue.abgr() == -65536
}
