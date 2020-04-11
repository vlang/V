module js

import (
	strings
	v.ast
	v.table
	v.depgraph
	v.token
	v.pref
	term
	v.util
)

const (
	//TODO
	js_reserved = ['delete', 'const', 'let', 'var', 'function', 'continue', 'break', 'switch', 'for', 'in', 'of', 'instanceof', 'typeof']
	tabs = ['', '\t', '\t\t', '\t\t\t', '\t\t\t\t', '\t\t\t\t\t', '\t\t\t\t\t\t', '\t\t\t\t\t\t\t', '\t\t\t\t\t\t\t\t']
)

struct JsGen {
	out   			strings.Builder
	table 			&table.Table
	definitions 	strings.Builder
	constants		strings.Builder // all global V constants 
	pref            &pref.Preferences
	doc				&JsDoc
	mut:
	file			ast.File
	inside_ternary  bool
	inside_loop		bool
	is_test         bool
	indent			int
	stmt_start_pos	int
	defer_stmts     []ast.DeferStmt
	fn_decl			&ast.FnDecl // pointer to the FnDecl we are currently inside otherwise 0
	empty_line		bool
}

pub fn gen(files []ast.File, table &table.Table, pref &pref.Preferences) string {
	mut g := &JsGen{
		out: strings.new_builder(100)
		definitions: strings.new_builder(100)
		constants: strings.new_builder(100)
		table: table
		pref: pref
		indent: -1
		fn_decl: 0
		empty_line: true
		doc: 0
	}
	g.doc = new_jsdoc(g)
	g.init()

	for file in files {
		g.file = file
		g.is_test = g.file.path.ends_with('_test.v')
		g.stmts(file.stmts)
	}
	g.finish()
	return g.hashes() + g.definitions.str() + g.constants.str() + g.out.str()
}

pub fn (g mut JsGen) init() {
	g.definitions.writeln('// Generated by the V compiler')
	g.constants.writeln('const CONSTANTS = Object.freeze({')
}

pub fn (g mut JsGen) finish() {
	g.constants.writeln('});')
}

pub fn (g JsGen) hashes() string {
	res := '// V_COMMIT_HASH ${util.vhash()}\n'
	res += '// V_CURRENT_COMMIT_HASH ${util.githash(g.pref.building_v)}\n\n'
	return res
}


// V type to JS type
pub fn (g mut JsGen) typ(t table.Type) string {
	nr_muls := table.type_nr_muls(t)
	sym := g.table.get_type_symbol(t)
	mut styp := sym.name.replace('.', '__')
	if styp.starts_with('JS__') {
		styp = styp[4..]
	}
	match styp {
		'int' {
			styp = 'number'
		}
		'bool' {
			styp = 'boolean'
		} else {}
	}
	return styp
}

pub fn (g &JsGen) save() {}

pub fn (g mut JsGen) gen_indent() {
	if g.indent > 0 && g.empty_line {
		g.out.write(tabs[g.indent])
	}
	g.empty_line = false
}

pub fn (g mut JsGen) write(s string) {
	g.gen_indent()
	g.out.write(s)
}

pub fn (g mut JsGen) writeln(s string) {
	g.gen_indent()
	g.out.writeln(s)
	g.empty_line = true
}

fn (g mut JsGen) stmts(stmts []ast.Stmt) {
	g.indent++
	for stmt in stmts {
		g.stmt(stmt)
	}
	g.indent--
}

