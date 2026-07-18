# ZAP Scanning Report

ZAP by [Checkmarx](https://checkmarx.com/).


## Summary of Alerts

| Risk Level | Number of Alerts |
| --- | --- |
| High | 1 |
| Medium | 8 |
| Low | 14 |
| Informational | 7 |




## Insights

| Level | Reason | Site | Description | Statistic |
| --- | --- | --- | --- | --- |
| Low | Warning |  | ZAP warnings logged - see the zap.log file for details | 7    |
| Info | Informational |  | Percentage of network failures | 1 % |
| Info | Informational | http://172.18.0.4 | Percentage of responses with status code 2xx | 83 % |
| Info | Informational | http://172.18.0.4 | Percentage of responses with status code 3xx | 4 % |
| Info | Informational | http://172.18.0.4 | Percentage of responses with status code 4xx | 11 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type application/javascript | 4 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type application/pdf | 2 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type image/png | 2 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type image/vnd.microsoft.icon | 2 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type text/css | 2 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type text/html | 82 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with content type text/plain | 2 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with method GET | 80 % |
| Info | Informational | http://172.18.0.4 | Percentage of endpoints with method POST | 19 % |
| Info | Informational | http://172.18.0.4 | Count of total endpoints | 41    |
| Info | Informational | http://172.18.0.4 | Percentage of slow responses | 37 % |







## Alerts

| Name | Risk Level | Number of Instances |
| --- | --- | --- |
| Path Traversal | High | 1 |
| Absence of Anti-CSRF Tokens | Medium | Systemic |
| CSP: Failure to Define Directive with No Fallback | Medium | 2 |
| CSP: Wildcard Directive | Medium | 2 |
| CSP: style-src unsafe-inline | Medium | 2 |
| Content Security Policy (CSP) Header Not Set | Medium | Systemic |
| Missing Anti-clickjacking Header | Medium | Systemic |
| Source Code Disclosure - SQL | Medium | 2 |
| Sub Resource Integrity Attribute Missing | Medium | 2 |
| Cookie No HttpOnly Flag | Low | 1 |
| Cookie without SameSite Attribute | Low | 1 |
| Cross-Domain JavaScript Source File Inclusion | Low | 2 |
| Cross-Origin-Embedder-Policy Header Missing or Invalid | Low | 4 |
| Cross-Origin-Opener-Policy Header Missing or Invalid | Low | 4 |
| Cross-Origin-Resource-Policy Header Missing or Invalid | Low | 5 |
| Dangerous JS Functions | Low | 1 |
| In Page Banner Information Leak | Low | 3 |
| Information Disclosure - Debug Error Messages | Low | 2 |
| Permissions Policy Header Not Set | Low | Systemic |
| Private IP Disclosure | Low | 2 |
| Server Leaks Version Information via "Server" HTTP Response Header Field | Low | Systemic |
| Timestamp Disclosure - Unix | Low | Systemic |
| X-Content-Type-Options Header Missing | Low | Systemic |
| Authentication Request Identified | Informational | 1 |
| Information Disclosure - Sensitive Information in URL | Informational | 2 |
| Information Disclosure - Suspicious Comments | Informational | 2 |
| Modern Web Application | Informational | 1 |
| Storable and Cacheable Content | Informational | 3 |
| Storable but Non-Cacheable Content | Informational | Systemic |
| User Controllable HTML Element Attribute (Potential XSS) | Informational | 8 |




## Alert Detail



### [ Path Traversal ](https://www.zaproxy.org/docs/alerts/6/)



##### High (Medium)

### Description

The Path Traversal attack technique allows an attacker access to files, directories, and commands that potentially reside outside the web document root directory. An attacker may manipulate a URL in such a way that the web site will execute or reveal the contents of arbitrary files anywhere on the web server. Any device that exposes an HTTP-based interface is potentially vulnerable to Path Traversal.

Most web sites restrict user access to a specific portion of the file-system, typically called the "web document root" or "CGI root" directory. These directories contain the files intended for user access and the executable necessary to drive web application functionality. To access files or execute commands anywhere on the file-system, Path Traversal attacks will utilize the ability of special-characters sequences.

The most basic Path Traversal attack uses the "../" special-character sequence to alter the resource location requested in the URL. Although most popular web servers will prevent this technique from escaping the web document root, alternate encodings of the "../" sequence may help bypass the security filters. These method variations include valid and invalid Unicode-encoding ("..%u2216" or "..%c0%af") of the forward slash character, backslash characters ("..\") on Windows-based servers, URL encoded characters "%2e%2e%2f"), and double URL encoding ("..%255c") of the backslash character.

Even if the web server properly restricts Path Traversal attempts in the URL path, a web application itself may still be vulnerable due to improper handling of user-supplied input. This is a common problem of web applications that use template mechanisms or load static text from files. In variations of the attack, the original URL parameter value is substituted with the file name of one of the web application's dynamic scripts. Consequently, the results can reveal source code because the file is interpreted as text instead of an executable script. These techniques often employ additional special characters such as the dot (".") to reveal the listing of the current working directory, or "%00" NULL characters in order to bypass rudimentary file extension checks.

* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=%252Fetc%252Fpasswd
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `page`
  * Attack: `/etc/passwd`
  * Evidence: `root:x:0:0`
  * Other Info: ``


Instances: 1

### Solution

Assume all input is malicious. Use an "accept known good" input validation strategy, i.e., use an allow list of acceptable inputs that strictly conform to specifications. Reject any input that does not strictly conform to specifications, or transform it into something that does. Do not rely exclusively on looking for malicious or malformed inputs (i.e., do not rely on a deny list). However, deny lists can be useful for detecting potential attacks or determining which inputs are so malformed that they should be rejected outright.

When performing input validation, consider all potentially relevant properties, including length, type of input, the full range of acceptable values, missing or extra inputs, syntax, consistency across related fields, and conformance to business rules. As an example of business rule logic, "boat" may be syntactically valid because it only contains alphanumeric characters, but it is not valid if you are expecting colors such as "red" or "blue."

For filenames, use stringent allow lists that limit the character set to be used. If feasible, only allow a single "." character in the filename to avoid weaknesses, and exclude directory separators such as "/". Use an allow list of allowable file extensions.

Warning: if you attempt to cleanse your data, then do so that the end result is not in the form that can be dangerous. A sanitizing mechanism can remove characters such as '.' and ';' which may be required for some exploits. An attacker can try to fool the sanitizing mechanism into "cleaning" data into a dangerous form. Suppose the attacker injects a '.' inside a filename (e.g. "sensi.tiveFile") and the sanitizing mechanism removes the character resulting in the valid filename, "sensitiveFile". If the input data are now assumed to be safe, then the file may be compromised. 

Inputs should be decoded and canonicalized to the application's current internal representation before being validated. Make sure that your application does not decode the same input twice. Such errors could be used to bypass allow list schemes by introducing dangerous inputs after they have been checked.

Use a built-in path canonicalization function (such as realpath() in C) that produces the canonical version of the pathname, which effectively removes ".." sequences and symbolic links.

Run your code using the lowest privileges that are required to accomplish the necessary tasks. If possible, create isolated accounts with limited privileges that are only used for a single task. That way, a successful attack will not immediately give the attacker access to the rest of the software or its environment. For example, database applications rarely need to run as the database administrator, especially in day-to-day operations.

When the set of acceptable objects, such as filenames or URLs, is limited or known, create a mapping from a set of fixed input values (such as numeric IDs) to the actual filenames or URLs, and reject all other inputs.

Run your code in a "jail" or similar sandbox environment that enforces strict boundaries between the process and the operating system. This may effectively restrict which files can be accessed in a particular directory or which commands can be executed by your software.

OS-level examples include the Unix chroot jail, AppArmor, and SELinux. In general, managed code may provide some protection. For example, java.io.FilePermission in the Java SecurityManager allows you to specify restrictions on file operations.

This may not be a feasible solution, and it only limits the impact to the operating system; the rest of your application may still be subject to compromise.


### Reference


* [ https://owasp.org/www-community/attacks/Path_Traversal ](https://owasp.org/www-community/attacks/Path_Traversal)
* [ https://cwe.mitre.org/data/definitions/22.html ](https://cwe.mitre.org/data/definitions/22.html)


#### CWE Id: [ 22 ](https://cwe.mitre.org/data/definitions/22.html)


#### WASC Id: 33

#### Source ID: 1

### [ Absence of Anti-CSRF Tokens ](https://www.zaproxy.org/docs/alerts/10202/)



##### Medium (Low)

### Description

No Anti-CSRF tokens were found in a HTML submission form.
A cross-site request forgery is an attack that involves forcing a victim to send an HTTP request to a target destination without their knowledge or intent in order to perform an action as the victim. The underlying cause is application functionality using predictable URL/form actions in a repeatable way. The nature of the attack is that CSRF exploits the trust that a web site has for a user. By contrast, cross-site scripting (XSS) exploits the trust that a user has for a web site. Like XSS, CSRF attacks are not necessarily cross-site, but they can be. Cross-site request forgery is also known as CSRF, XSRF, one-click attack, session riding, confused deputy, and sea surf.

CSRF attacks are effective in a number of situations, including:
    * The victim has an active session on the target site.
    * The victim is authenticated via HTTP auth on the target site.
    * The victim is on the same local network as the target site.

CSRF has primarily been used to perform an action against a target site using the victim's privileges, but recent techniques have been discovered to disclose information by gaining access to the response. The risk of information disclosure is dramatically increased when the target site is vulnerable to XSS, because XSS can be used as a platform for CSRF, allowing the attack to operate within the bounds of the same-origin policy.

* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form action="#" method="POST" style="display:none;">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "Change" "password_conf" "password_new" "step" ].`
* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form name="csp" method="POST">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "include" ].`
* URL: http://172.18.0.4/vulnerabilities/exec/
  * Node Name: `http://172.18.0.4/vulnerabilities/exec/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form name="ping" action="#" method="post">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "ip" "Submit" ].`
* URL: http://172.18.0.4/vulnerabilities/upload/
  * Node Name: `http://172.18.0.4/vulnerabilities/upload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form enctype="multipart/form-data" action="#" method="POST">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "MAX_FILE_SIZE" "Upload" "uploaded" ].`
* URL: http://172.18.0.4/vulnerabilities/weak_id/
  * Node Name: `http://172.18.0.4/vulnerabilities/weak_id/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form method="post">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "" ].`

Instances: Systemic


### Solution

Phase: Architecture and Design
Use a vetted library or framework that does not allow this weakness to occur or provides constructs that make this weakness easier to avoid.
For example, use anti-CSRF packages such as the OWASP CSRFGuard.

Phase: Implementation
Ensure that your application is free of cross-site scripting issues, because most CSRF defenses can be bypassed using attacker-controlled script.

Phase: Architecture and Design
Generate a unique nonce for each form, place the nonce into the form, and verify the nonce upon receipt of the form. Be sure that the nonce is not predictable (CWE-330).
Note that this can be bypassed using XSS.

Identify especially dangerous operations. When the user performs a dangerous operation, send a separate confirmation request to ensure that the user intended to perform that operation.
Note that this can be bypassed using XSS.

Use the ESAPI Session Management control.
This control includes a component for CSRF.

Do not use the GET method for any request that triggers a state change.

Phase: Implementation
Check the HTTP Referer header to see if the request originated from an expected page. This could break legitimate functionality, because users or proxies may have disabled sending the Referer for privacy reasons.

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
* [ https://cwe.mitre.org/data/definitions/352.html ](https://cwe.mitre.org/data/definitions/352.html)


#### CWE Id: [ 352 ](https://cwe.mitre.org/data/definitions/352.html)


#### WASC Id: 9

#### Source ID: 3

### [ CSP: Failure to Define Directive with No Fallback ](https://www.zaproxy.org/docs/alerts/10055/)



##### Medium (High)

### Description

The Content Security Policy fails to define one of the directives that has no fallback. Missing/excluding them is the same as allowing anything.

* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The directive(s): frame-ancestors, form-action is/are among the directives that do not fallback to default-src.`
* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/ ()(include)`
  * Method: `POST`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The directive(s): frame-ancestors, form-action is/are among the directives that do not fallback to default-src.`


Instances: 2

### Solution

Ensure that your web server, application server, load balancer, etc. is properly configured to set the Content-Security-Policy header.

### Reference


* [ https://www.w3.org/TR/CSP/ ](https://www.w3.org/TR/CSP/)
* [ https://caniuse.com/#search=content+security+policy ](https://caniuse.com/#search=content+security+policy)
* [ https://content-security-policy.com/ ](https://content-security-policy.com/)
* [ https://github.com/HtmlUnit/htmlunit-csp ](https://github.com/HtmlUnit/htmlunit-csp)
* [ https://web.dev/articles/csp#resource-options ](https://web.dev/articles/csp#resource-options)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ CSP: Wildcard Directive ](https://www.zaproxy.org/docs/alerts/10055/)



##### Medium (High)

### Description

Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks. Including (but not limited to) Cross Site Scripting (XSS), and data injection attacks. These attacks are used for everything from data theft to site defacement or distribution of malware. CSP provides a set of standard HTTP headers that allow website owners to declare approved sources of content that browsers should be allowed to load on that page — covered types are JavaScript, CSS, HTML frames, fonts, images and embeddable objects such as Java applets, ActiveX, audio and video files.

* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The following directives either allow wildcard sources (or ancestors), are not defined, or are overly broadly defined:
style-src, img-src, connect-src, frame-src, font-src, media-src, object-src, manifest-src`
* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/ ()(include)`
  * Method: `POST`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The following directives either allow wildcard sources (or ancestors), are not defined, or are overly broadly defined:
style-src, img-src, connect-src, frame-src, font-src, media-src, object-src, manifest-src`


Instances: 2

### Solution

Ensure that your web server, application server, load balancer, etc. is properly configured to set the Content-Security-Policy header.

### Reference


* [ https://www.w3.org/TR/CSP/ ](https://www.w3.org/TR/CSP/)
* [ https://caniuse.com/#search=content+security+policy ](https://caniuse.com/#search=content+security+policy)
* [ https://content-security-policy.com/ ](https://content-security-policy.com/)
* [ https://github.com/HtmlUnit/htmlunit-csp ](https://github.com/HtmlUnit/htmlunit-csp)
* [ https://web.dev/articles/csp#resource-options ](https://web.dev/articles/csp#resource-options)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ CSP: style-src unsafe-inline ](https://www.zaproxy.org/docs/alerts/10055/)



##### Medium (High)

### Description

Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks. Including (but not limited to) Cross Site Scripting (XSS), and data injection attacks. These attacks are used for everything from data theft to site defacement or distribution of malware. CSP provides a set of standard HTTP headers that allow website owners to declare approved sources of content that browsers should be allowed to load on that page — covered types are JavaScript, CSS, HTML frames, fonts, images and embeddable objects such as Java applets, ActiveX, audio and video files.

* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `style-src includes unsafe-inline.`
* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/ ()(include)`
  * Method: `POST`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `style-src includes unsafe-inline.`


Instances: 2

### Solution

Ensure that your web server, application server, load balancer, etc. is properly configured to set the Content-Security-Policy header.

### Reference


* [ https://www.w3.org/TR/CSP/ ](https://www.w3.org/TR/CSP/)
* [ https://caniuse.com/#search=content+security+policy ](https://caniuse.com/#search=content+security+policy)
* [ https://content-security-policy.com/ ](https://content-security-policy.com/)
* [ https://github.com/HtmlUnit/htmlunit-csp ](https://github.com/HtmlUnit/htmlunit-csp)
* [ https://web.dev/articles/csp#resource-options ](https://web.dev/articles/csp#resource-options)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ Content Security Policy (CSP) Header Not Set ](https://www.zaproxy.org/docs/alerts/10038/)



##### Medium (High)

### Description

Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks, including Cross Site Scripting (XSS) and data injection attacks. These attacks are used for everything from data theft to site defacement or distribution of malware. CSP provides a set of standard HTTP headers that allow website owners to declare approved sources of content that browsers should be allowed to load on that page — covered types are JavaScript, CSS, HTML frames, fonts, images and embeddable objects such as Java applets, ActiveX, audio and video files.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/sitemap.xml
  * Node Name: `http://172.18.0.4/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/brute/
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that your web server, application server, load balancer, etc. is configured to set the Content-Security-Policy header.

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP)
* [ https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
* [ https://www.w3.org/TR/CSP/ ](https://www.w3.org/TR/CSP/)
* [ https://w3c.github.io/webappsec-csp/ ](https://w3c.github.io/webappsec-csp/)
* [ https://web.dev/articles/csp ](https://web.dev/articles/csp)
* [ https://caniuse.com/#feat=contentsecuritypolicy ](https://caniuse.com/#feat=contentsecuritypolicy)
* [ https://content-security-policy.com/ ](https://content-security-policy.com/)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ Missing Anti-clickjacking Header ](https://www.zaproxy.org/docs/alerts/10020/)



##### Medium (Medium)

### Description

The response does not protect against 'ClickJacking' attacks. It should include either Content-Security-Policy with 'frame-ancestors' directive or X-Frame-Options.

* URL: http://172.18.0.4
  * Node Name: `http://172.18.0.4`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/exec/
  * Node Name: `http://172.18.0.4/vulnerabilities/exec/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


### Solution

Modern Web browsers support the Content-Security-Policy and X-Frame-Options HTTP headers. Ensure one of them is set on all web pages returned by your site/app.
If you expect the page to be framed only by pages on your server (e.g. it's part of a FRAMESET) then you'll want to use SAMEORIGIN, otherwise if you never expect the page to be framed, you should use DENY. Alternatively consider implementing Content Security Policy's "frame-ancestors" directive.

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-Frame-Options ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/X-Frame-Options)


#### CWE Id: [ 1021 ](https://cwe.mitre.org/data/definitions/1021.html)


#### WASC Id: 15

#### Source ID: 3

### [ Source Code Disclosure - SQL ](https://www.zaproxy.org/docs/alerts/10099/)



##### Medium (Medium)

### Description

Application Source Code was disclosed by the web server. - SQL

* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `create database dvwa`
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php%3Fdoc=readme
  * Node Name: `http://172.18.0.4/instructions.php (doc)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `create database dvwa`
  * Other Info: ``


Instances: 2

### Solution

Ensure that application Source Code is not available with alternative extensions, and ensure that source code is not present within other files or data deployed to the web server, or served by the web server.

### Reference


* [ https://nhimg.org/twitter-breach ](https://nhimg.org/twitter-breach)


#### CWE Id: [ 540 ](https://cwe.mitre.org/data/definitions/540.html)


#### WASC Id: 13

#### Source ID: 3

### [ Sub Resource Integrity Attribute Missing ](https://www.zaproxy.org/docs/alerts/90003/)



##### Medium (High)

### Description

The integrity attribute is missing on a script or link tag served by an external server. The integrity tag prevents an attacker who have gained access to this server from injecting a malicious content.

* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/ ()(Change,password_conf,password_new,step)`
  * Method: `POST`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``


Instances: 2

### Solution

Provide a valid integrity attribute to the tag.

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity ](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)


#### CWE Id: [ 345 ](https://cwe.mitre.org/data/definitions/345.html)


#### WASC Id: 15

#### Source ID: 3

### [ Cookie No HttpOnly Flag ](https://www.zaproxy.org/docs/alerts/10010/)



##### Low (Medium)

### Description

A cookie has been set without the HttpOnly flag, which means that the cookie can be accessed by JavaScript. If a malicious script can be run on this page then the cookie will be accessible and can be transmitted to another site. If this is a session cookie then session hijacking may be possible.

* URL: http://172.18.0.4/vulnerabilities/weak_id/
  * Node Name: `http://172.18.0.4/vulnerabilities/weak_id/`
  * Method: `POST`
  * Parameter: `dvwaSession`
  * Attack: ``
  * Evidence: `Set-Cookie: dvwaSession`
  * Other Info: ``


Instances: 1

### Solution

Ensure that the HttpOnly flag is set for all cookies.

### Reference


* [ https://owasp.org/www-community/HttpOnly ](https://owasp.org/www-community/HttpOnly)


#### CWE Id: [ 1004 ](https://cwe.mitre.org/data/definitions/1004.html)


#### WASC Id: 13

#### Source ID: 3

### [ Cookie without SameSite Attribute ](https://www.zaproxy.org/docs/alerts/10054/)



##### Low (Medium)

### Description

A cookie has been set without the SameSite attribute, which means that the cookie can be sent as a result of a 'cross-site' request. The SameSite attribute is an effective counter measure to cross-site request forgery, cross-site script inclusion, and timing attacks.

* URL: http://172.18.0.4/vulnerabilities/weak_id/
  * Node Name: `http://172.18.0.4/vulnerabilities/weak_id/`
  * Method: `POST`
  * Parameter: `dvwaSession`
  * Attack: ``
  * Evidence: `Set-Cookie: dvwaSession`
  * Other Info: ``


Instances: 1

### Solution

Ensure that the SameSite attribute is set to either 'lax' or ideally 'strict' for all cookies.

### Reference


* [ https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-cookie-same-site ](https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-cookie-same-site)


#### CWE Id: [ 1275 ](https://cwe.mitre.org/data/definitions/1275.html)


#### WASC Id: 13

#### Source ID: 3

### [ Cross-Domain JavaScript Source File Inclusion ](https://www.zaproxy.org/docs/alerts/10017/)



##### Low (Medium)

### Description

The page includes one or more script files from a third-party domain.

* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: `https://www.google.com/recaptcha/api.js`
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/ ()(Change,password_conf,password_new,step)`
  * Method: `POST`
  * Parameter: `https://www.google.com/recaptcha/api.js`
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``


Instances: 2

### Solution

Ensure JavaScript source files are loaded from only trusted sources, and the sources can't be controlled by end users of the application.

### Reference



#### CWE Id: [ 829 ](https://cwe.mitre.org/data/definitions/829.html)


#### WASC Id: 15

#### Source ID: 3

### [ Cross-Origin-Embedder-Policy Header Missing or Invalid ](https://www.zaproxy.org/docs/alerts/90004/)



##### Low (Medium)

### Description

Cross-Origin-Embedder-Policy header is a response header that prevents a document from loading any cross-origin resources that don't explicitly grant the document permission (using CORP or CORS).

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 4

### Solution

Ensure that the application/web server sets the Cross-Origin-Embedder-Policy header appropriately, and that it sets the Cross-Origin-Embedder-Policy header to 'require-corp' for documents.
If possible, ensure that the end user uses a standards-compliant and modern web browser that supports the Cross-Origin-Embedder-Policy header (https://caniuse.com/mdn-http_headers_cross-origin-embedder-policy).

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 14

#### Source ID: 3

### [ Cross-Origin-Opener-Policy Header Missing or Invalid ](https://www.zaproxy.org/docs/alerts/90004/)



##### Low (Medium)

### Description

Cross-Origin-Opener-Policy header is a response header that allows a site to control if others included documents share the same browsing context. Sharing the same browsing context with untrusted documents might lead to data leak.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 4

### Solution

Ensure that the application/web server sets the Cross-Origin-Opener-Policy header appropriately, and that it sets the Cross-Origin-Opener-Policy header to 'same-origin' for documents.
'same-origin-allow-popups' is considered as less secured and should be avoided.
If possible, ensure that the end user uses a standards-compliant and modern web browser that supports the Cross-Origin-Opener-Policy header (https://caniuse.com/mdn-http_headers_cross-origin-opener-policy).

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Opener-Policy ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Opener-Policy)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 14

#### Source ID: 3

### [ Cross-Origin-Resource-Policy Header Missing or Invalid ](https://www.zaproxy.org/docs/alerts/90004/)



##### Low (Medium)

### Description

Cross-Origin-Resource-Policy header is an opt-in header designed to counter side-channels attacks like Spectre. Resource should be specifically set as shareable amongst different origins.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/robots.txt
  * Node Name: `http://172.18.0.4/robots.txt`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 5

### Solution

Ensure that the application/web server sets the Cross-Origin-Resource-Policy header appropriately, and that it sets the Cross-Origin-Resource-Policy header to 'same-origin' for all web pages.
'same-site' is considered as less secured and should be avoided.
If resources must be shared, set the header to 'cross-origin'.
If possible, ensure that the end user uses a standards-compliant and modern web browser that supports the Cross-Origin-Resource-Policy header (https://caniuse.com/mdn-http_headers_cross-origin-resource-policy).

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cross-Origin-Embedder-Policy)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 14

#### Source ID: 3

### [ Dangerous JS Functions ](https://www.zaproxy.org/docs/alerts/10110/)



##### Low (Low)

### Description

A dangerous JS function seems to be in use that would leave the site vulnerable.

* URL: http://172.18.0.4/dvwa/js/dvwaPage.js
  * Node Name: `http://172.18.0.4/dvwa/js/dvwaPage.js`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `eval(`
  * Other Info: ``


Instances: 1

### Solution

See the references for security advice on the use of these functions.

### Reference


* [ https://v17.angular.io/guide/security ](https://v17.angular.io/guide/security)


#### CWE Id: [ 749 ](https://cwe.mitre.org/data/definitions/749.html)


#### Source ID: 3

### [ In Page Banner Information Leak ](https://www.zaproxy.org/docs/alerts/10009/)



##### Low (High)

### Description

The server returned a version banner string in the response content. Such information leaks may allow attackers to further target specific issues impacting the product and version in use.

* URL: http://172.18.0.4/DTD/xhtml1-transitional.dtd
  * Node Name: `http://172.18.0.4/DTD/xhtml1-transitional.dtd`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: http://172.18.0.4/sitemap.xml
  * Node Name: `http://172.18.0.4/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: http://172.18.0.4/vulnerabilities/csp/ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/ZAP`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`


Instances: 3

### Solution

Configure the server to prevent such information leaks. For example:
Under Tomcat this is done via the "server" directive and implementation of custom error pages.
Under Apache this is done via the "ServerSignature" and "ServerTokens" directives.

### Reference


* [ https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/08-Testing_for_Error_Handling/ ](https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/08-Testing_for_Error_Handling/)


#### CWE Id: [ 497 ](https://cwe.mitre.org/data/definitions/497.html)


#### WASC Id: 13

#### Source ID: 3

### [ Information Disclosure - Debug Error Messages ](https://www.zaproxy.org/docs/alerts/10023/)



##### Low (Medium)

### Description

The response appeared to contain common error messages returned by platforms such as ASP.NET, and Web-servers such as IIS and Apache. You can configure the list of common debug messages.

* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `PHP warning`
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php%3Fdoc=readme
  * Node Name: `http://172.18.0.4/instructions.php (doc)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `PHP warning`
  * Other Info: ``


Instances: 2

### Solution

Disable debugging messages before pushing to production.

### Reference



#### CWE Id: [ 1295 ](https://cwe.mitre.org/data/definitions/1295.html)


#### WASC Id: 13

#### Source ID: 3

### [ Permissions Policy Header Not Set ](https://www.zaproxy.org/docs/alerts/10063/)



##### Low (Medium)

### Description

Permissions Policy Header is an added layer of security that helps to restrict from unauthorized access or usage of browser/client features by web resources. This policy ensures the user privacy by limiting or specifying the features of the browsers can be used by the web resources. Permissions Policy provides a set of standard HTTP headers that allow website owners to limit which features of browsers can be used by the page such as camera, microphone, location, full screen etc.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/sitemap.xml
  * Node Name: `http://172.18.0.4/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that your web server, application server, load balancer, etc. is configured to set the Permissions-Policy header.

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Permissions-Policy ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Permissions-Policy)
* [ https://developer.chrome.com/blog/feature-policy/ ](https://developer.chrome.com/blog/feature-policy/)
* [ https://scotthelme.co.uk/a-new-security-header-feature-policy/ ](https://scotthelme.co.uk/a-new-security-header-feature-policy/)
* [ https://w3c.github.io/webappsec-feature-policy/ ](https://w3c.github.io/webappsec-feature-policy/)
* [ https://www.smashingmagazine.com/2018/12/feature-policy/ ](https://www.smashingmagazine.com/2018/12/feature-policy/)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ Private IP Disclosure ](https://www.zaproxy.org/docs/alerts/2/)



##### Low (Medium)

### Description

A private IP (such as 10.x.x.x, 172.x.x.x, 192.168.x.x) or an Amazon EC2 private hostname (for example, ip-10-0-56-78) has been found in the HTTP response body. This information might be helpful for further attacks targeting internal systems.

* URL: http://172.18.0.4/phpinfo.php
  * Node Name: `http://172.18.0.4/phpinfo.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `172.18.0.11`
  * Other Info: `172.18.0.11
172.18.0.11
`
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=file3.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `172.18.0.11`
  * Other Info: `172.18.0.11
`


Instances: 2

### Solution

Remove the private IP address from the HTTP response body. For comments, use JSP/ASP/PHP comment instead of HTML/JavaScript comment which can be seen by client browsers.

### Reference


* [ https://datatracker.ietf.org/doc/html/rfc1918 ](https://datatracker.ietf.org/doc/html/rfc1918)


#### CWE Id: [ 497 ](https://cwe.mitre.org/data/definitions/497.html)


#### WASC Id: 13

#### Source ID: 3

### [ Server Leaks Version Information via "Server" HTTP Response Header Field ](https://www.zaproxy.org/docs/alerts/10036/)



##### Low (High)

### Description

The web/application server is leaking version information via the "Server" HTTP response header. Access to such information may facilitate attackers identifying other vulnerabilities your web/application server is subject to.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: http://172.18.0.4/robots.txt
  * Node Name: `http://172.18.0.4/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: http://172.18.0.4/sitemap.xml
  * Node Name: `http://172.18.0.4/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that your web server, application server, load balancer, etc. is configured to suppress the "Server" header or provide generic details.

### Reference


* [ https://httpd.apache.org/docs/current/mod/core.html#servertokens ](https://httpd.apache.org/docs/current/mod/core.html#servertokens)
* [ https://learn.microsoft.com/en-us/previous-versions/msp-n-p/ff648552(v=pandp.10) ](https://learn.microsoft.com/en-us/previous-versions/msp-n-p/ff648552(v=pandp.10))
* [ https://www.troyhunt.com/shhh-dont-let-your-response-headers/ ](https://www.troyhunt.com/shhh-dont-let-your-response-headers/)


#### CWE Id: [ 497 ](https://cwe.mitre.org/data/definitions/497.html)


#### WASC Id: 13

#### Source ID: 3

### [ Timestamp Disclosure - Unix ](https://www.zaproxy.org/docs/alerts/10096/)



##### Low (Low)

### Description

A timestamp was disclosed by the application/web server. - Unix

* URL: http://172.18.0.4/phpinfo.php
  * Node Name: `http://172.18.0.4/phpinfo.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1784328422`
  * Other Info: `1784328422, which evaluates to: 2026-07-17 22:47:02.`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1473231341`
  * Other Info: `1473231341, which evaluates to: 2016-09-07 06:55:41.`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1732584193`
  * Other Info: `1732584193, which evaluates to: 2024-11-26 01:23:13.`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1732584194`
  * Other Info: `1732584194, which evaluates to: 2024-11-26 01:23:14.`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1770035416`
  * Other Info: `1770035416, which evaluates to: 2026-02-02 12:30:16.`

Instances: Systemic


### Solution

Manually confirm that the timestamp data is not sensitive, and that the data cannot be aggregated to disclose exploitable patterns.

### Reference


* [ https://cwe.mitre.org/data/definitions/200.html ](https://cwe.mitre.org/data/definitions/200.html)


#### CWE Id: [ 497 ](https://cwe.mitre.org/data/definitions/497.html)


#### WASC Id: 13

#### Source ID: 3

### [ X-Content-Type-Options Header Missing ](https://www.zaproxy.org/docs/alerts/10021/)



##### Low (Medium)

### Description

The Anti-MIME-Sniffing header X-Content-Type-Options was not set to 'nosniff'. This allows older versions of Internet Explorer and Chrome to perform MIME-sniffing on the response body, potentially causing the response body to be interpreted and displayed as a content type other than the declared content type. Current (early 2014) and legacy versions of Firefox will use the declared content type (if one is set), rather than performing MIME-sniffing.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: http://172.18.0.4/robots.txt
  * Node Name: `http://172.18.0.4/robots.txt`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`

Instances: Systemic


### Solution

Ensure that the application/web server sets the Content-Type header appropriately, and that it sets the X-Content-Type-Options header to 'nosniff' for all web pages.
If possible, ensure that the end user uses a standards-compliant and modern web browser that does not perform MIME-sniffing at all, or that can be directed by the web application/web server to not perform MIME-sniffing.

### Reference


* [ https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/compatibility/gg622941(v=vs.85) ](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/compatibility/gg622941(v=vs.85))
* [ https://owasp.org/www-community/Security_Headers ](https://owasp.org/www-community/Security_Headers)


#### CWE Id: [ 693 ](https://cwe.mitre.org/data/definitions/693.html)


#### WASC Id: 15

#### Source ID: 3

### [ Authentication Request Identified ](https://www.zaproxy.org/docs/alerts/10111/)



##### Informational (High)

### Description

The given request has been identified as an authentication request. The 'Other Info' field contains a set of key=value lines which identify any relevant fields. If the request is in a context which has an Authentication Method set to "Auto-Detect" then this rule will change the authentication to match the request identified.

* URL: http://172.18.0.4/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `Login`
  * Attack: ``
  * Evidence: `password`
  * Other Info: `userParam=Login
userValue=Login
passwordParam=password
referer=http://172.18.0.4/vulnerabilities/brute/`


Instances: 1

### Solution

This is an informational alert rather than a vulnerability and so there is nothing to fix.

### Reference


* [ https://www.zaproxy.org/docs/desktop/addons/authentication-helper/auth-req-id/ ](https://www.zaproxy.org/docs/desktop/addons/authentication-helper/auth-req-id/)



#### Source ID: 3

### [ Information Disclosure - Sensitive Information in URL ](https://www.zaproxy.org/docs/alerts/10024/)



##### Informational (Medium)

### Description

The request appeared to contain sensitive information leaked in the URL. This can violate PCI and most organizational compliance policies. You can configure the list of strings for this check to add or remove values specific to your environment.

* URL: http://172.18.0.4/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `password`
  * Attack: ``
  * Evidence: `password`
  * Other Info: `The URL contains potentially sensitive information. The following string was found via the pattern: pass
password`
* URL: http://172.18.0.4/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `username`
  * Attack: ``
  * Evidence: `username`
  * Other Info: `The URL contains potentially sensitive information. The following string was found via the pattern: user
username`


Instances: 2

### Solution

Do not pass sensitive information in URIs.

### Reference



#### CWE Id: [ 598 ](https://cwe.mitre.org/data/definitions/598.html)


#### WASC Id: 13

#### Source ID: 3

### [ Information Disclosure - Suspicious Comments ](https://www.zaproxy.org/docs/alerts/10027/)



##### Informational (Medium)

### Description

The response appears to contain suspicious comments which may help an attacker.

* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `/*
MD5 code from here
https://github`
  * Other Info: `The following pattern was used: \bFROM\b and was detected in likely comment: "/*
MD5 code from here
https://github.com/blueimp/JavaScript-MD5
*/", see evidence field for the suspicious comment/snippet.`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/ ()(phrase,send,token)`
  * Method: `POST`
  * Parameter: ``
  * Attack: ``
  * Evidence: `/*
MD5 code from here
https://github`
  * Other Info: `The following pattern was used: \bFROM\b and was detected in likely comment: "/*
MD5 code from here
https://github.com/blueimp/JavaScript-MD5
*/", see evidence field for the suspicious comment/snippet.`


Instances: 2

### Solution

Remove all comments that return information that may help an attacker and fix any underlying problems they refer to.

### Reference



#### CWE Id: [ 615 ](https://cwe.mitre.org/data/definitions/615.html)


#### WASC Id: 13

#### Source ID: 3

### [ Modern Web Application ](https://www.zaproxy.org/docs/alerts/10109/)



##### Informational (Medium)

### Description

The application appears to be a modern web application. If you need to explore it automatically then the Client Spider may well be more effective than the standard one.

* URL: http://172.18.0.4/phpinfo.php
  * Node Name: `http://172.18.0.4/phpinfo.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a name="module_apache2handler">apache2handler</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`


Instances: 1

### Solution

This is an informational alert and so no changes are required.

### Reference




#### Source ID: 3

### [ Storable and Cacheable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are storable by caching components such as proxy servers, and may be retrieved directly from the cache, rather than from the origin server by the caching servers, in response to similar requests from other users. If the response data is sensitive, personal or user-specific, this may result in sensitive information being leaked. In some cases, this may even result in a user gaining complete control of the session of another user, depending on the configuration of the caching components in use in their environment. This is primarily an issue where "shared" caching servers such as "proxy" caches are configured on the local network. This configuration is typically found in corporate or educational environments, for instance.

* URL: http://172.18.0.4/favicon.ico
  * Node Name: `http://172.18.0.4/favicon.ico`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: http://172.18.0.4/robots.txt
  * Node Name: `http://172.18.0.4/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: http://172.18.0.4/sitemap.xml
  * Node Name: `http://172.18.0.4/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`


Instances: 3

### Solution

Validate that the response does not contain sensitive, personal or user-specific information. If it does, consider the use of the following HTTP response headers, to limit, or prevent the content being stored and retrieved from the cache by another user:
Cache-Control: no-cache, no-store, must-revalidate, private
Pragma: no-cache
Expires: 0
This configuration directs both HTTP 1.0 and HTTP 1.1 compliant caching servers to not store the response, and to not retrieve the response (without validation) from the cache, in response to a similar request.

### Reference


* [ https://datatracker.ietf.org/doc/html/rfc7234 ](https://datatracker.ietf.org/doc/html/rfc7234)
* [ https://datatracker.ietf.org/doc/html/rfc7231 ](https://datatracker.ietf.org/doc/html/rfc7231)
* [ https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html ](https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)


#### CWE Id: [ 524 ](https://cwe.mitre.org/data/definitions/524.html)


#### WASC Id: 13

#### Source ID: 3

### [ Storable but Non-Cacheable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are storable by caching components such as proxy servers, but will not be retrieved directly from the cache, without validating the request upstream, in response to similar requests from other users.

* URL: http://172.18.0.4:80/
  * Node Name: `http://172.18.0.4/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: http://172.18.0.4/instructions.php
  * Node Name: `http://172.18.0.4/instructions.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/brute/
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `http://172.18.0.4/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: http://172.18.0.4/vulnerabilities/sqli_blind/
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``

Instances: Systemic


### Solution



### Reference


* [ https://datatracker.ietf.org/doc/html/rfc7234 ](https://datatracker.ietf.org/doc/html/rfc7234)
* [ https://datatracker.ietf.org/doc/html/rfc7231 ](https://datatracker.ietf.org/doc/html/rfc7231)
* [ https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html ](https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)


#### CWE Id: [ 524 ](https://cwe.mitre.org/data/definitions/524.html)


#### WASC Id: 13

#### Source ID: 3

### [ User Controllable HTML Element Attribute (Potential XSS) ](https://www.zaproxy.org/docs/alerts/10031/)



##### Informational (Low)

### Description

This check looks at user-supplied input in query string parameters and POST data to identify where certain HTML attribute values might be controlled. This provides hot-spot detection for XSS (cross-site scripting) that will require further review by a security analyst to determine exploitability.

* URL: http://172.18.0.4/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `Login`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/brute/?Login=Login&password=ZAP&username=ZAP

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
Login=Login

The user-controlled value was:
login`
* URL: http://172.18.0.4/vulnerabilities/sqli/%3FSubmit=Submit&id=ZAP
  * Node Name: `http://172.18.0.4/vulnerabilities/sqli/ (Submit,id)`
  * Method: `GET`
  * Parameter: `Submit`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/sqli/?Submit=Submit&id=ZAP

appears to include user input in:
a(n) [input] tag [type] attribute

The user input found was:
Submit=Submit

The user-controlled value was:
submit`
* URL: http://172.18.0.4/vulnerabilities/captcha/
  * Node Name: `http://172.18.0.4/vulnerabilities/captcha/ ()(Change,password_conf,password_new,step)`
  * Method: `POST`
  * Parameter: `Change`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/captcha/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
Change=Change

The user-controlled value was:
change`
* URL: http://172.18.0.4/vulnerabilities/csp/
  * Node Name: `http://172.18.0.4/vulnerabilities/csp/ ()(include)`
  * Method: `POST`
  * Parameter: `include`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/csp/

appears to include user input in:
a(n) [script] tag [src] attribute

The user input found was:
include=ZAP

The user-controlled value was:
zap`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/ ()(phrase,send,token)`
  * Method: `POST`
  * Parameter: `phrase`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/javascript/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
phrase=ChangeMe

The user-controlled value was:
changeme`
* URL: http://172.18.0.4/vulnerabilities/javascript/
  * Node Name: `http://172.18.0.4/vulnerabilities/javascript/ ()(phrase,send,token)`
  * Method: `POST`
  * Parameter: `send`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/javascript/

appears to include user input in:
a(n) [input] tag [type] attribute

The user input found was:
send=Submit

The user-controlled value was:
submit`
* URL: http://172.18.0.4/vulnerabilities/xss_s/
  * Node Name: `http://172.18.0.4/vulnerabilities/xss_s/ ()(btnClear,mtxMessage,txtName)`
  * Method: `POST`
  * Parameter: `btnClear`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/xss_s/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
btnClear=Clear Guestbook

The user-controlled value was:
clear guestbook`
* URL: http://172.18.0.4/vulnerabilities/xss_s/
  * Node Name: `http://172.18.0.4/vulnerabilities/xss_s/ ()(btnSign,mtxMessage,txtName)`
  * Method: `POST`
  * Parameter: `btnSign`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

http://172.18.0.4/vulnerabilities/xss_s/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
btnSign=Sign Guestbook

The user-controlled value was:
sign guestbook`


Instances: 8

### Solution

Validate all input and sanitize output it before writing to any HTML attributes.

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)


#### CWE Id: [ 20 ](https://cwe.mitre.org/data/definitions/20.html)


#### WASC Id: 20

#### Source ID: 3


