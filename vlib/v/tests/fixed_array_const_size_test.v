const (
	size = 5
)

struct Foo {
	bar [5]byte
}

fn test_fixed_array_const_size() {
	a := Foo{}
	println(a)
	assert a == Foo{
		bar: [byte(0), 0, 0, 0, 0]!
	}
}
