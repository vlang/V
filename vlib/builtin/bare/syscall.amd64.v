module builtin

pub enum Linux_mem {
	page_size = 4096
}

pub const (
	wp_sys_wnohang     = u64(0x00000001)
	wp_sys_wuntraced   = u64(0x00000002)
	wp_sys_wstopped    = u64(0x00000002)
	wp_sys_wexited     = u64(0x00000004)
	wp_sys_wcontinued  = u64(0x00000008)
	wp_sys_wnowait     = u64(0x01000000) // don't reap, just poll status.
	wp_sys___wnothread = u64(0x20000000) // don't wait on children of other threads in this group
	wp_sys___wall      = u64(0x40000000) // wait on all children, regardless of type
	wp_sys___wclone    = u64(0x80000000) // wait only on non-sigchld children
)

// First argument to waitid:
pub enum Wi_which {
	p_all = 0
	p_pid = 1
	p_pgid = 2
}

pub enum Wi_si_code {
	cld_exited = 1 // child has exited
	cld_killed = 2 // child was killed
	cld_dumped = 3 // child terminated abnormally
	cld_trapped = 4 // traced child has trapped
	cld_stopped = 5 // child has stopped
	cld_continued = 6 // stopped child has continued
}

/*
Paraphrased from "man 2 waitid" on Linux

	Upon successful return, waitid() fills in the
	following fields of the siginfo_t structure
	pointed to by infop:

	si_pid, offset 0x10, int index 0x04:
		The process ID of the child.

	si_uid: offset 0x14, int index 0x05
		The real user ID of the child.

	si_signo: offset 0x00, int index 0x00
		Always set to SIGCHLD.

	si_status: ofset 0x18, int index 0x06
		1 the exit status of the child, as given to _exit(2)
			(or exit(3)) (sc_sys.cld_exited)
		2 the signal that caused the child to terminate, stop,
			or continue.
		3 The si_code field can be used to determine how to
			interpret this field.

	si_code, set to one of (enum Wi_si_code), offset 0x08, int index 0x02:
		CLD_EXITED (child called _exit(2));
		CLD_KILLED (child killed by signal);
		CLD_DUMPED (child  killed by signal, and dumped core);
		CLD_STOPPED (child stopped by signal);
		CLD_TRAPPED (traced child has trapped);
		CLD_CONTINUED (child continued by SIGCONT).
*/

pub enum Sig_index {
	si_signo = 0x00
	si_code = 0x02
	si_pid = 0x04
	si_uid = 0x05
	si_status = 0x06
	si_size = 0x80
}

pub enum Signo {
	sighup = 1 // Hangup.
	sigint = 2 // Interactive attention signal.
	sigquit = 3 // Quit.
	sigill = 4 // Illegal instruction.
	sigtrap = 5 // Trace/breakpoint trap.
	sigabrt = 6 // Abnormal termination.
	sigbus = 7
	sigfpe = 8 // Erroneous arithmetic operation.
	sigkill = 9 // Killed.
	sigusr1 = 10
	sigsegv = 11 // Invalid access to storage.
	sigusr2 = 12
	sigpipe = 13 // Broken pipe.
	sigalrm = 14 // Alarm clock.
	sigterm = 15 // Termination request.
	sigstkflt = 16
	sigchld = 17
	sigcont = 18
	sigstop = 19
	sigtstp = 20
	sigttin = 21 // Background read from control terminal.
	sigttou = 22 // Background write to control terminal.
	sigurg = 23
	sigxcpu = 24 // CPU time limit exceeded.
	sigxfsz = 25 // File size limit exceeded.
	sigvtalrm = 26 // Virtual timer expired.
	sigprof = 27 // Profiling timer expired.
	sigwinch = 28
	sigpoll = 29
	sigsys = 31
}

