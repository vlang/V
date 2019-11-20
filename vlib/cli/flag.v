module cli

pub enum FlagType {
	bool
	int
	float
	string
}

pub struct Flag {
pub mut:
	flag FlagType
	name string
	abbrev string
	description string
	global bool
	required bool

	value string
}

pub fn (flags []Flag) get_bool(name string) ?bool {
	value := flags.get_raw(name) or { return error(err) }
	return value == 'true'
}

pub fn (flags []Flag) get_int(name string) ?int {
	value := flags.get_raw(name) or { return error(err) }
	return value.int()
}

pub fn (flags []Flag) get_float(name string) ?f32 {
	value := flags.get_raw(name) or { return error(err) }
	return value.f32()
}

pub fn (flags []Flag) get_string(name string) ?string {
	return flags.get_raw(name)
}

// check if first arg matches flag
fn (flag mut Flag) matches(args []string) bool {
	return 
		(flag.name != '' && args[0].starts_with('--${flag.name}')) ||
		(flag.abbrev != '' && args[0].starts_with('-${flag.abbrev}'))
}

// parse flag value from arguments and return arguments with all consumed element removed
fn (flag mut Flag) parse(args []string) ?[]string {
	if flag.matches(args) {
		if flag.flag == .bool {
			new_args := flag.parse_bool(args) or { return error(err) }
			return new_args
		} else {
			new_args := flag.parse_raw(args) or { return error(err) }
			return new_args
		}
	} else {
		return args
	}
}

fn (flag mut Flag) parse_raw(args []string) ?[]string {
	if args[0].len > flag.name.len && args[0].contains('=') {
		println('1')
		flag.value = args[0].split('=')[1]
		return args.right(1)
	} else if args.len >= 2 {
		flag.value = args[1]
		return args.right(2)
	}
	return error('missing argument for ${flag.name}')
}

fn (flag mut Flag) parse_bool(args []string) ?[]string {
	if args[0].len > flag.name.len && args[0].contains('=') {
		flag.value = args[0].split('=')[1]
		return args.right(1)
	} else if args.len >= 2 { 
		if args[1] in ['true', 'false'] {
			flag.value = args[1]
			return args.right(2)
		} 
	} 
	flag.value = 'true'
	return args.right(1)
}

fn (flags []Flag) get_raw(name string) ?string {
	for flag in flags {
		if flag.name == name {
			return flag.value
		}
	}
	return error('flag ${name} not found.')
}

fn (flags []Flag) contains(name string) bool {
	for flag in flags {
		if flag.name == name || flag.abbrev == name {
			return true
		}
	}
	return false
}