fn (g mut JsGen) stmt(node ast.Stmt) {
	g.stmt_start_pos = g.out.len

	match node {
		ast.AssertStmt {
			g.gen_assert_stmt(it)
		}
		ast.AssignStmt {
			g.gen_assign_stmt(it)
		}
		ast.Attr {
			g.gen_attr(it)
		}
		ast.Block {
			g.gen_block(it)
		}
		ast.BranchStmt {
			g.gen_branch_stmt(it)
		}
		ast.ConstDecl {
			g.gen_const_decl(it)
		}
		ast.CompIf {
			// skip: JS has no compile time if
		}
		ast.DeferStmt {
			g.defer_stmts << *it
		}
		ast.EnumDecl {
			g.gen_enum_decl(it)
			g.writeln('')
		}
		ast.ExprStmt {
			g.gen_expr_stmt(it)
		}
		ast.FnDecl {
			g.fn_decl = it
			g.gen_fn_decl(it)
			g.writeln('')
		}
		ast.ForCStmt {
			g.gen_for_c_stmt(it)
		}
		ast.Return {
			if g.defer_stmts.len > 0 {
				g.gen_defer_stmts()
			}
			g.gen_return_stmt(it)
		}
		ast.ForStmt {
			g.write('while (')
			g.expr(it.cond)
			g.writeln(') {')
			for stmt in it.stmts {
				g.stmt(stmt)
			}
			g.writeln('}')
		}
		ast.StructDecl {
			g.gen_struct_decl(it)
		}
		ast.ExprStmt {
			g.expr(it.expr)
		}
		else {
			verror('jsgen.stmt(): bad node')
		}
	}
}

fn (g mut JsGen) expr(node ast.Expr) {
	// println('cgen expr()')
	print(typeof(node))
	print(' ')
	println(node)
	match node {
		ast.IntegerLiteral {
			g.write(it.val)
		}
		ast.FloatLiteral {
			g.write(it.val)
		}
		/*
		ast.UnaryExpr {
			g.expr(it.left)
			g.write(' $it.op ')
		}
		*/

		ast.StringLiteral {
			g.write('tos3("$it.val")')
		}
		ast.InfixExpr {
			g.expr(it.left)
			g.write(' $it.op.str() ')
			g.expr(it.right)
		}
		// `user := User{name: 'Bob'}`
		ast.StructInit {
			type_sym := g.table.get_type_symbol(it.typ)
			g.writeln('new ${type_sym.name}(')
			g.indent++
			for i, field in it.fields {
				g.expr(it.exprs[i])
				g.write(' /* $field */')
				if i < it.fields.len-1 {
					g.write(', ')				
				}
				g.writeln('')
			}
			g.indent--
			g.write(')')
		}
		ast.CallExpr {
			g.write('${it.name}(')
			for i, arg in it.args {
				g.expr(arg.expr)
				if i != it.args.len - 1 {
					g.write(', ')
				}
			}
			g.write(')')
		}
		ast.Ident {
			g.write('$it.name')
		}
		ast.BoolLiteral {
			if it.val == true {
				g.write('true')
			}
			else {
				g.write('false')
			}
		}
		ast.IfExpr {
			for i, branch in it.branches {
				if i == 0 {
					g.write('if (')
					g.expr(branch.cond)
					g.writeln(') {')
				}
				else if i < it.branches.len-1 || !it.has_else {
					g.write('else if (')
					g.expr(branch.cond)
					g.writeln(') {')
				}
				else {
					g.write('else {')
				}
				g.stmts(branch.stmts)
				g.writeln('}')
			}
		}
		ast.PostfixExpr {
			g.expr(it.expr)
			g.write(it.op.str())
		}
		else {
			println(term.red('jsgen.expr(): bad node'))
		}
	}
}

fn (g mut JsGen) gen_assert_stmt(a ast.AssertStmt) {
	g.writeln('// assert')
	g.write('if( ')
	g.expr(a.expr)
	g.write(' ) {')
	s_assertion := a.expr.str().replace('"', "\'")
	mut mod_path := g.file.path
	if g.is_test {
		g.writeln('	g_test_oks++;')
		g.writeln('	cb_assertion_ok("${mod_path}", ${a.pos.line_nr+1}, "assert ${s_assertion}", "${g.fn_decl.name}()" );')
		g.writeln('} else {')
		g.writeln('	g_test_fails++;')
		g.writeln('	cb_assertion_failed("${mod_path}", ${a.pos.line_nr+1}, "assert ${s_assertion}", "${g.fn_decl.name}()" );')
		g.writeln('	exit(1);')
		g.writeln('}')
		return
	}
	g.writeln('} else {')
	g.writeln('	eprintln("${mod_path}:${a.pos.line_nr+1}: FAIL: fn ${g.fn_decl.name}(): assert $s_assertion");')
	g.writeln('	exit(1);')
	g.writeln('}')
}

