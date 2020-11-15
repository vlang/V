module net

import time

pub struct TcpConn {
pub:
	sock TcpSocket

mut:
	write_deadline time.Time
	read_deadline time.Time

	read_timeout time.Duration
	write_timeout time.Duration
}

pub fn dial_tcp(address string) ?TcpConn {
	s := new_tcp_socket()?
	s.connect(address)?

	return TcpConn {
		sock: s

		read_timeout: 0
		write_timeout: 0
	}
}

pub fn (c TcpConn) close() ? {
	c.sock.close()?
	return none
}

// write_ptr blocks and attempts to write all data
pub fn (c TcpConn) write_ptr(b byteptr, len int) ? {
	unsafe {
		mut ptr_base := byteptr(b)
		mut total_sent := 0

		for total_sent < len {
			ptr := ptr_base + total_sent
			remaining := len - total_sent
			mut sent := C.send(c.sock.handle, ptr, remaining, msg_nosignal)

			if sent < 0 {
				code := error_code()
				match code {
					error_ewouldblock {
						c.wait_for_write()
						continue
					}
					else {
						wrap_error(code)?
					}
				}
			}
			total_sent += sent
		}
	}
	return none
}

// write blocks and attempts to write all data
pub fn (c TcpConn) write(bytes []byte) ? {
	return c.write_ptr(bytes.data, bytes.len)
}

// write_str blocks and attempts to write all data
pub fn (c TcpConn) write_str(s string) ? {
	return c.write_ptr(s.str, s.len)
}

pub fn (c TcpConn) read_ptr(buf_ptr byteptr, len int) ?int {
	mut res := wrap_read_result(C.recv(c.sock.handle, buf_ptr, len, 0))?

	if res > 0 {
		return res
	}

	code := error_code()
	match code {
		error_ewouldblock {
			c.wait_for_read()?
			res = wrap_read_result(C.recv(c.sock.handle, buf_ptr, len, 0))?
			return socket_error(res)
		}
		else {
			wrap_error(code)?
		}
	}
}

pub fn (c TcpConn) read(mut buf []byte) ?int {
	return c.read_ptr(buf.data, buf.len)
}

pub fn (c TcpConn) read_deadline() ?time.Time {
	if c.read_deadline.unix == 0 {
		return c.read_deadline
	}
	return none
}

pub fn (mut c TcpConn) set_read_deadline(deadline time.Time) {
	c.read_deadline = deadline
}

pub fn (c TcpConn) write_deadline() ?time.Time {
	if c.write_deadline.unix == 0 {
		return c.write_deadline
	}
	return none
}

pub fn (mut c TcpConn) set_write_deadline(deadline time.Time) {
	c.write_deadline = deadline
}

pub fn (c TcpConn) read_timeout() time.Duration {
	return c.read_timeout
}

pub fn(mut c TcpConn) set_read_timeout(t time.Duration) {
	c.read_timeout = t
}

pub fn (c TcpConn) write_timeout() time.Duration {
	return c.write_timeout
}

pub fn (mut c TcpConn) set_write_timeout(t time.Duration) {
	c.write_timeout = t
}

[inline]
pub fn (c TcpConn) wait_for_read() ? {
	return wait_for_read(c.sock.handle, c.read_deadline, c.read_timeout)
}

[inline]
pub fn (c TcpConn) wait_for_write() ? {
	return wait_for_write(c.sock.handle, c.write_deadline, c.write_timeout)
}

pub fn (c TcpConn) peer_addr() ?Addr {
	mut addr := C.sockaddr{}
	len := sizeof(C.sockaddr)

	socket_error(C.getpeername(c.sock.handle, &addr, &len))?

	return new_addr(addr)
}

pub fn (c TcpConn) str() string {
	// TODO
	return 'TcpConn'
}

pub struct TcpListener {
	sock TcpSocket

mut:
	accept_timeout time.Duration
	accept_deadline time.Time
}

pub fn listen_tcp(port int) ?TcpListener {
	s := new_tcp_socket()?

	validate_port(port)?

	mut addr := C.sockaddr_in{}
	addr.sin_family = SocketFamily.inet
	addr.sin_port = C.htons(port)
	addr.sin_addr.s_addr = C.htonl(C.INADDR_ANY)
	size := sizeof(C.sockaddr_in)

	// cast to the correct type
	sockaddr := &C.sockaddr(&addr)

	socket_error(C.bind(s.handle, sockaddr, size))?
	socket_error(C.listen(s.handle, 128))?

	return TcpListener {
		sock: s
		accept_deadline: no_deadline
		accept_timeout: infinite_timeout
	}
}

