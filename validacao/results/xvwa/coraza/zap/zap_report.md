# ZAP Scanning Report

ZAP by [Checkmarx](https://checkmarx.com/).


## Summary of Alerts

| Risk Level | Number of Alerts |
| --- | --- |
| High | 1 |
| Medium | 7 |
| Low | 13 |
| Informational | 7 |




## Insights

| Level | Reason | Site | Description | Statistic |
| --- | --- | --- | --- | --- |
| Low | Warning |  | ZAP errors logged - see the zap.log file for details | 1    |
| Low | Warning |  | ZAP warnings logged - see the zap.log file for details | 1    |
| Low | Exceeded High | https://172.18.0.9 | Percentage of responses with status code 4xx | 51 % |
| Info | Informational | http://172.18.0.9 | Percentage of responses with status code 3xx | 100 % |
| Info | Informational | http://172.18.0.9:443 | Percentage of responses with status code 4xx | 100 % |
| Info | Informational | https://172.18.0.9 | Percentage of responses with status code 2xx | 33 % |
| Info | Informational | https://172.18.0.9 | Percentage of responses with status code 3xx | 22 % |
| Info | Informational | https://172.18.0.9 | Percentage of endpoints with content type text/html | 97 % |
| Info | Informational | https://172.18.0.9 | Percentage of endpoints with method GET | 100 % |
| Info | Informational | https://172.18.0.9 | Count of total endpoints | 35    |
| Info | Exceeded Low | https://172.18.0.9 | Percentage of slow responses | 13 % |







## Alerts

| Name | Risk Level | Number of Instances |
| --- | --- | --- |
| Remote File Inclusion | High | 1 |
| Absence of Anti-CSRF Tokens | Medium | Systemic |
| Bypassing 403 | Medium | 1 |
| Content Security Policy (CSP) Header Not Set | Medium | Systemic |
| Missing Anti-clickjacking Header | Medium | Systemic |
| Proxy Disclosure | Medium | Systemic |
| Relative Path Confusion | Medium | 1 |
| Sub Resource Integrity Attribute Missing | Medium | Systemic |
| Cookie No HttpOnly Flag | Low | Systemic |
| Cookie Without Secure Flag | Low | Systemic |
| Cookie without SameSite Attribute | Low | Systemic |
| Cross-Domain JavaScript Source File Inclusion | Low | Systemic |
| Cross-Origin-Embedder-Policy Header Missing or Invalid | Low | Systemic |
| Cross-Origin-Opener-Policy Header Missing or Invalid | Low | Systemic |
| Cross-Origin-Resource-Policy Header Missing or Invalid | Low | Systemic |
| In Page Banner Information Leak | Low | 3 |
| Permissions Policy Header Not Set | Low | Systemic |
| Server Leaks Information via "X-Powered-By" HTTP Response Header Field(s) | Low | Systemic |
| Server Leaks Version Information via "Server" HTTP Response Header Field | Low | Systemic |
| Strict-Transport-Security Header Not Set | Low | Systemic |
| X-Content-Type-Options Header Missing | Low | Systemic |
| Cookie Slack Detector | Informational | Systemic |
| Modern Web Application | Informational | Systemic |
| Non-Storable Content | Informational | Systemic |
| Session Management Response Identified | Informational | 26 |
| Storable and Cacheable Content | Informational | 2 |
| User Agent Fuzzer | Informational | Systemic |
| User Controllable HTML Element Attribute (Potential XSS) | Informational | 1 |




## Alert Detail



### [ Remote File Inclusion ](https://www.zaproxy.org/docs/alerts/7/)



##### High (Medium)

### Description

Remote File Include (RFI) is an attack technique used to exploit "dynamic file include" mechanisms in web applications. When web applications take user input (URL, parameter value, etc.) and pass them into file include commands, the web application might be tricked into including remote files with malicious code.

Almost all web application frameworks support file inclusion. File inclusion is mainly used for packaging common code into separate files that are later referenced by main application modules. When a web application references an include file, the code in this file may be executed implicitly or explicitly by calling specific procedures. If the choice of module to load is based on elements from the HTTP request, the web application might be vulnerable to RFI.
An attacker can use RFI for:
    * Running malicious code on the server: any code in the included malicious files will be run by the server. If the file include is not executed using some wrapper, code in include files is executed in the context of the server user. This could lead to a complete system compromise.
    * Running malicious code on clients: the attacker's malicious code can manipulate the content of the response sent to the client. The attacker can embed malicious code in the response that will be run by the client (for example, JavaScript to steal the client session cookies).

PHP is particularly vulnerable to RFI attacks due to the extensive use of "file includes" in PHP programming and due to default server configurations that increase susceptibility to an RFI attack.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/%3Ffile=http%253A%252F%252Fwww.google.com%252F
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/ (file)`
  * Method: `GET`
  * Parameter: `file`
  * Attack: `http://www.google.com/`
  * Evidence: `<title>Google</title>`
  * Other Info: ``


Instances: 1

### Solution

Phase: Architecture and Design
When the set of acceptable objects, such as filenames or URLs, is limited or known, create a mapping from a set of fixed input values (such as numeric IDs) to the actual filenames or URLs, and reject all other inputs.
For example, ID 1 could map to "inbox.txt" and ID 2 could map to "profile.txt". Features such as the ESAPI AccessReferenceMap provide this capability.

Phases: Architecture and Design; Operation
Run your code in a "jail" or similar sandbox environment that enforces strict boundaries between the process and the operating system. This may effectively restrict which files can be accessed in a particular directory or which commands can be executed by your software.
OS-level examples include the Unix chroot jail, AppArmor, and SELinux. In general, managed code may provide some protection. For example, java.io.FilePermission in the Java SecurityManager allows you to specify restrictions on file operations.
This may not be a feasible solution, and it only limits the impact to the operating system; the rest of your application may still be subject to compromise.
Be careful to avoid CWE-243 and other weaknesses related to jails.
For PHP, the interpreter offers restrictions such as open basedir or safe mode which can make it more difficult for an attacker to escape out of the application. Also consider Suhosin, a hardened PHP extension, which includes various options that disable some of the more dangerous PHP features.

Phase: Implementation
Assume all input is malicious. Use an "accept known good" input validation strategy, i.e., use an allow list of acceptable inputs that strictly conform to specifications. Reject any input that does not strictly conform to specifications, or transform it into something that does. Do not rely exclusively on looking for malicious or malformed inputs (i.e., do not rely on a deny list). However, deny lists can be useful for detecting potential attacks or determining which inputs are so malformed that they should be rejected outright.
When performing input validation, consider all potentially relevant properties, including length, type of input, the full range of acceptable values, missing or extra inputs, syntax, consistency across related fields, and conformance to business rules. As an example of business rule logic, "boat" may be syntactically valid because it only contains alphanumeric characters, but it is not valid if you are expecting colors such as "red" or "blue."
For filenames, use stringent allow lists that limit the character set to be used. If feasible, only allow a single "." character in the filename to avoid weaknesses such as CWE-23, and exclude directory separators such as "/" to avoid CWE-36. Use an allow list of allowable file extensions, which will help to avoid CWE-434.

Phases: Architecture and Design; Operation
Store library, include, and utility files outside of the web document root, if possible. Otherwise, store them in a separate directory and use the web server's access control capabilities to prevent attackers from directly requesting them. One common practice is to define a fixed constant in each calling program, then check for the existence of the constant in the library/include file; if the constant does not exist, then the file was directly requested, and it can exit immediately.
This significantly reduces the chance of an attacker being able to bypass any protection mechanisms that are in the base program but not in the include files. It will also reduce your attack surface.

Phases: Architecture and Design; Implementation
Understand all the potential areas where untrusted inputs can enter your software: parameters or arguments, cookies, anything read from the network, environment variables, reverse DNS lookups, query results, request headers, URL components, e-mail, files, databases, and any external systems that provide data to the application. Remember that such inputs may be obtained indirectly through API calls.
Many file inclusion problems occur because the programmer assumed that certain inputs could not be modified, especially for cookies and URL components.

### Reference


* [ https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.2-Testing_for_Remote_File_Inclusion ](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/07-Input_Validation_Testing/11.2-Testing_for_Remote_File_Inclusion)
* [ https://cwe.mitre.org/data/definitions/98.html ](https://cwe.mitre.org/data/definitions/98.html)


#### CWE Id: [ 98 ](https://cwe.mitre.org/data/definitions/98.html)


#### WASC Id: 5

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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form method='post' action=''>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 2: "search" ].`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`

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

### [ Bypassing 403 ](https://www.zaproxy.org/docs/alerts/40038/)



##### Medium (Medium)

### Description

Bypassing 403 endpoints may be possible, the scan rule sent a payload that caused the response to be accessible (status code 200).

* URL: https://172.18.0.9:443/%252e/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/./xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `/%2e/xvwa/vulnerabilities/fi/`
  * Evidence: ``
  * Other Info: `https://172.18.0.9:443/xvwa/vulnerabilities/fi/?file=test.php`


Instances: 1

### Solution



### Reference


* [ https://www.acunetix.com/blog/articles/a-fresh-look-on-reverse-proxy-related-attacks/ ](https://www.acunetix.com/blog/articles/a-fresh-look-on-reverse-proxy-related-attacks/)
* [ https://i.blackhat.com/us-18/Wed-August-8/us-18-Orange-Tsai-Breaking-Parser-Logic-Take-Your-Path-Normalization-Off-And-Pop-0days-Out-2.pdf ](https://i.blackhat.com/us-18/Wed-August-8/us-18-Orange-Tsai-Breaking-Parser-Logic-Take-Your-Path-Normalization-Off-And-Pop-0days-Out-2.pdf)
* [ https://seclists.org/fulldisclosure/2011/Oct/273 ](https://seclists.org/fulldisclosure/2011/Oct/273)


#### CWE Id: [ 348 ](https://cwe.mitre.org/data/definitions/348.html)


#### Source ID: 1

### [ Content Security Policy (CSP) Header Not Set ](https://www.zaproxy.org/docs/alerts/10038/)



##### Medium (High)

### Description

Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks, including Cross Site Scripting (XSS) and data injection attacks. These attacks are used for everything from data theft to site defacement or distribution of malware. CSP provides a set of standard HTTP headers that allow website owners to declare approved sources of content that browsers should be allowed to load on that page — covered types are JavaScript, CSS, HTML frames, fonts, images and embeddable objects such as Java applets, ActiveX, audio and video files.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/reflected_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/reflected_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
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

* URL: https://172.18.0.9:443/xvwa/instruction.php
  * Node Name: `https://172.18.0.9/xvwa/instruction.php`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli_blind/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli_blind/`
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

### [ Proxy Disclosure ](https://www.zaproxy.org/docs/alerts/40025/)



##### Medium (Medium)

### Description

1 proxy server(s) were detected or fingerprinted. This information helps a potential attacker to determine
- A list of targets for an attack against the application.
 - Potential vulnerabilities on the proxy servers that service the application.
 - The presence or absence of any proxy-based components that might cause attacks against the application to be detected, prevented, or mitigated.

* URL: https://172.18.0.9:443/
  * Node Name: `https://172.18.0.9/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Apache/2.4.54 (Debian)
`
* URL: https://172.18.0.9/robots.txt
  * Node Name: `https://172.18.0.9/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Caddy
The following web/application server has been identified:
- Caddy
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Apache/2.4.54 (Debian)[PHP/7.4.33]
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/%3Ffile=test.php
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/ (file)`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sessionflaws/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sessionflaws/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Apache/2.4.54 (Debian)[PHP/7.4.33]
`

Instances: Systemic


### Solution

Disable the 'TRACE' method on the proxy servers, as well as the origin web/application server.
Disable the 'OPTIONS' method on the proxy servers, as well as the origin web/application server, if it is not required for other purposes, such as 'CORS' (Cross Origin Resource Sharing).
Configure the web and application servers with custom error pages, to prevent 'fingerprintable' product-specific error pages being leaked to the user in the event of HTTP errors, such as 'TRACK' requests for non-existent pages.
Configure all proxies, application servers, and web servers to prevent disclosure of the technology and version information in the 'Server' and 'X-Powered-By' HTTP response headers.


### Reference


* [ https://datatracker.ietf.org/doc/html/rfc7231#section-5.1.2 ](https://datatracker.ietf.org/doc/html/rfc7231#section-5.1.2)


#### CWE Id: [ 204 ](https://cwe.mitre.org/data/definitions/204.html)


#### WASC Id: 45

#### Source ID: 1

### [ Relative Path Confusion ](https://www.zaproxy.org/docs/alerts/10051/)



##### Medium (Medium)

### Description

The web server is configured to serve responses to ambiguous URLs in a manner that is likely to lead to confusion about the correct "relative path" for the URL. Resources (CSS, images, etc.) are also specified in the page response using relative, rather than absolute URLs. In an attack, if the web browser parses the "cross-content" response in a permissive manner, or can be tricked into permissively parsing the "cross-content" response, using techniques such as framing, then the web browser may be fooled into interpreting HTML as CSS (or other content types), leading to an XSS vulnerability.

* URL: https://172.18.0.9:443/xvwa/instruction.php
  * Node Name: `https://172.18.0.9/xvwa/instruction.php/w9vak/a9kj8`
  * Method: `GET`
  * Parameter: ``
  * Attack: `https://172.18.0.9:443/xvwa/instruction.php/w9vak/a9kj8`
  * Evidence: `<link href="css/bootstrap.min.css" rel="stylesheet">`
  * Other Info: `No <base> tag was specified in the HTML <head> tag to define the location for relative URLs.
A Content Type of "text/html; charset=UTF-8" was specified. If the web browser is employing strict parsing rules, this will prevent cross-content attacks from succeeding. Quirks Mode in the web browser would disable strict parsing.
No X-Frame-Options header was specified, so the page can be framed, and this can be used to enable Quirks Mode, allowing the specified Content Type to be bypassed.`


Instances: 1

### Solution

Web servers and frameworks should be updated to be configured to not serve responses to ambiguous URLs in such a way that the relative path of such URLs could be mis-interpreted by components on either the client side, or server side.
Within the application, the correct use of the "<base>" HTML tag in the HTTP response will unambiguously specify the base URL for all relative URLs in the document.
Use the "Content-Type" HTTP response header to make it harder for the attacker to force the web browser to mis-interpret the content type of the response.
Use the "X-Content-Type-Options: nosniff" HTTP response header to prevent the web browser from "sniffing" the content type of the response.
Use a modern DOCTYPE such as "<!doctype html>" to prevent the page from being rendered in the web browser using "Quirks Mode", since this results in the content type being ignored by the web browser.
Specify the "X-Frame-Options" HTTP response header to prevent Quirks Mode from being enabled in the web browser using framing attacks.

### Reference


* [ https://arxiv.org/abs/1811.00917 ](https://arxiv.org/abs/1811.00917)
* [ https://hsivonen.fi/doctype/ ](https://hsivonen.fi/doctype/)
* [ https://www.w3schools.com/tags/tag_base.asp ](https://www.w3schools.com/tags/tag_base.asp)


#### CWE Id: [ 20 ](https://cwe.mitre.org/data/definitions/20.html)


#### WASC Id: 20

#### Source ID: 1

### [ Sub Resource Integrity Attribute Missing ](https://www.zaproxy.org/docs/alerts/90003/)



##### Medium (High)

### Description

The integrity attribute is missing on a script or link tag served by an external server. The integrity tag prevents an attacker who have gained access to this server from injecting a malicious content.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>`
  * Other Info: ``

Instances: Systemic


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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that the HttpOnly flag is set for all cookies.

### Reference


* [ https://owasp.org/www-community/HttpOnly ](https://owasp.org/www-community/HttpOnly)


#### CWE Id: [ 1004 ](https://cwe.mitre.org/data/definitions/1004.html)


#### WASC Id: 13

#### Source ID: 3

### [ Cookie Without Secure Flag ](https://www.zaproxy.org/docs/alerts/10011/)



##### Low (Medium)

### Description

A cookie has been set without the secure flag, which means that the cookie can be accessed via unencrypted connections.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``

Instances: Systemic


### Solution

Whenever a cookie contains sensitive information or is a session token, then it should always be passed using an encrypted channel. Ensure that the secure flag is set for cookies containing such sensitive information.

### Reference


* [ https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/06-Session_Management_Testing/02-Testing_for_Cookies_Attributes.html ](https://owasp.org/www-project-web-security-testing-guide/v41/4-Web_Application_Security_Testing/06-Session_Management_Testing/02-Testing_for_Cookies_Attributes.html)


#### CWE Id: [ 614 ](https://cwe.mitre.org/data/definitions/614.html)


#### WASC Id: 13

#### Source ID: 3

### [ Cookie without SameSite Attribute ](https://www.zaproxy.org/docs/alerts/10054/)



##### Low (Medium)

### Description

A cookie has been set without the SameSite attribute, which means that the cookie can be sent as a result of a 'cross-site' request. The SameSite attribute is an effective counter measure to cross-site request forgery, cross-site script inclusion, and timing attacks.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/idor/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/idor/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `Set-Cookie: PHPSESSID`
  * Other Info: ``

Instances: Systemic


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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``

Instances: Systemic


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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/formula_injection/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/formula_injection/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/formula_injection/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/formula_injection/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


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

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/formula_injection/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/formula_injection/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


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

### [ In Page Banner Information Leak ](https://www.zaproxy.org/docs/alerts/10009/)



##### Low (High)

### Description

The server returned a version banner string in the response content. Such information leaks may allow attackers to further target specific issues impacting the product and version in use.

* URL: https://172.18.0.9:443/
  * Node Name: `https://172.18.0.9/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: https://172.18.0.9/robots.txt
  * Node Name: `https://172.18.0.9/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: https://172.18.0.9/sitemap.xml
  * Node Name: `https://172.18.0.9/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54`
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

### [ Permissions Policy Header Not Set ](https://www.zaproxy.org/docs/alerts/10063/)



##### Low (Medium)

### Description

Permissions Policy Header is an added layer of security that helps to restrict from unauthorized access or usage of browser/client features by web resources. This policy ensures the user privacy by limiting or specifying the features of the browsers can be used by the web resources. Permissions Policy provides a set of standard HTTP headers that allow website owners to limit which features of browsers can be used by the page such as camera, microphone, location, full screen etc.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
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

### [ Server Leaks Information via "X-Powered-By" HTTP Response Header Field(s) ](https://www.zaproxy.org/docs/alerts/10037/)



##### Low (Medium)

### Description

The web/application server is leaking information via one or more "X-Powered-By" HTTP response headers. Access to such information may facilitate attackers identifying other frameworks/components your web application is reliant upon and the vulnerabilities such components may be subject to.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `X-Powered-By: PHP/7.4.33`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `X-Powered-By: PHP/7.4.33`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `X-Powered-By: PHP/7.4.33`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `X-Powered-By: PHP/7.4.33`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `X-Powered-By: PHP/7.4.33`
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that your web server, application server, load balancer, etc. is configured to suppress "X-Powered-By" headers.

### Reference


* [ https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/08-Fingerprint_Web_Application_Framework ](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/08-Fingerprint_Web_Application_Framework)
* [ https://www.troyhunt.com/shhh-dont-let-your-response-headers/ ](https://www.troyhunt.com/shhh-dont-let-your-response-headers/)


#### CWE Id: [ 497 ](https://cwe.mitre.org/data/definitions/497.html)


#### WASC Id: 13

#### Source ID: 3

### [ Server Leaks Version Information via "Server" HTTP Response Header Field ](https://www.zaproxy.org/docs/alerts/10036/)



##### Low (High)

### Description

The web/application server is leaking version information via the "Server" HTTP response header. Access to such information may facilitate attackers identifying other vulnerabilities your web/application server is subject to.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54 (Debian)`
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

### [ Strict-Transport-Security Header Not Set ](https://www.zaproxy.org/docs/alerts/10035/)



##### Low (High)

### Description

HTTP Strict Transport Security (HSTS) is a web security policy mechanism whereby a web server declares that complying user agents (such as a web browser) are to interact with it using only secure HTTPS connections (i.e. HTTP layered over TLS/SSL). HSTS is an IETF standards track protocol and is specified in RFC 6797.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


### Solution

Ensure that your web server, application server, load balancer, etc. is configured to enforce Strict-Transport-Security.

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html)
* [ https://owasp.org/www-community/Security_Headers ](https://owasp.org/www-community/Security_Headers)
* [ https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security ](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)
* [ https://caniuse.com/stricttransportsecurity ](https://caniuse.com/stricttransportsecurity)
* [ https://datatracker.ietf.org/doc/html/rfc6797 ](https://datatracker.ietf.org/doc/html/rfc6797)


#### CWE Id: [ 319 ](https://cwe.mitre.org/data/definitions/319.html)


#### WASC Id: 15

#### Source ID: 3

### [ X-Content-Type-Options Header Missing ](https://www.zaproxy.org/docs/alerts/10021/)



##### Low (Medium)

### Description

The Anti-MIME-Sniffing header X-Content-Type-Options was not set to 'nosniff'. This allows older versions of Internet Explorer and Chrome to perform MIME-sniffing on the response body, potentially causing the response body to be interpreted and displayed as a content type other than the declared content type. Current (early 2014) and legacy versions of Firefox will use the declared content type (if one is set), rather than performing MIME-sniffing.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
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

### [ Cookie Slack Detector ](https://www.zaproxy.org/docs/alerts/90027/)



##### Informational (Low)

### Description

Repeated GET requests: drop a different cookie each time, followed by normal request with all cookies to stabilize session, compare responses against original baseline GET. This can reveal areas where cookie based authentication/attributes are not actually enforced.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/reflected_xss/%3Fitem=test
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/reflected_xss/ (item)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Cookies that don't have expected effects can reveal flaws in application logic. In the worst case, this can reveal where authentication via cookie token(s) is not actually enforced.
These cookies affected the response: 
These cookies did NOT affect the response: PHPSESSID
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sessionflaws/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sessionflaws/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Cookies that don't have expected effects can reveal flaws in application logic. In the worst case, this can reveal where authentication via cookie token(s) is not actually enforced.
These cookies affected the response: 
These cookies did NOT affect the response: PHPSESSID
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Cookies that don't have expected effects can reveal flaws in application logic. In the worst case, this can reveal where authentication via cookie token(s) is not actually enforced.
These cookies affected the response: 
These cookies did NOT affect the response: PHPSESSID
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/stored_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/stored_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Cookies that don't have expected effects can reveal flaws in application logic. In the worst case, this can reveal where authentication via cookie token(s) is not actually enforced.
These cookies affected the response: 
These cookies did NOT affect the response: PHPSESSID
`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Cookies that don't have expected effects can reveal flaws in application logic. In the worst case, this can reveal where authentication via cookie token(s) is not actually enforced.
These cookies affected the response: 
These cookies did NOT affect the response: PHPSESSID
`

Instances: Systemic


### Solution



### Reference


* [ https://cwe.mitre.org/data/definitions/205.html ](https://cwe.mitre.org/data/definitions/205.html)


#### CWE Id: [ 205 ](https://cwe.mitre.org/data/definitions/205.html)


#### WASC Id: 45

#### Source ID: 1

### [ Modern Web Application ](https://www.zaproxy.org/docs/alerts/10109/)



##### Informational (Medium)

### Description

The application appears to be a modern web application. If you need to explore it automatically then the Client Spider may well be more effective than the standard one.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`

Instances: Systemic


### Solution

This is an informational alert and so no changes are required.

### Reference




#### Source ID: 3

### [ Non-Storable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are not storable by caching components such as proxy servers. If the response does not contain sensitive, personal or user-specific information, it may benefit from being stored and cached, to improve performance.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``

Instances: Systemic


### Solution

The content may be marked as storable by ensuring that the following conditions are satisfied:
The request method must be understood by the cache and defined as being cacheable ("GET", "HEAD", and "POST" are currently defined as cacheable)
The response status code must be understood by the cache (one of the 1XX, 2XX, 3XX, 4XX, or 5XX response classes are generally understood)
The "no-store" cache directive must not appear in the request or response header fields
For caching by "shared" caches such as "proxy" caches, the "private" response directive must not appear in the response
For caching by "shared" caches such as "proxy" caches, the "Authorization" header field must not appear in the request, unless the response explicitly allows it (using one of the "must-revalidate", "public", or "s-maxage" Cache-Control response directives)
In addition to the conditions above, at least one of the following conditions must also be satisfied by the response:
It must contain an "Expires" header field
It must contain a "max-age" response directive
For "shared" caches such as "proxy" caches, it must contain a "s-maxage" response directive
It must contain a "Cache Control Extension" that allows it to be cached
It must have a status code that is defined as cacheable by default (200, 203, 204, 206, 300, 301, 404, 405, 410, 414, 501).

### Reference


* [ https://datatracker.ietf.org/doc/html/rfc7234 ](https://datatracker.ietf.org/doc/html/rfc7234)
* [ https://datatracker.ietf.org/doc/html/rfc7231 ](https://datatracker.ietf.org/doc/html/rfc7231)
* [ https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html ](https://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)


#### CWE Id: [ 524 ](https://cwe.mitre.org/data/definitions/524.html)


#### WASC Id: 13

#### Source ID: 3

### [ Session Management Response Identified ](https://www.zaproxy.org/docs/alerts/10112/)



##### Informational (Medium)

### Description

The given response has been identified as containing a session management token. The 'Other Info' field contains a set of header tokens that can be used in the Header Based Session Management Method. If the request is in a context which has a Session Management Method set to "Auto-Detect" then this rule will change the session management to use the tokens identified.

* URL: https://172.18.0.9/xvwa/
  * Node Name: `https://172.18.0.9/xvwa/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/instruction.php
  * Node Name: `https://172.18.0.9/xvwa/instruction.php`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/cmdi/%3Ftarget=127.0.0.1
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/cmdi/ (target)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/crypto/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/crypto/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/formula_injection/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/formula_injection/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/idor/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/idor/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/idor/%3Fitem=1
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/idor/ (item)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/missfunc/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/missfunc/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/php_object_injection/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/php_object_injection/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/php_object_injection/%3Fr=test
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/php_object_injection/ (r)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/redirect/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/redirect/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/redirect/%3Furl=http://example.com
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/redirect/ (url)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/reflected_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/reflected_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/reflected_xss/%3Fitem=test
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/reflected_xss/ (item)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sessionflaws/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sessionflaws/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/sqli_blind/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/ssti/%3Fname=test
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/ssti/ (name)`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/stored_xss/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/stored_xss/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`
* URL: https://172.18.0.9:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: `PHPSESSID`
  * Attack: ``
  * Evidence: `PHPSESSID`
  * Other Info: `cookie:PHPSESSID`


Instances: 26

### Solution

This is an informational alert rather than a vulnerability and so there is nothing to fix.

### Reference


* [ https://www.zaproxy.org/docs/desktop/addons/authentication-helper/session-mgmt-id/ ](https://www.zaproxy.org/docs/desktop/addons/authentication-helper/session-mgmt-id/)



#### Source ID: 3

### [ Storable and Cacheable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are storable by caching components such as proxy servers, and may be retrieved directly from the cache, rather than from the origin server by the caching servers, in response to similar requests from other users. If the response data is sensitive, personal or user-specific, this may result in sensitive information being leaked. In some cases, this may even result in a user gaining complete control of the session of another user, depending on the configuration of the caching components in use in their environment. This is primarily an issue where "shared" caching servers such as "proxy" caches are configured on the local network. This configuration is typically found in corporate or educational environments, for instance.

* URL: https://172.18.0.9/robots.txt
  * Node Name: `https://172.18.0.9/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: https://172.18.0.9/sitemap.xml
  * Node Name: `https://172.18.0.9/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`


Instances: 2

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

### [ User Agent Fuzzer ](https://www.zaproxy.org/docs/alerts/10104/)



##### Informational (Medium)

### Description

Check for differences in response based on fuzzed User Agent (eg. mobile sites, access as a Search Engine Crawler). Compares the response statuscode and the hashcode of the response body with the original response.

* URL: https://172.18.0.9/xvwa
  * Node Name: `https://172.18.0.9/xvwa`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9/xvwa
  * Node Name: `https://172.18.0.9/xvwa`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9/xvwa
  * Node Name: `https://172.18.0.9/xvwa`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9/xvwa/vulnerabilities
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.9/xvwa/vulnerabilities/cmdi
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/cmdi`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``

Instances: Systemic


### Solution



### Reference


* [ https://owasp.org/wstg ](https://owasp.org/wstg)



#### Source ID: 1

### [ User Controllable HTML Element Attribute (Potential XSS) ](https://www.zaproxy.org/docs/alerts/10031/)



##### Informational (Low)

### Description

This check looks at user-supplied input in query string parameters and POST data to identify where certain HTML attribute values might be controlled. This provides hot-spot detection for XSS (cross-site scripting) that will require further review by a security analyst to determine exploitability.

* URL: https://172.18.0.9:443/xvwa/vulnerabilities/idor/%3Fitem=1
  * Node Name: `https://172.18.0.9/xvwa/vulnerabilities/idor/ (item)`
  * Method: `GET`
  * Parameter: `item`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.9:443/xvwa/vulnerabilities/idor/?item=1

appears to include user input in:
a(n) [meta] tag [content] attribute

The user input found was:
item=1

The user-controlled value was:
width=device-width, initial-scale=1`


Instances: 1

### Solution

Validate all input and sanitize output it before writing to any HTML attributes.

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)


#### CWE Id: [ 20 ](https://cwe.mitre.org/data/definitions/20.html)


#### WASC Id: 20

#### Source ID: 3