fn (g mut JsGen) gen_assign_stmt(it ast.AssignStmt) {
	if it.left.len > it.right.len {
		// multi return
		jsdoc := strings.new_builder(50)
		jsdoc.write('[')
		stmt := strings.new_builder(50)
		stmt.write('const [')
		for i, ident in it.left {
			ident_var_info := ident.var_info()
			styp := g.typ(ident_var_info.typ)
			jsdoc.write(styp)
			if ident.kind == .blank_ident {
				stmt.write('_')
			} else {
				stmt.write('$ident.name')				
			}
			if i < it.left.len - 1 {
				jsdoc.write(', ')
				stmt.write(', ')
			}
		}
		jsdoc.write(']')
		stmt.write('] = ')
		g.writeln(g.doc.gen_typ(jsdoc.str(), ''))
		g.write(stmt.str())
		g.expr(it.right[0])
		g.writeln(';')
	}
	else {
		// `a := 1` | `a,b := 1,2`
		for i, ident in it.left {
			val := it.right[i]
			ident_var_info := ident.var_info()
			styp := g.typ(ident_var_info.typ)
			
			if !g.inside_loop {
				g.writeln(g.doc.gen_typ(styp, ident.name))
			}
			
			if g.inside_loop {
				g.write('let ')
			} else {
				g.write('const ')
			}

			if ident.kind == .blank_ident {
				g.write('_ = ')
				g.expr(val)
			} else {
				g.write('$ident.name = ')
				g.expr(val)
			}

			if g.inside_loop {
				g.write("; ")
			} else {
				g.writeln(';')
			}
		}
	}
}

fn (g mut JsGen) gen_attr(it ast.Attr) {
	g.writeln('/* [$it.name] */')
}

fn (g mut JsGen) gen_block(it ast.Block) {
	g.writeln('{')
	g.stmts(it.stmts)
	g.writeln('}')
}

fn (g mut JsGen) gen_branch_stmt(it ast.BranchStmt) {
	// continue or break
	g.write(it.tok.kind.str())
	g.writeln(';')
}

fn (g mut JsGen) gen_const_decl(it ast.ConstDecl) {
	old_indent := g.indent
	for i, field in it.fields {
		// TODO hack. Cut the generated value and paste it into definitions.
		pos := g.out.len
		g.expr(field.expr)
		val := g.out.after(pos)
		g.out.go_back(val.len)
		typ := g.typ(field.typ)
		g.constants.write('\t')
		g.constants.writeln(g.doc.gen_typ(typ, field.name))
		g.constants.write('\t')
		g.constants.write('$field.name: $val')
		if i < it.fields.len - 1 {
			g.constants.writeln(',')
		}
	}
	g.constants.writeln('')
}

fn (g mut JsGen) gen_defer_stmts() {
	g.writeln('{')
	g.indent++
	g.writeln('// defer')
	g.indent--
	for defer_stmt in g.defer_stmts {
		g.stmts(defer_stmt.stmts)
	}
	g.writeln('}')
}

fn (g mut JsGen) gen_enum_decl(it ast.EnumDecl) {
	g.writeln('const $it.name = Object.freeze({')
	g.indent++
	for i, field in it.fields {
		g.write('$field.name: ')
		if field.has_expr {
			pos := g.out.len
			g.expr(field.expr)
			expr_str := g.out.after(pos)
			g.out.go_back(expr_str.len)
			g.write('$expr_str')
		} else {
			g.write('$i')
		}
		g.writeln(',')
	}
	g.indent--
	g.writeln('});')
}