pub fn (l TcpListener) accept() ?TcpConn {
	addr := C.sockaddr_storage{}
	unsafe {
		C.memset(&addr, 0, sizeof(C.sockaddr_storage))
	}
	size := sizeof(C.sockaddr_storage)

	// cast to correct type
	sock_addr := &C.sockaddr(&addr)
	mut new_handle := C.accept(l.sock.handle, sock_addr, &size)

	if new_handle <= 0 {
		l.wait_for_accept()?

		new_handle = C.accept(l.sock.handle, sock_addr, &size)

		if new_handle == -1 || new_handle == 0 {
			return none
		}
	}

	new_sock := TcpSocket {
		handle: new_handle
	}

	return TcpConn{
		sock: new_sock
	}
}

pub fn (c TcpListener) accept_deadline() ?time.Time {
	if c.accept_deadline.unix != 0 {
		return c.accept_deadline
	}
	return none
}

pub fn (mut c TcpListener) set_accept_deadline(deadline time.Time) {
	c.accept_deadline = deadline
}

pub fn (c TcpListener) accept_timeout() time.Duration {
	return c.accept_timeout
}

pub fn(mut c TcpListener) set_accept_timeout(t time.Duration) {
	c.accept_timeout = t
}

pub fn (c TcpListener) wait_for_accept() ? {
	return wait_for_read(c.sock.handle, c.accept_deadline, c.accept_timeout)
}

pub fn (c TcpListener) close() ? {
	c.sock.close()?
	return none
}

pub fn (c TcpListener) address() ?Addr {
	return c.sock.address()
}

struct TcpSocket {
pub:
	handle int
}

fn new_tcp_socket() ?TcpSocket {
	sockfd := socket_error(C.socket(SocketFamily.inet, SocketType.tcp, 0))?
	s := TcpSocket {
		handle: sockfd
	}
	//s.set_option_bool(.reuse_addr, true)?
	s.set_option_int(.reuse_addr, 1)?
	$if windows {
		t := true
		socket_error(C.ioctlsocket(sockfd, fionbio, &t))?
	} $else {
		socket_error(C.fcntl(sockfd, C.F_SETFL, C.O_NONBLOCK))
	}
	return s
}

pub fn (s TcpSocket) set_option_bool(opt SocketOption, value bool) ? {
	// TODO reenable when this `in` operation works again
	// if opt !in opts_can_set {
	// 	return err_option_not_settable
	// }

	// if opt !in opts_bool {
	// 	return err_option_wrong_type
	// }

	socket_error(C.setsockopt(s.handle, C.SOL_SOCKET, int(opt), &value, sizeof(bool)))?

	return none
}

pub fn (s TcpSocket) set_option_int(opt SocketOption, value int) ? {
	socket_error(C.setsockopt(s.handle, C.SOL_SOCKET, int(opt), &value, sizeof(int)))?

	return none
}

fn (s TcpSocket) close() ? {
	return shutdown(s.handle)
}

fn (s TcpSocket) @select(test Select, timeout time.Duration) ?bool {
	return @select(s.handle, test, timeout)
}

const (
	connect_timeout = 5 * time.second
)

fn (s TcpSocket) connect(a string) ? {
	addr := resolve_addr(a, .inet, .tcp)?

	res := C.connect(s.handle, &addr.addr, addr.len)

	if res == 0 {
		return none
	}

	errcode := error_code()

	if errcode == error_ewouldblock {
		write_result := s.@select(.write, connect_timeout)?
		if write_result {
			// succeeded
			return none
		}
		except_result := s.@select(.except, connect_timeout)?
		if except_result {
			return err_connect_failed
		}
		// otherwise we timed out
		return err_connect_timed_out
	}

	return wrap_error(errcode)
}

// address gets the address of a socket
pub fn (s TcpSocket) address() ?Addr {
	mut addr := C.sockaddr_in{}
	size := sizeof(C.sockaddr_in)
	// cast to the correct type
	sockaddr := &C.sockaddr(&addr)
	C.getsockname(s.handle, sockaddr, &size)
	return new_addr(sockaddr)
}
