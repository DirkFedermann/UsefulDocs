# 418 I'm a Teapot

This is an evergrowing list of files that Bots try to access to see what is installed on the website and if there could be an exploit.

It redirects to `teapot.php` which has the header `HTTP/1.1 418 I'm a teapot`.
Although it is not a fully fletched HTCPCP Server, it is the next best thing.

## Warning

If you use this list in the `.htaccess` file, there could be unforeseen errors and not working pages, due to false-positive. Especially for WordPress Sites.

Please use with caution and test thoroughly before deploying!
You've been warned.

## Links

Official Specification RFC2324: <https://www.rfc-editor.org/rfc/rfc2324>

MDN about 418 I'm a Teapot: <https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/418>

Google Teapot Page: <https://www.google.com/teapot>
