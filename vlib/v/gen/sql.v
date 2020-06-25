// Copyright (c) 2019-2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license that can be found in the LICENSE file.
module gen

import v.ast
import strings
import v.table
import v.util

// pg,mysql etc
const (
	dbtype = 'sqlite'
)

enum SqlExprSide {
	left
	right
}

fn (mut g Gen) sql_stmt(node ast.SqlStmt) {
	g.sql_i = 0
	g.writeln('\n\t// sql insert')
	db_name := g.new_tmp_var()
	g.sql_stmt_name = g.new_tmp_var()
	g.write('${dbtype}__DB $db_name = ')
	g.expr(node.db_expr)
	g.writeln(';')
	g.write('sqlite3_stmt* $g.sql_stmt_name = ${dbtype}__DB_init_stmt($db_name, tos_lit("')
	if node.kind == .insert {
		g.write('INSERT INTO ${util.strip_mod_name(node.table_name)} (')
	} else {
		g.write('UPDATE ${util.strip_mod_name(node.table_name)} SET ')
	}
	if node.kind == .insert {
		for i, field in node.fields {
			if field.name == 'id' {
				continue
			}
			g.write(field.name)
			if i < node.fields.len - 1 {
				g.write(', ')
			}
		}
		g.write(') values (')
		for i, field in node.fields {
			if field.name == 'id' {
				continue
			}
			g.write('?${i+0}')
			if i < node.fields.len - 1 {
				g.write(', ')
			}
		}
		g.write(')')
	} else if node.kind == .update {
		for i, col in node.updated_columns {
			g.write(' $col = ')
			g.expr_to_sql(node.update_exprs[i])
			if i < node.updated_columns.len - 1 {
				g.write(', ')
			}
		}
		g.write(' WHERE ')
	}
	if node.kind == .update {
		g.expr_to_sql(node.where_expr)
	}
	g.writeln('"));')
	if node.kind == .insert {
		// build the object now (`x.name = ... x.id == ...`)
		for i, field in node.fields {
			if field.name == 'id' {
				continue
			}
			x := '${node.object_var_name}.$field.name'
			if field.typ == table.string_type {
				g.writeln('sqlite3_bind_text($g.sql_stmt_name, ${i+0}, ${x}.str, ${x}.len, 0);')
			} else {
				g.writeln('sqlite3_bind_int($g.sql_stmt_name, ${i+0}, $x); // stmt')
			}
		}
	}
	// Dump all sql parameters generated by our custom expr handler
	binds := g.sql_buf.str()
	g.sql_buf = strings.new_builder(100)
	g.writeln(binds)
	g.writeln('sqlite3_step($g.sql_stmt_name);')
	g.writeln('if (strcmp(sqlite3_errmsg(${db_name}.conn), "not an error") != 0) puts(sqlite3_errmsg(${db_name}.conn)); ')
	g.writeln('sqlite3_finalize($g.sql_stmt_name);')
}