pub const (
	fcntlf_dupfd         = 0x00000000
	fcntlf_exlck         = 0x00000004
	fcntlf_getfd         = 0x00000001
	fcntlf_getfl         = 0x00000003
	fcntlf_getlk         = 0x00000005
	fcntlf_getlk64       = 0x0000000c
	fcntlf_getown        = 0x00000009
	fcntlf_getowner_uids = 0x00000011
	fcntlf_getown_ex     = 0x00000010
	fcntlf_getsig        = 0x0000000b
	fcntlf_ofd_getlk     = 0x00000024
	fcntlf_ofd_setlk     = 0x00000025
	fcntlf_ofd_setlkw    = 0x00000026
	fcntlf_owner_pgrp    = 0x00000002
	fcntlf_owner_pid     = 0x00000001
	fcntlf_owner_tid     = 0x00000000
	fcntlf_rdlck         = 0x00000000
	fcntlf_setfd         = 0x00000002
	fcntlf_setfl         = 0x00000004
	fcntlf_setlk         = 0x00000006
	fcntlf_setlk64       = 0x0000000d
	fcntlf_setlkw        = 0x00000007
	fcntlf_setlkw64      = 0x0000000e
	fcntlf_setown        = 0x00000008
	fcntlf_setown_ex     = 0x0000000f
	fcntlf_setsig        = 0x0000000a
	fcntlf_shlck         = 0x00000008
	fcntlf_unlck         = 0x00000002
	fcntlf_wrlck         = 0x00000001
	fcntllock_ex         = 0x00000002
	fcntllock_mand       = 0x00000020
	fcntllock_nb         = 0x00000004
	fcntllock_read       = 0x00000040
	fcntllock_rw         = 0x000000c0
	fcntllock_sh         = 0x00000001
	fcntllock_un         = 0x00000008
	fcntllock_write      = 0x00000080
	fcntlo_accmode       = 0x00000003
	fcntlo_append        = 0x00000400
	fcntlo_cloexec       = 0x00080000
	fcntlo_creat         = 0x00000040
	fcntlo_direct        = 0x00004000
	fcntlo_directory     = 0x00010000
	fcntlo_dsync         = 0x00001000
	fcntlo_excl          = 0x00000080
	fcntlo_largefile     = 0x00008000
	fcntlo_ndelay        = 0x00000800
	fcntlo_noatime       = 0x00040000
	fcntlo_noctty        = 0x00000100
	fcntlo_nofollow      = 0x00020000
	fcntlo_nonblock      = 0x00000800
	fcntlo_path          = 0x00200000
	fcntlo_rdonly        = 0x00000000
	fcntlo_rdwr          = 0x00000002
	fcntlo_trunc         = 0x00000200
	fcntlo_wronly        = 0x00000001
)

pub enum Errno {
	enoerror = 0x00000000
	e2big = 0x00000007
	eacces = 0x0000000d
	eagain = 0x0000000b
	ebadf = 0x00000009
	ebusy = 0x00000010
	echild = 0x0000000a
	edom = 0x00000021
	eexist = 0x00000011
	efault = 0x0000000e
	efbig = 0x0000001b
	eintr = 0x00000004
	einval = 0x00000016
	eio = 0x00000005
	eisdir = 0x00000015
	emfile = 0x00000018
	emlink = 0x0000001f
	enfile = 0x00000017
	enodev = 0x00000013
	enoent = 0x00000002
	enoexec = 0x00000008
	enomem = 0x0000000c
	enospc = 0x0000001c
	enotblk = 0x0000000f
	enotdir = 0x00000014
	enotty = 0x00000019
	enxio = 0x00000006
	eperm = 0x00000001
	epipe = 0x00000020
	erange = 0x00000022
	erofs = 0x0000001e
	espipe = 0x0000001d
	esrch = 0x00000003
	etxtbsy = 0x0000001a
	exdev = 0x00000012
}

pub enum Mm_prot {
	prot_read = 0x1
	prot_write = 0x2
	prot_exec = 0x4
	prot_none = 0x0
	prot_growsdown = 0x01000000
	prot_growsup = 0x02000000
}

pub enum Map_flags {
	map_shared = 0x01
	map_private = 0x02
	map_shared_validate = 0x03
	map_type = 0x0f
	map_fixed = 0x10
	map_file = 0x00
	map_anonymous = 0x20
	map_huge_shift = 26
	map_huge_mask = 0x3f
}

fn sys_call0(scn u64) u64 {
	mut res := u64(0)
	asm amd64 {
		syscall 
		; =a (res)
		; a (scn)
	}
	return res
}

fn sys_call1(scn u64, arg1 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
	}
	return res
}

fn sys_call2(scn u64, arg1 u64, arg2 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
		  S (arg2)
	}
	return res
}

fn sys_call3(scn u64, arg1 u64, arg2 u64, arg3 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
		  S (arg2)
		  d (arg3)
	}
	return res
}

fn sys_call4(scn u64, arg1 u64, arg2 u64, arg3 u64, arg4 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		mov r10, arg4
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
		  S (arg2)
		  d (arg3)
		  r (arg4)
		; r10
	}
	return res
}

fn sys_call5(scn u64, arg1 u64, arg2 u64, arg3 u64, arg4 u64, arg5 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		mov r10, arg4
		mov r8, arg5
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
		  S (arg2)
		  d (arg3)
		  r (arg4)
		  r (arg5)
		; r10
		  r8
	}
	return res
}

fn sys_call6(scn u64, arg1 u64, arg2 u64, arg3 u64, arg4 u64, arg5 u64, arg6 u64) u64 {
	mut res := u64(0)
	asm amd64 {
		mov r10, arg4
		mov r8, arg5
		mov r9, arg6
		syscall 
		; =a (res)
		; a (scn)
		  D (arg1)
		  S (arg2)
		  d (arg3)
		  r (arg4)
		  r (arg5)
		  r (arg6)
		; r10
		  r8
		  r9
	}
	return res
}