fn (g mut JsGen) gen_expr_stmt(it ast.ExprStmt) {
	g.expr(it.expr)
	expr := it.expr
	match expr {
		ast.IfExpr {
			// no ; after an if expression
		}
		else {
			if !g.inside_ternary {
				g.writeln(';')
			}
		}
	}
}

fn (g mut JsGen) gen_fn_decl(it ast.FnDecl) {
	if it.no_body {
		return
	}

	is_main := it.name == 'main'
	if is_main {
		// there is no concept of main in JS but we do have iife
		g.writeln('/* program entry point */')
		g.write('(function(')
	} else {
		mut name := it.name
		c := name[0]
		if c in [`+`, `-`, `*`, `/`] {
			name = util.replace_op(name)
		}

		type_name := g.typ(it.return_type)

		// generate jsdoc for the function
		g.writeln('/**')
		for i, arg in it.args {
			arg_type_name := g.typ(arg.typ)
			is_varg := i == it.args.len - 1 && it.is_variadic
			if is_varg {
				g.writeln('* @param {...$arg_type_name} $arg.name')
			} else {
				g.writeln('* @param {$arg_type_name} $arg.name')
			}
		}
		g.writeln('* @return {$type_name}')
		g.writeln('*/')


		if it.is_method {
			// javascript has class methods, so we just assign this function on the class prototype
			className :=  g.table.get_type_symbol(it.receiver.typ).name
			g.write('${className}.prototype.${name} = ')
		}
		g.write('function ${name}(')
	}
	g.fn_args(it.args, it.is_variadic)
	g.writeln(') {')

	if is_main {
		g.writeln('\t_vinit();')
	}

	g.stmts(it.stmts)
	g.writeln('}')
	if is_main {
		g.writeln(')();')
	}
	g.fn_decl = 0
}

fn (g mut JsGen) gen_for_c_stmt(it ast.ForCStmt) {
	g.inside_loop = true
	g.write('for (')
	if it.has_init {
		g.stmt(it.init)
	} else {
		g.write('; ')
	}
	if it.has_cond {
		g.expr(it.cond)
	}
	g.write('; ')
	if it.has_inc {
		g.expr(it.inc)
	}
	g.writeln(') {')
	g.stmts(it.stmts)
	g.writeln('}')
	g.inside_loop = false
}

fn (g mut JsGen) fn_args(args []table.Arg, is_variadic bool) {
	no_names := args.len > 0 && args[0].name == 'arg_1'
	for i, arg in args {
		is_varg := i == args.len - 1 && is_variadic
		if is_varg {
			g.write('...$arg.name')
		} else {
			g.write(arg.name)
		}
		// if its not the last argument
		if i < args.len - 1 {
			g.write(', ')
		}
	}
}

fn (g mut JsGen) gen_return_stmt(it ast.Return) {
	g.write('return ')

	if g.fn_decl.name == 'main' {
		// we can't return anything in main
		g.writeln('void;')
		return
	}

	// multiple returns
	if it.exprs.len > 1 {
		g.write('[')
		for i, expr in it.exprs {
			g.expr(expr)
			if i < it.exprs.len - 1 {
				g.write(', ')
			}
		}
		g.write(']')
	}
	else {
		g.expr(it.exprs[0])
	}
	g.writeln(';')
}

fn (g mut JsGen) gen_struct_decl(it ast.StructDecl) {
  g.writeln('class $it.name {')
	g.indent++
	g.write('constructor(')
	for i, field in it.fields {
		g.write('/* ${g.typ(field.typ)} */ $field.name')
		if i < it.fields.len-1 { g.write(', ') }
	}
	g.writeln(') {')
	g.indent++
	for field in it.fields {
    typ := g.typ(field.typ)
		g.writeln(g.doc.gen_typ(typ, field.name))
	  g.writeln('this.$field.name = $field.name')
	}
	g.indent--
	g.writeln('}')
	g.indent--
	g.writeln('}')
}

fn verror(s string) {
	util.verror('jsgen error', s)
}
