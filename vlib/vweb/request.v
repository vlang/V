module vweb

import io
import net.http
import net.urllib

fn parse_request(mut reader io.BufferedReader) ?http.Request {
	// request line
	mut line := reader.read_line() ?
	method, target, version := parse_request_line(line) ?

	// headers
	mut header := http.new_header()
	line = reader.read_line() ?
	for line != '' {
		key, value := parse_header(line) ?
		header.add_custom(key, value) ?
		line = reader.read_line() ?
	}
	header.coerce(canonicalize: true)

	// body
	mut body := []byte{}
	if length := header.get(.content_length) {
		n := length.int()
		if n > 0 {
			body = []byte{len: n}
			mut count := 0
			for count < body.len {
				count += reader.read(mut body[count..]) or { break }
			}
		}
	}

	return http.Request{
		method: method
		url: target.str()
		header: header
		data: body.bytestr()
		version: version
	}
}

fn parse_request_line(s string) ?(http.Method, urllib.URL, http.Version) {
	words := s.split(' ')
	if words.len != 3 {
		return error('malformed request line')
	}
	method := http.method_from_str(words[0])
	target := urllib.parse(words[1]) ?
	version := http.version_from_str(words[2])
	if version == .unknown {
		return error('unsupported version')
	}

	return method, target, version
}

fn parse_header(s string) ?(string, string) {
	if !s.contains(':') {
		return error('missing colon in header')
	}
	words := s.split_nth(':', 2)
	// TODO: parse quoted text according to the RFC
	return words[0], words[1].trim_left(' \t')
}

// Parse URL encoded key=value&key=value forms
fn parse_form(body string) map[string]string {
	words := body.split('&')
	mut form := map[string]string{}
	for word in words {
		kv := word.split_nth('=', 2)
		if kv.len != 2 {
			continue
		}
		key := urllib.query_unescape(kv[0]) or { continue }
		val := urllib.query_unescape(kv[1]) or { continue }
		form[key] = val
	}
	return form
	// }
	// todo: parse form-data and application/json
	// ...
}

fn parse_multipart_form(body string, boundary string) (map[string]string, map[string][]FileData) {
	sections := body.split(boundary)
	fields := sections[1..sections.len - 1]
	mut form := map[string]string{}
	mut files := map[string][]FileData{}

	for field in fields {
		crnl := field.contains('\r\n\r\n')
		mut section_start := field.index('\r\n\r\n') or { field.index('\n\n') or { 0 } }
		headers := field[0..section_start].split_into_lines()[1..]
		disposition := parse_disposition(if headers.len > 0 { headers[0] } else { '' })
		name := disposition['name'] or { continue }
		section_start += if section_start > 0 && crnl { 4 } else { 2 }
		section_end := field.last_index('\n') or { field.len }
		data := field[section_start..section_end].trim_right('\r')
		// Parse files
		// TODO: filename*
		if 'filename' in disposition {
			filename := disposition['filename']
			_, content_type := parse_header(if headers.len > 1 { headers[1] } else { '' }) or {
				'', ''
			}
			files[name] << FileData{
				filename: filename
				content_type: content_type
				data: data
			}
			continue
		}
		form[name] = data
	}
	return form, files
}

// Parse the Content-Disposition header of a multipart form
// Returns a map of the key="value" pairs
// Example: parse_disposition('Content-Disposition: form-data; name="a"; filename="b"') == {'name': 'a', 'filename': 'b'}
fn parse_disposition(line string) map[string]string {
	mut data := map[string]string{}
	for word in line.split(';') {
		kv := word.split_nth('=', 2)
		if kv.len != 2 {
			continue
		}
		key, value := kv[0].to_lower().trim_left(' \t'), kv[1]
		if value.starts_with('"') && value.ends_with('"') {
			data[key] = value[1..value.len - 1]
		} else {
			data[key] = value
		}
	}
	return data
}
