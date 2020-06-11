module os

#include <sys/stat.h> // #include <signal.h>
#include <errno.h>
#include <sys/utsname.h>

fn C.readdir(voidptr) C.dirent
fn C.getpid() int
fn C.readlink() int
fn C.getline(voidptr, voidptr, voidptr) int
fn C.ftell(fp voidptr) int
fn C.sigaction(int, voidptr, int)
fn C.open(charptr, int, int) int
fn C.fdopen(int, string) voidptr
fn C.CopyFile(&u32, &u32, int) int
fn C.fork() int
fn C.wait() int
//fn C.proc_pidpath(int, byteptr, int) int
fn C.uname(name voidptr) int

struct C.stat {
	st_size  int
	st_mode  u32
	st_mtime int
}

struct C.DIR {}

struct C.utsname {
mut:
	sysname  [256]char
	nodename [256]char
	release  [256]char
	version  [256]char
	machine  [256]char
}

struct C.sigaction {
mut:
	sa_mask      int
	sa_sigaction int
	sa_flags     int
}

struct C.dirent {
	d_name byteptr
}
