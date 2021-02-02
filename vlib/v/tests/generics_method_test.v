struct Point {
mut:
	x int
	y int
}

fn (mut p Point) translate<T>(x T, y T) {
	p.x += x
	p.y += y
}

fn test_generic_method() {
	mut pot := Point{}
	pot.translate<int>(1, 3)
	pot.translate(1, 3)
	println(pot)
	assert pot == Point{
		x: 2
		y: 6
	}
}

struct Person {
mut:
	name string
}

fn (mut p Person) show<T>(name string, data T) string {
	p.name = name
	return 'name: $p.name, data: $data'
}

fn test_generic_method_with_fixed_arg_type() {
	mut person := Person{}
	res := person.show('bob', 10)
	assert res == 'name: bob, data: 10'
}

struct Foo {}

fn (v Foo) new<T>() T {
	return T{}
}

fn test_generic_method_with_map_type() {
	foo := Foo{}
	assert foo.new<map[string]string>() == map[string]string{}
}

fn test_generic_method_with_array_type() {
	foo := Foo{}
	assert foo.new<[]string>() == []string{}
}

fn test_generic_init() {
	foo := Foo{}
	// array init
	mut a := foo.new<[]string>()
	assert a.len == 0
	a << 'a'
	assert a.len == 1
	assert a[0] == 'a'
	// map init
	mut b := foo.new<map[string]string>()
	assert b.len == 0
	b['b'] = 'b'
	assert b.len == 1
	assert b['b'] == 'b'
	// struct init
	mut c := foo.new<Person>()
	c.name = 'c'
	assert c.name == 'c'
}
