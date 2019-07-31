import http

fn test_escape_unescape() {
  original := 'те ст: т\\%'
  escaped := http.escape(original)
  assert escaped == '%D1%82%D0%B5%20%D1%81%D1%82%3A%20%D1%82%5C%25'
  unescaped := http.unescape(escaped)
  assert unescaped == original
}