fn (mut g Gen) sql_select_expr(node ast.SqlExpr) {
	g.sql_i = 0
	/*
	`nr_users := sql db { ... }` =>
	```
		sql_init_stmt()
		sql_bind_int()
		sql_bind_string()
		...
		int nr_users = get_int(stmt)
	```
	*/
	cur_line := g.go_before_stmt(0)
	mut q := 'SELECT '
	if node.is_count {
		// `select count(*) from User`
		q += 'COUNT(*) from ${util.strip_mod_name(node.table_name)}'
	} else {
		// `select id, name, country from User`
		for i, field in node.fields {
			q += '$field.name'
			if i < node.fields.len - 1 {
				q += ', '
			}
		}
		q += ' FROM ${util.strip_mod_name(node.table_name)}'
	}
	if node.has_where {
		q += ' WHERE '
	}
	// g.write('${dbtype}__DB_q_int(*(${dbtype}__DB*)${node.db_var_name}.data, tos_lit("$q')
	g.sql_stmt_name = g.new_tmp_var()
	db_name := g.new_tmp_var()
	g.writeln('\n\t// sql select')
	// g.write('${dbtype}__DB $db_name = *(${dbtype}__DB*)${node.db_var_name}.data;')
	g.write('${dbtype}__DB $db_name = ') // $node.db_var_name;')
	g.expr(node.db_expr)
	g.writeln(';')
	// g.write('sqlite3_stmt* $g.sql_stmt_name = ${dbtype}__DB_init_stmt(*(${dbtype}__DB*)${node.db_var_name}.data, tos_lit("$q')
	g.write('sqlite3_stmt* $g.sql_stmt_name = ${dbtype}__DB_init_stmt($db_name, tos_lit("$q')
	if node.has_where && node.where_expr is ast.InfixExpr {
		g.expr_to_sql(node.where_expr)
	}
	g.write(' ORDER BY id ')
	if node.has_limit {
		g.write(' LIMIT ')
		g.expr_to_sql(node.limit_expr)
	}
	if node.has_offset {
		g.write(' OFFSET ')
		g.expr_to_sql(node.offset_expr)
	}
	g.writeln('"));')
	// Dump all sql parameters generated by our custom expr handler
	binds := g.sql_buf.str()
	g.sql_buf = strings.new_builder(100)
	g.writeln(binds)
	g.writeln('if (strcmp(sqlite3_errmsg(${db_name}.conn), "not an error") != 0) puts(sqlite3_errmsg(${db_name}.conn)); ')
	//
	if node.is_count {
		g.writeln('$cur_line ${dbtype}__get_int_from_stmt($g.sql_stmt_name);')
	} else {
		// `user := sql db { select from User where id = 1 }`
		tmp := g.new_tmp_var()
		styp := g.typ(node.typ)
		mut elem_type_str := ''
		if node.is_array {
			// array_User array_tmp;
			// for { User tmp; ... array_tmp << tmp; }
			array_sym := g.table.get_type_symbol(node.typ)
			array_info := array_sym.info as table.Array
			elem_type_str = g.typ(array_info.elem_type)
			g.writeln('$styp ${tmp}_array = __new_array(0, 10, sizeof($elem_type_str));')
			g.writeln('while (1) {')
			g.writeln('\t$elem_type_str $tmp = ($elem_type_str) {')
			//
			sym := g.table.get_type_symbol(array_info.elem_type)
			info := sym.info as table.Struct
			for field in info.fields {
				g.zero_struct_field(field)
			}
			g.writeln('};')
		} else {
			// `User tmp;`
			g.writeln('$styp $tmp = ($styp){')
			// Zero fields, (only the [skip] ones?)
			// If we don't, string values are going to be nil etc for fields that are not returned
			// by the db engine.
			sym := g.table.get_type_symbol(node.typ)
			info := sym.info as table.Struct
			for field in info.fields {
				g.zero_struct_field(field)
			}
			g.writeln('};')
		}
		//
		g.writeln('int _step_res$tmp = sqlite3_step($g.sql_stmt_name);')
		if node.is_array {
			// g.writeln('\tprintf("step res=%d\\n", _step_res$tmp);')
			g.writeln('\tif (_step_res$tmp == SQLITE_DONE) break;')
			g.writeln('\tif (_step_res$tmp == SQLITE_ROW) ;') // another row
			g.writeln('\telse if (_step_res$tmp != SQLITE_OK) break;')
		} else {
			// g.writeln('printf("RES: %d\\n", _step_res$tmp) ;')
			g.writeln('\tif (_step_res$tmp == SQLITE_OK || _step_res$tmp == SQLITE_ROW) {')
		}
		for i, field in node.fields {
			mut func := 'sqlite3_column_int'
			if field.typ == table.string_type {
				func = 'sqlite3_column_text'
				g.writeln('${tmp}.$field.name = tos_clone(${func}($g.sql_stmt_name, $i));')
			} else {
				g.writeln('${tmp}.$field.name = ${func}($g.sql_stmt_name, $i);')
			}
		}
		if node.is_array {
			g.writeln('\t array_push(&${tmp}_array, _MOV(($elem_type_str[]){ $tmp }));')
		}
		g.writeln('}')
		g.writeln('sqlite3_finalize($g.sql_stmt_name);')
		if node.is_array {
			g.writeln('$cur_line ${tmp}_array; ') // `array_User users = tmp_array;`
		} else {
			g.writeln('$cur_line $tmp; ') // `User user = tmp;`
		}
	}
}

