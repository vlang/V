// Copyright (c) 2019-2020 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module compiler

import (
	os
	time
	v.pref
	term
)

fn todo() {
}

fn (v &V) no_cc_installed() bool {
	$if windows {
		os.exec('$v.pref.ccompiler -v')or{
			if v.pref.verbosity.is_higher_or_equal(.level_one) {
				println('C compiler not found, trying to build with msvc...')
			}
			return true
		}
	}
	return false
}

fn (v mut V) cc() {
	if os.executable().contains('vfmt') {
		return
	}
	v.build_thirdparty_obj_files()
	vexe := pref.vexe_path()
	vdir := os.dir(vexe)
	// Just create a C/JavaScript file and exit
	// for example: `v -o v.c compiler`
	ends_with_c := v.pref.out_name.ends_with('.c')
	ends_with_js := v.pref.out_name.ends_with('.js')

	if v.pref.is_pretty_c && !ends_with_js {
		format_result := os.exec('clang-format -i -style=file "$v.out_name_c"') or {
			eprintln('clang-format not found')
			os.Result{exit_code:-1}
		}
		if format_result.exit_code > 0 {
			eprintln('clang-format failed to format $v.out_name_c')
			eprintln(format_result.output)
		}
	}

	if ends_with_c || ends_with_js {
		// Translating V code to JS by launching vjs.
		// Using a separate process for V.js is for performance mostly,
		// to avoid constant is_js checks.
		$if !js {
			if ends_with_js {
				vjs_path := vexe + 'js'
				if !os.exists(vjs_path) {
					println('V.js compiler not found, building...')
					// Build V.js. Specifying `-os js` makes V include
					// only _js.v files and ignore _c.v files.
					ret := os.system('$vexe -o $vjs_path -os js $vdir/cmd/v')
					if ret == 0 {
						println('Done.')
					}
					else {
						println('Failed.')
						exit(1)
					}
				}
				ret := os.system('$vjs_path -o $v.pref.out_name $v.pref.path')
				if ret == 0 {
					println('Done. Run it with `node $v.pref.out_name`')
					println('JS backend is at a very early stage.')
				}
			}
		}
		// v.out_name_c may be on a different partition than v.out_name
		os.mv_by_cp(v.out_name_c, v.pref.out_name)or{
			panic(err)
		}
		exit(0)
	}
	// Cross compiling for Windows
	if v.pref.os == .windows {
		$if !windows {
			v.cc_windows_cross()
			return
		}
	}
	$if windows {
		if v.pref.ccompiler == 'msvc' || v.no_cc_installed() {
			v.cc_msvc()
			return
		}
	}
	// arguments for the C compiler
	mut a := [v.pref.cflags, '-std=gnu11', '-Wall', '-Wextra',
	// TODO : activate -Werror once no warnings remain
	// '-Werror',
	// TODO : try and remove the below workaround options when the corresponding
	// warnings are totally fixed/removed
	'-Wno-unused-variable',
	// '-Wno-unused-but-set-variable',
	'-Wno-unused-parameter', '-Wno-unused-result', '-Wno-unused-function', '-Wno-missing-braces', '-Wno-unused-label']
	// TCC on Linux by default, unless -cc was provided
	// TODO if -cc = cc, TCC is still used, default compiler should be
	// used instead.
	if v.pref.fast {
		$if linux {
			$if !android {
				tcc_3rd := '$vdir/thirdparty/tcc/bin/tcc'
				// println('tcc third "$tcc_3rd"')
				tcc_path := '/var/tmp/tcc/bin/tcc'
				if os.exists(tcc_3rd) && !os.exists(tcc_path) {
					// println('moving tcc')
					// if there's tcc in thirdparty/, that means this is
					// a prebuilt V_linux.zip.
					// Until the libtcc1.a bug is fixed, we neeed to move
					// it to /var/tmp/
					os.system('mv $vdir/thirdparty/tcc /var/tmp/')
				}
				if v.pref.ccompiler == 'cc' && os.exists(tcc_path) {
					// TODO tcc bug, needs an empty libtcc1.a fila
					// os.mkdir('/var/tmp/tcc/lib/tcc/') or { panic(err) }
					// os.create('/var/tmp/tcc/lib/tcc/libtcc1.a')
					v.pref.ccompiler = tcc_path
					a << '-m64'
				}
			}
		} $else {
			verror('-fast is only supported on Linux right now')
		}
	}

	if !v.pref.is_so
		&& v.pref.build_mode != .build_module
		&& os.user_os() == 'windows'
		&& !v.pref.out_name.ends_with('.exe')
	{
		v.pref.out_name += '.exe'
	}

	// linux_host := os.user_os() == 'linux'
	v.log('cc() isprod=$v.pref.is_prod outname=$v.pref.out_name')
	if v.pref.is_so {
		a << '-shared -fPIC ' // -Wl,-z,defs'
		v.pref.out_name += '.so'
	}
	if v.pref.is_bare {
		a << '-fno-stack-protector -static -ffreestanding -nostdlib'
	}
	if v.pref.build_mode == .build_module {
		// Create the modules & out directory if it's not there.
		mut out_dir := if v.pref.path.starts_with('vlib') { '$v_modules_path${os.separator}cache${os.separator}$v.pref.path' } else { '$v_modules_path${os.separator}$v.pref.path' }
		pdir := out_dir.all_before_last(os.separator)
		if !os.is_dir(pdir) {
			os.mkdir_all(pdir)
		}
		v.pref.out_name = '${out_dir}.o' // v.out_name
		println('Building ${v.pref.out_name}...')
	}
	debug_mode := v.pref.is_debug
	mut debug_options := '-g'
	mut optimization_options := '-O2'
	mut guessed_compiler := v.pref.ccompiler
	if guessed_compiler == 'cc' && v.pref.is_prod {
		// deliberately guessing only for -prod builds for performance reasons
		if ccversion:=os.exec('cc --version'){
			if ccversion.exit_code == 0 {
				if ccversion.output.contains('This is free software;') && ccversion.output.contains('Free Software Foundation, Inc.') {
					guessed_compiler = 'gcc'
				}
				if ccversion.output.contains('clang version ') {
					guessed_compiler = 'clang'
				}
			}
		}
	}
	if v.pref.ccompiler.contains('clang') || guessed_compiler == 'clang' {
		if debug_mode {
			debug_options = '-g -O0 -no-pie'
		}
		optimization_options = '-O3'
		mut have_flto := true
		$if openbsd {
			have_flto = false
		}
		if have_flto {
			optimization_options += ' -flto'
		}
	}
	if v.pref.ccompiler.contains('gcc') || guessed_compiler == 'gcc' {
		if debug_mode {
			debug_options = '-g3 -no-pie'
		}
		optimization_options = '-O3 -fno-strict-aliasing -flto'
	}
	if debug_mode {
		a << debug_options
		$if macos {
			a << ' -ferror-limit=5000 '
		}
	}
	if v.pref.is_prod {
		a << optimization_options
	}
	if debug_mode && os.user_os() != 'windows' {
		a << ' -rdynamic ' // needed for nicer symbolic backtraces
	}
	if v.pref.ccompiler != 'msvc' && v.pref.os != .freebsd {
		a << '-Werror=implicit-function-declaration'
	}
	for f in v.generate_hotcode_reloading_compiler_flags() {
		a << f
	}
	mut libs := '' // builtin.o os.o http.o etc
	if v.pref.build_mode == .build_module {
		a << '-c'
	}
	else if v.pref.is_cache {
		builtin_o_path := os.join(v_modules_path,'cache','vlib','builtin.o')
		a << builtin_o_path.replace('builtin.o', 'strconv.o') // TODO hack no idea why this is needed
		if os.exists(builtin_o_path) {
			libs = builtin_o_path
		}
		else {
			println('$builtin_o_path not found... building module builtin')
			os.system('$vexe build module vlib${os.separator}builtin')
		}
		for imp in v.table.imports {
			if imp.contains('vweb') {
				continue
			} // not working
			if imp == 'webview' {
				continue
			}
			imp_path := imp.replace('.', os.separator)
			path := '$v_modules_path${os.separator}cache${os.separator}vlib${os.separator}${imp_path}.o'
			// println('adding ${imp_path}.o')
			if os.exists(path) {
				libs += ' ' + path
			}
			else {
				println('$path not found... building module $imp')
				if path.ends_with('vlib/ui.o') {
					println('copying ui...')
					os.cp('$vdir/thirdparty/ui/ui.o', path)or{
						panic('error copying ui files')
					}
					os.cp('$vdir/thirdparty/ui/ui.vh', v_modules_path + '/vlib/ui.vh')or{
						panic('error copying ui files')
					}
				}
				else {
					os.system('$vexe build module vlib${os.separator}$imp_path')
				}
			}
			if path.ends_with('vlib/ui.o') {
				a << '-framework Cocoa -framework Carbon'
			}
		}
	}
	if v.pref.sanitize {
		a << '-fsanitize=leak'
	}
	// Cross compiling linux TODO
	/*
	sysroot := '/tmp/lld/linuxroot/'
	if v.os == .linux && !linux_host {
		// Build file.o
		a << '-c --sysroot=$sysroot -target x86_64-linux-gnu'
		// Right now `out_name` can be `file`, not `file.o`
		if !v.out_name.ends_with('.o') {
			v.out_name = v.out_name + '.o'
		}
	}
	*/
	// Cross compiling windows
	//
	// Output executable name
	a << '-o "$v.pref.out_name"'
	if os.is_dir(v.pref.out_name) {
		verror("\'$v.pref.out_name\' is a directory")
	}
	// macOS code can include objective C  TODO remove once objective C is replaced with C
	if v.pref.os == .mac {
		a << '-x objective-c'
	}
	// The C file we are compiling
	a << '"$v.out_name_c"'
	if v.pref.os == .mac {
		a << '-x none'
	}
	// Min macos version is mandatory I think?
	if v.pref.os == .mac {
		a << '-mmacosx-version-min=10.7'
	}
	if v.pref.os == .windows {
		a << '-municode'
	}
	cflags := v.get_os_cflags()
	// add .o files
	a << cflags.c_options_only_object_files()
	// add all flags (-I -l -L etc) not .o files
	a << cflags.c_options_without_object_files()
	a << libs
	// Without these libs compilation will fail on Linux
	// || os.user_os() == 'linux'
	if !v.pref.is_bare && v.pref.build_mode != .build_module && v.pref.os in [.linux, .freebsd, .openbsd, .netbsd, .dragonfly, .solaris, .haiku] {
		a << '-lm -lpthread '
		// -ldl is a Linux only thing. BSDs have it in libc.
		if v.pref.os == .linux {
			a << ' -ldl '
		}
		if v.pref.os == .freebsd {
			// FreeBSD: backtrace needs execinfo library while linking
			a << ' -lexecinfo '
		}
	}
	if !v.pref.is_bare && v.pref.os == .js && os.user_os() == 'linux' {
		a << '-lm'
	}
	args := a.join(' ')
start:
	todo()
	// TODO remove
	cmd := '${v.pref.ccompiler} $args'
	// Run
	if v.pref.verbosity.is_higher_or_equal(.level_one) {
		println('\n==========')
		println(cmd)
	}
	ticks := time.ticks()
	res := os.exec(cmd)or{
		// C compilation failed.
		// If we are on Windows, try msvc
		println('C compilation failed.')
		/*
		if os.user_os() == 'windows' && v.pref.ccompiler != 'msvc' {
			println('Trying to build with MSVC')
			v.cc_msvc()
			return
		}
		*/

		verror(err)
		return
	}
	if res.exit_code != 0 {
		// the command could not be found by the system
		if res.exit_code == 127 {
			$if linux {
				// TCC problems on linux? Try GCC.
				if v.pref.ccompiler.contains('tcc') {
					v.pref.ccompiler = 'cc'
					goto start
				}
			}
			verror('C compiler error, while attempting to run: \n' + '-----------------------------------------------------------\n' + '$cmd\n' + '-----------------------------------------------------------\n' + 'Probably your C compiler is missing. \n' + 'Please reinstall it, or make it available in your PATH.\n\n' + missing_compiler_info())
		}
		if v.pref.is_debug {
			eword := 'error:'
			khighlight := if term.can_show_color_on_stdout() { term.red(eword) } else { eword }
			println(res.output.replace(eword, khighlight))
			verror("
==================
C error. This should never happen.

V compiler version: V $Version $vhash()
Host OS: ${pref.get_host_os().str()}
Target OS: $v.pref.os.str()

If you were not working with C interop and are not sure about what's happening,
please put the whole output in a pastebin and contact us through the following ways with a link to the pastebin:
- Raise an issue on GitHub: https://github.com/vlang/v/issues/new/choose
- Ask a question in #help on Discord: https://discord.gg/vlang")
		}
		else {
			if res.output.len < 30 {
				println(res.output)
			} else {
				elines := error_context_lines( res.output, 'error:', 1, 12 )
				println('==================')
				for eline in elines {
					println(eline)
				}
				println('...')
				println('==================')
				println('(Use `v -cg` to print the entire error message)\n')
			}
			verror("C error.

Please make sure that:
- You have all V dependencies installed.
- You did not declare a C function that was not included. (Try commenting your code that involves C interop)
- You are running the latest version of V. (Try running `v up` and rerunning your command)

If you're confident that all of the above is true, please try running V with the `-cg` option which enables more debugging capabilities.\n")
		}
	}
	diff := time.ticks() - ticks
	// Print the C command
	if v.pref.verbosity.is_higher_or_equal(.level_one) {
		println('${v.pref.ccompiler} took $diff ms')
		println('=========\n')
	}
	// Link it if we are cross compiling and need an executable
	/*
	if v.os == .linux && !linux_host && v.pref.build_mode != .build {
		v.out_name = v.out_name.replace('.o', '')
		obj_file := v.out_name + '.o'
		println('linux obj_file=$obj_file out_name=$v.out_name')
		ress := os.exec('/usr/local/Cellar/llvm/8.0.0/bin/ld.lld --sysroot=$sysroot ' +
		'-v -o $v.out_name ' +
		'-m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2 ' +
		'/usr/lib/x86_64-linux-gnu/crt1.o ' +
		'$sysroot/lib/x86_64-linux-gnu/libm-2.28.a ' +
		'/usr/lib/x86_64-linux-gnu/crti.o ' +
		obj_file +
		' /usr/lib/x86_64-linux-gnu/libc.so ' +
		'/usr/lib/x86_64-linux-gnu/crtn.o') or {
			verror(err)
			return
		}
		println(ress.output)
		println('linux cross compilation done. resulting binary: "$v.out_name"')
	}
	*/

	if !v.pref.is_keep_c && v.out_name_c != 'v.c' {
		os.rm(v.out_name_c)
	}
	if v.pref.compress {
		$if windows {
			println('-compress does not work on Windows for now')
			return
		}
		ret := os.system('strip $v.pref.out_name')
		if ret != 0 {
			println('strip failed')
			return
		}
		// NB: upx --lzma can sometimes fail with NotCompressibleException
		// See https://github.com/vlang/v/pull/3528
		mut ret2 := os.system('upx --lzma -qqq $v.pref.out_name')
		if ret2 != 0 {
			ret2 = os.system('upx -qqq $v.pref.out_name')
		}
		if ret2 != 0 {
			println('upx failed')
			$if macos {
				println('install upx with `brew install upx`')
			}
			$if linux {
				println('install upx\n' + 'for example, on Debian/Ubuntu run `sudo apt install upx`')
			}
			$if windows {
				// :)
			}
		}
	}
}

fn (c mut V) cc_windows_cross() {
	println('Cross compiling for Windows...')
	if !c.pref.out_name.ends_with('.exe') {
		c.pref.out_name += '.exe'
	}
	mut args := '-o $c.pref.out_name -w -L. '
	cflags := c.get_os_cflags()
	// -I flags
	args += if c.pref.ccompiler == 'msvc' { cflags.c_options_before_target_msvc() } else { cflags.c_options_before_target() }
	mut libs := ''
	if false && c.pref.build_mode == .default_mode {
		libs = '"$v_modules_path/vlib/builtin.o"'
		if !os.exists(libs) {
			println('`$libs` not found')
			exit(1)
		}
		for imp in c.table.imports {
			libs += ' "$v_modules_path/vlib/${imp}.o"'
		}
	}
	args += ' $c.out_name_c '

	args += if c.pref.ccompiler == 'msvc' { cflags.c_options_after_target_msvc() } else { cflags.c_options_after_target() }

	/*
	winroot := '$v_modules_path/winroot'
	if !os.is_dir(winroot) {
		winroot_url := 'https://github.com/vlang/v/releases/download/v0.1.10/winroot.zip'
		println('"$winroot" not found.')
		println('Download it from $winroot_url and save it in $v_modules_path')
		println('Unzip it afterwards.\n')
		println('winroot.zip contains all library and header files needed ' + 'to cross-compile for Windows.')
		exit(1)
	}
	mut obj_name := c.out_name
	obj_name = obj_name.replace('.exe', '')
	obj_name = obj_name.replace('.o.o', '.o')
	include := '-I $winroot/include '
	*/
	mut cmd := ''
	cmd = ''
	$if macos {
		cmd = 'x86_64-w64-mingw32-gcc -std=gnu11 $args -municode'
	}
	$else {
		panic('your platform is not supported yet')
	}

	println(cmd)
	//cmd := 'clang -o $obj_name -w $include -m32 -c -target x86_64-win32 $v_modules_path/$c.out_name_c'
	if c.pref.verbosity.is_higher_or_equal(.level_one) {
		println(cmd)
	}
	if os.system(cmd) != 0 {
		println('Cross compilation for Windows failed. Make sure you have clang installed.')
		exit(1)
	}
	/*
	if c.pref.build_mode != .build_module {
		link_cmd := 'lld-link $obj_name $winroot/lib/libcmt.lib ' + '$winroot/lib/libucrt.lib $winroot/lib/kernel32.lib $winroot/lib/libvcruntime.lib ' + '$winroot/lib/uuid.lib'
		if c.pref.show_c_cmd {
			println(link_cmd)
		}
		if os.system(link_cmd) != 0 {
			println('Cross compilation for Windows failed. Make sure you have lld linker installed.')
			exit(1)
		}
		// os.rm(obj_name)
	}
	*/
	println('Done!')
}

fn (c &V) build_thirdparty_obj_files() {
	for flag in c.get_os_cflags() {
		if flag.value.ends_with('.o') {
			rest_of_module_flags := c.get_rest_of_module_cflags(flag)
			if c.pref.ccompiler == 'msvc' || c.no_cc_installed() {
				build_thirdparty_obj_file_with_msvc(flag.value, rest_of_module_flags)
			}
			else {
				c.build_thirdparty_obj_file(flag.value, rest_of_module_flags)
			}
		}
	}
}

fn missing_compiler_info() string {
	$if windows {
		return 'https://github.com/vlang/v/wiki/Installing-a-C-compiler-on-Windows'
	}
	$if linux {
		return 'On Debian/Ubuntu, run `sudo apt install build-essential`'
	}
	$if macos {
		return 'Install command line XCode tools with `xcode-select --install`'
	}
	return ''
}

fn error_context_lines(text, keyword string, before, after int) []string {
	khighlight := if term.can_show_color_on_stdout() { term.red(keyword) } else { keyword }
	mut eline_idx := 0
	mut lines := text.split_into_lines()
	for idx, eline in lines {
		if eline.contains(keyword) {
			lines[idx] = lines[idx].replace(keyword, khighlight)
			if eline_idx == 0 {
				eline_idx = idx
			}
		}
	}
	idx_s := if eline_idx - before >= 0 { eline_idx - before } else { 0 }
	idx_e := if idx_s + after < lines.len { idx_s + after } else { lines.len }
	return lines[idx_s..idx_e]
}
