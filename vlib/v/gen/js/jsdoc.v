module js

import (
	strings
	v.ast
)

struct JsDoc {
	gen &JsGen
	mut:
	out strings.Builder
	empty_line bool
}

fn new_jsdoc(gen &JsGen) &JsDoc {
	return &JsDoc {
		out: strings.new_builder(20)
		gen: gen
	}
}

fn (d mut JsDoc) gen_indent() {
	if d.gen.indent > 0 && d.empty_line {
		d.out.write(tabs[d.gen.indent])
	}
	d.empty_line = false
}

fn (d mut JsDoc) write(s string) {
	d.gen_indent()
	d.out.write(s)
}

fn (d mut JsDoc) writeln(s string) {
	d.gen_indent()
	d.out.writeln(s)
	d.empty_line = true
}

fn (d mut JsDoc) reset() {
	d.out = strings.new_builder(20)
	d.empty_line = false
}

fn (d mut JsDoc) gen_typ(typ string, name string) string {
	d.reset()
	d.write('/**')
	d.write(' @type {$typ}')
	if name.len > 0 {
		d.write(' - $name')
	}
	d.write(' */')
	return d.out.str()
}

fn (d mut JsDoc) gen_ctor(fields []ast.StructField) string {
	d.reset()
	d.writeln('/**')
	d.write('* @param {{')
	for i, field in fields {
		d.write('$field.name: ${d.gen.typ(field.typ)}')
		if i < fields.len-1 { d.write(', ') }
	}
	d.writeln('}} values - values for this class fields')
	d.writeln('* @constructor')
	d.write('*/')
	return d.out.str()
}

fn (d mut JsDoc) gen_fn(it ast.FnDecl) string {
	d.reset()
	type_name := d.gen.typ(it.return_type)
	d.writeln('/**')
	for i, arg in it.args {
		arg_type_name := d.gen.typ(arg.typ)
		is_varg := i == it.args.len - 1 && it.is_variadic
		if is_varg {
			d.writeln('* @param {...$arg_type_name} $arg.name')
		} else {
			d.writeln('* @param {$arg_type_name} $arg.name')
		}
	}
	d.writeln('* @return {$type_name}')
	d.write('*/')
	return d.out.str()
}