fn (mut g Gen) sql_bind_int(val string) {
	g.sql_buf.writeln('sqlite3_bind_int($g.sql_stmt_name, $g.sql_i, $val);')
}

fn (mut g Gen) sql_bind_string(val, len string) {
	g.sql_buf.writeln('sqlite3_bind_text($g.sql_stmt_name, $g.sql_i, $val, $len, 0);')
}

fn (mut g Gen) expr_to_sql(expr ast.Expr) {
	// Custom handling for infix exprs (since we need e.g. `and` instead of `&&` in SQL queries),
	// strings. Everything else (like numbers, a.b) is handled by g.expr()
	//
	// TODO `where id = some_column + 1` needs literal generation of `some_column` as a string,
	// not a V variable. Need to distinguish column names from V variables.
	match expr {
		ast.InfixExpr {
			g.sql_side = .left
			g.expr_to_sql(expr.left)
			match expr.op {
				.eq { g.write(' = ') }
				.gt { g.write(' > ') }
				.lt { g.write(' < ') }
				.ge { g.write(' >= ') }
				.le { g.write(' <= ') }
				.and { g.write(' and ') }
				.logical_or { g.write(' or ') }
				.plus { g.write(' + ') }
				.minus { g.write(' - ') }
				.mul { g.write(' * ') }
				.div { g.write(' / ') }
				else {}
			}
			g.sql_side = .right
			g.expr_to_sql(it.right)
		}
		ast.StringLiteral {
			// g.write("'$it.val'")
			g.inc_sql_i()
			g.sql_bind_string('"$it.val"', it.val.len.str())
		}
		ast.IntegerLiteral {
			g.inc_sql_i()
			g.sql_bind_int(it.val)
		}
		ast.BoolLiteral {
			// true/false literals were added to Sqlite 3.23 (2018-04-02)
			// but lots of apps/distros use older sqlite (e.g. Ubuntu 18.04 LTS )
			g.inc_sql_i()
			g.sql_bind_int(if it.val {
				'1'
			} else {
				'0'
			})
		}
		ast.Ident {
			// `name == user_name` => `name == ?1`
			// for left sides just add a string, for right sides, generate the bindings
			if g.sql_side == .left {
				// println("sql gen left $expr.name")
				g.write(expr.name)
			} else {
				g.inc_sql_i()
				info := expr.info as ast.IdentVar
				typ := info.typ
				if typ == table.string_type {
					g.sql_bind_string('${expr.name}.str', '${expr.name}.len')
				} else if typ == table.int_type {
					g.sql_bind_int(expr.name)
				} else {
					verror('bad sql type=$typ ident_name=$expr.name')
				}
			}
		}
		ast.SelectorExpr {
			g.inc_sql_i()
			if expr.typ == table.int_type {
				if expr.expr !is ast.Ident {
					verror('orm selector not ident')
				}
				ident := expr.expr as ast.Ident
				g.sql_bind_int(ident.name + '.' + expr.field_name)
			} else {
				verror('bad sql type=$expr.typ selector expr=$expr.field_name')
			}
		}
		else {
			g.expr(expr)
		}
	}
	/*
	ast.Ident {
			g.write('$it.name')
		}
		else {}
	*/
}

fn (mut g Gen) inc_sql_i() {
	g.sql_i++
	g.write('?$g.sql_i')
}