fn split_int_errno(rc_in u64) (i64, Errno) {
	rc := i64(rc_in)
	if rc < 0 {
		return i64(-1), Errno(-rc)
	}
	return rc, Errno.enoerror
}

// 0 sys_read unsigned int fd char *buf size_t count
pub fn sys_read(fd i64, buf &byte, count u64) (i64, Errno) {
	return split_int_errno(sys_call3(0, u64(fd), u64(buf), count))
}

// 1 sys_write unsigned int fd, const char *buf, size_t count
pub fn sys_write(fd i64, buf &byte, count u64) (i64, Errno) {
	return split_int_errno(sys_call3(1, u64(fd), u64(buf), count))
}

pub fn sys_open(filename &byte, flags i64, mode int) (i64, Errno) {
	// 2 sys_open  const char *filename  int flags int mode
	return split_int_errno(sys_call3(2, u64(filename), u64(flags), u64(mode)))
}

pub fn sys_close(fd i64) Errno {
	// 3 sys_close unsigned int fd
	return Errno(-i64(sys_call1(3, u64(fd))))
}

// 9 sys_mmap unsigned long addr  unsigned long len unsigned long prot  unsigned long flags unsigned long fd  unsigned long off
pub fn sys_mmap(addr &byte, len u64, prot Mm_prot, flags Map_flags, fildes u64, off u64) (&byte, Errno) {
	rc := sys_call6(9, u64(addr), len, u64(prot), u64(flags), fildes, off)
	a, e := split_int_errno(rc)
	return &byte(a), e
}

pub fn sys_munmap(addr voidptr, len u64) Errno {
	// 11 sys_munmap  unsigned long addr  size_t len
	return Errno(-sys_call2(11, u64(addr), len))
}

// 22  sys_pipe  int *filedes
pub fn sys_pipe(filedes &int) Errno {
	return Errno(sys_call1(22, u64(filedes)))
}

// 24 sys_sched_yield
pub fn sys_sched_yield() Errno {
	return Errno(sys_call0(24))
}

pub fn sys_madvise(addr voidptr, len u64, advice int) Errno {
	// 28 sys_madvise unsigned long start size_t len_in int behavior
	return Errno(sys_call3(28, u64(addr), len, u64(advice)))
}

// 39 sys_getpid
pub fn sys_getpid() int {
	return int(sys_call0(39))
}

// 57 sys_fork
pub fn sys_fork() int {
	return int(sys_call0(57))
}

// 58 sys_vfork
pub fn sys_vfork() int {
	return int(sys_call0(58))
}

// 33  sys_dup2  unsigned int oldfd  unsigned int newfd
pub fn sys_dup2(oldfd int, newfd int) (i64, Errno) {
	return split_int_errno(sys_call2(33, u64(oldfd), u64(newfd)))
}

// 59  sys_execve  const char *filename  const char *const argv[]  const char *const envp[]
// pub fn sys_execve(filename byteptr, argv []byteptr, envp []byteptr) int {
//  return sys_call3(59, filename, argv, envp)
//}

// 60 sys_exit  int error_code
pub fn sys_exit(ec int) {
	sys_call1(60, u64(ec))
}

// 102 sys_getuid
pub fn sys_getuid() int {
	return int(sys_call0(102))
}

// 247 sys_waitid  int which pid_t upid  struct siginfo *infop int options struct rusage *ru
pub fn sys_waitid(which Wi_which, pid int, infop &int, options int, ru voidptr) Errno {
	return Errno(sys_call5(247, u64(which), u64(pid), u64(infop), u64(options), u64(ru)))
}

const (
	mem_prot  = Mm_prot(int(Mm_prot.prot_read) | int(Mm_prot.prot_write))
	mem_flags = Map_flags(int(Map_flags.map_private) | int(Map_flags.map_anonymous))
	page_size = u64(Linux_mem.page_size)
)

pub fn mm_pages(size u64) u32 {
	pages := (size + u64(4) + page_size) / page_size
	return u32(pages)
}

pub fn mm_alloc(size u64) (&byte, Errno) {
	pages := mm_pages(size)
	n_bytes := u64(pages * u32(Linux_mem.page_size))

	a, e := sys_mmap(&byte(0), n_bytes, mem_prot, mem_flags, -1, 0)
	if e == .enoerror {
		unsafe {
			mut ap := &u32(a)
			*ap = pages
			return &byte(a + 4), e
		}
	}
	return &byte(0), e
}

pub fn mm_free(addr &byte) Errno {
	unsafe {
		ap := &int(addr - 4)
		size := u64(*ap) * u64(Linux_mem.page_size)
		return sys_munmap(ap, size)
	}
}

pub fn memcpy(dest0 &C.void, src0 &C.void, n size_t) &C.void {
	unsafe {
		mut dest := &byte(dest0)
		src := &byte(src0)
		for i in 0 .. int(n) {
			dest[i] = src[i]
		}
		return dest0
	}
}
