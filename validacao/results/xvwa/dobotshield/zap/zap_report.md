# ZAP Scanning Report

ZAP by [Checkmarx](https://checkmarx.com/).


## Summary of Alerts

| Risk Level | Number of Alerts |
| --- | --- |
| High | 2 |
| Medium | 5 |
| Low | 6 |
| Informational | 6 |




## Insights

| Level | Reason | Site | Description | Statistic |
| --- | --- | --- | --- | --- |
| Low | Warning |  | ZAP warnings logged - see the zap.log file for details | 1    |
| Low | Exceeded High | https://172.23.0.4 | Percentage of responses with status code 4xx | 96 % |
| Info | Informational |  | Percentage of network failures | 1 % |
| Info | Informational | http://172.23.0.4:443 | Percentage of responses with status code 4xx | 100 % |
| Info | Informational | https://172.23.0.4 | Percentage of responses with status code 2xx | 1 % |
| Info | Informational | https://172.23.0.4 | Percentage of responses with status code 5xx | 1 % |
| Info | Informational | https://172.23.0.4 | Percentage of endpoints with content type application/json | 9 % |
| Info | Informational | https://172.23.0.4 | Percentage of endpoints with content type text/html | 90 % |
| Info | Informational | https://172.23.0.4 | Percentage of endpoints with method GET | 93 % |
| Info | Informational | https://172.23.0.4 | Percentage of endpoints with method POST | 6 % |
| Info | Informational | https://172.23.0.4 | Count of total endpoints | 32    |
| Info | Informational | https://172.23.0.4 | Percentage of slow responses | 10 % |







## Alerts

| Name | Risk Level | Number of Instances |
| --- | --- | --- |
| SQL Injection | High | 1 |
| Spring4Shell | High | 2 |
| Absence of Anti-CSRF Tokens | Medium | Systemic |
| Application Error Disclosure | Medium | 1 |
| Content Security Policy (CSP) Header Not Set | Medium | Systemic |
| Proxy Disclosure | Medium | Systemic |
| Sub Resource Integrity Attribute Missing | Medium | Systemic |
| Cross-Domain JavaScript Source File Inclusion | Low | Systemic |
| Cross-Origin-Embedder-Policy Header Missing or Invalid | Low | Systemic |
| Cross-Origin-Opener-Policy Header Missing or Invalid | Low | Systemic |
| Cross-Origin-Resource-Policy Header Missing or Invalid | Low | Systemic |
| In Page Banner Information Leak | Low | 3 |
| Strict-Transport-Security Header Not Set | Low | 1 |
| Cookie Slack Detector | Informational | Systemic |
| Modern Web Application | Informational | Systemic |
| Non-Storable Content | Informational | Systemic |
| Storable and Cacheable Content | Informational | 2 |
| User Agent Fuzzer | Informational | Systemic |
| User Controllable HTML Element Attribute (Potential XSS) | Informational | 1 |




## Alert Detail



### [ SQL Injection ](https://www.zaproxy.org/docs/alerts/40018/)



##### High (Medium)

### Description

SQL injection may be possible.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/redirect/%3Furl=http%253A%252F%252Fexample.com%2527+AND+%25271%2527%253D%25271%2527+--+
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/redirect/ (url)`
  * Method: `GET`
  * Parameter: `url`
  * Attack: `http://example.com' AND '1'='1' -- `
  * Evidence: ``
  * Other Info: `The page results were successfully manipulated using the boolean conditions [http://example.com' AND '1'='1' -- ] and [http://example.com' AND '1'='2' -- ]
The parameter value being modified was stripped from the HTML output for the purposes of the comparison.
Data was returned for the original parameter.
The vulnerability was detected by successfully restricting the data originally returned, by manipulating the parameter.`


Instances: 1

### Solution

Do not trust client side input, even if there is client side validation in place.
In general, type check all data on the server side.
If the application uses JDBC, use PreparedStatement or CallableStatement, with parameters passed by '?'
If the application uses ASP, use ADO Command Objects with strong type checking and parameterized queries.
If database Stored Procedures can be used, use them.
Do *not* concatenate strings into queries in the stored procedure, or use 'exec', 'exec immediate', or equivalent functionality!
Do not create dynamic SQL queries using simple string concatenation.
Escape all data received from the client.
Apply an 'allow list' of allowed characters, or a 'deny list' of disallowed characters in user input.
Apply the principle of least privilege by using the least privileged database user possible.
In particular, avoid using the 'sa' or 'db-owner' database users. This does not eliminate SQL injection, but minimizes its impact.
Grant the minimum database access that is necessary for the application.

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html ](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)


#### CWE Id: [ 89 ](https://cwe.mitre.org/data/definitions/89.html)


#### WASC Id: 19

#### Source ID: 1

### [ Spring4Shell ](https://www.zaproxy.org/docs/alerts/40045/)



##### High (Medium)

### Description

The application appears to be vulnerable to CVE-2022-22965 (otherwise known as Spring4Shell) - remote code execution (RCE) via data binding.

* URL: https://172.23.0.4/xvwa/vulnerabilities/fileupload
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fileupload ()(class.module.classLoader.DefaultAssertio...)`
  * Method: `POST`
  * Parameter: ``
  * Attack: `class.module.classLoader.DefaultAssertionStatus=nonsense`
  * Evidence: `HTTP/1.1 400 Bad Request`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli_blind/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli_blind/ ()(class.module.classLoader.DefaultAssertio...)`
  * Method: `POST`
  * Parameter: ``
  * Attack: `class.module.classLoader.DefaultAssertionStatus=nonsense`
  * Evidence: `HTTP/1.1 400 Bad Request`
  * Other Info: ``


Instances: 2

### Solution

Upgrade Spring Framework to versions 5.3.18, 5.2.20, or newer.

### Reference


* [ https://nvd.nist.gov/vuln/detail/CVE-2022-22965 ](https://nvd.nist.gov/vuln/detail/CVE-2022-22965)
* [ https://www.rapid7.com/blog/post/2022/03/30/spring4shell-zero-day-vulnerability-in-spring-framework/ ](https://www.rapid7.com/blog/post/2022/03/30/spring4shell-zero-day-vulnerability-in-spring-framework/)
* [ https://spring.io/blog/2022/03/31/spring-framework-rce-early-announcement/#vulnerability ](https://spring.io/blog/2022/03/31/spring-framework-rce-early-announcement/#vulnerability)
* [ https://spring.io/security/cve-2022-22965/ ](https://spring.io/security/cve-2022-22965/)


#### CWE Id: [ 78 ](https://cwe.mitre.org/data/definitions/78.html)


#### WASC Id: 20

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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/idor/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/idor/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form class='form' method='POST' id='formLogin' action='/xvwa/login.php'>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "password" "username" ].`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form method='post' action=''>`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 2: "img_url" ].`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

### [ Application Error Disclosure ](https://www.zaproxy.org/docs/alerts/90022/)



##### Medium (Medium)

### Description

This page contains an error/warning message that may disclose sensitive information like the location of the file that produced the unhandled exception. This information can be used to launch further attacks against the web application. The alert could be a false positive if the error message is found inside a documentation page.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/%3Ffile=test.php
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/ (file)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<b>Warning</b>:  include(test.php): failed to open stream: No such file or directory in <b>/var/www/html/xvwa/vulnerabilities/fi/home.php</b> on line <b>36</b><br />`
  * Other Info: ``


Instances: 1

### Solution

Review the source code of this page. Implement custom error pages. Consider implementing a mechanism to provide a unique error reference/identifier to the client (browser) while logging the details on the server side and not exposing them to the user.

### Reference



#### CWE Id: [ 550 ](https://cwe.mitre.org/data/definitions/550.html)


#### WASC Id: 13

#### Source ID: 3

### [ Content Security Policy (CSP) Header Not Set ](https://www.zaproxy.org/docs/alerts/10038/)



##### Medium (High)

### Description

Content Security Policy (CSP) is an added layer of security that helps to detect and mitigate certain types of attacks, including Cross Site Scripting (XSS) and data injection attacks. These attacks are used for everything from data theft to site defacement or distribution of malware. CSP provides a set of standard HTTP headers that allow website owners to declare approved sources of content that browsers should be allowed to load on that page — covered types are JavaScript, CSS, HTML frames, fonts, images and embeddable objects such as Java applets, ActiveX, audio and video files.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

### [ Proxy Disclosure ](https://www.zaproxy.org/docs/alerts/40025/)



##### Medium (Medium)

### Description

1 proxy server(s) were detected or fingerprinted. This information helps a potential attacker to determine
- A list of targets for an attack against the application.
 - Potential vulnerabilities on the proxy servers that service the application.
 - The presence or absence of any proxy-based components that might cause attacks against the application to be detected, prevented, or mitigated.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/php_object_injection/%3Fr=test
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/php_object_injection/ (r)`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/reflected_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/reflected_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/stored_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/stored_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: `TRACE, OPTIONS methods with 'Max-Forwards' header. TRACK method.`
  * Evidence: ``
  * Other Info: `Using the TRACE, OPTIONS, and TRACK methods, the following proxy servers have been identified between ZAP and the application/web server:
- Unknown
The following web/application server has been identified:
- Unknown
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

### [ Sub Resource Integrity Attribute Missing ](https://www.zaproxy.org/docs/alerts/90003/)



##### Medium (High)

### Description

The integrity attribute is missing on a script or link tag served by an external server. The integrity tag prevents an attacker who have gained access to this server from injecting a malicious content.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fileupload/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fileupload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/reflected_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/reflected_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``

Instances: Systemic


### Solution

Provide a valid integrity attribute to the tag.

### Reference


* [ https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity ](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)


#### CWE Id: [ 345 ](https://cwe.mitre.org/data/definitions/345.html)


#### WASC Id: 15

#### Source ID: 3

### [ Cross-Domain JavaScript Source File Inclusion ](https://www.zaproxy.org/docs/alerts/10017/)



##### Low (Medium)

### Description

The page includes one or more script files from a third-party domain.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/idor/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/idor/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli/`
  * Method: `GET`
  * Parameter: `https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js`
  * Attack: ``
  * Evidence: `<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/
  * Node Name: `https://172.23.0.4/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: https://172.23.0.4/robots.txt
  * Node Name: `https://172.23.0.4/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.54`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: https://172.23.0.4/sitemap.xml
  * Node Name: `https://172.23.0.4/sitemap.xml`
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

### [ Strict-Transport-Security Header Not Set ](https://www.zaproxy.org/docs/alerts/10035/)



##### Low (High)

### Description

HTTP Strict Transport Security (HSTS) is a web security policy mechanism whereby a web server declares that complying user agents (such as a web browser) are to interact with it using only secure HTTPS connections (i.e. HTTP layered over TLS/SSL). HSTS is an IETF standards track protocol and is specified in RFC 6797.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/redirect/%3Furl=http://example.com
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/redirect/ (url)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 1

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

### [ Cookie Slack Detector ](https://www.zaproxy.org/docs/alerts/90027/)



##### Informational (Low)

### Description

Repeated GET requests: drop a different cookie each time, followed by normal request with all cookies to stabilize session, compare responses against original baseline GET. This can reveal areas where cookie based authentication/attributes are not actually enforced.

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/sqli_blind/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Dropping this cookie appears to have invalidated the session: [PHPSESSID] A follow-on request with all original cookies still had a different response than the original request.
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Dropping this cookie appears to have invalidated the session: [PHPSESSID] A follow-on request with all original cookies still had a different response than the original request.
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Dropping this cookie appears to have invalidated the session: [PHPSESSID] A follow-on request with all original cookies still had a different response than the original request.
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/%3Fname=test
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/ (name)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Dropping this cookie appears to have invalidated the session: [PHPSESSID] A follow-on request with all original cookies still had a different response than the original request.
`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/stored_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/stored_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `Dropping this cookie appears to have invalidated the session: [PHPSESSID] A follow-on request with all original cookies still had a different response than the original request.
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

* URL: https://172.23.0.4:443/xvwa/instruction.php
  * Node Name: `https://172.23.0.4/xvwa/instruction.php`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/idor/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/idor/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<a class='dropdown-toggle' href='#' data-toggle='dropdown' id='navLogin'>Login</a>`
  * Other Info: `Links have been found that do not have traditional href attributes, which is an indication that this is a modern web application.`
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/cmdi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/cmdi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/dom_xss/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/dom_xss/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/fi/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/fi/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-store`
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

### [ Storable and Cacheable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are storable by caching components such as proxy servers, and may be retrieved directly from the cache, rather than from the origin server by the caching servers, in response to similar requests from other users. If the response data is sensitive, personal or user-specific, this may result in sensitive information being leaked. In some cases, this may even result in a user gaining complete control of the session of another user, depending on the configuration of the caching components in use in their environment. This is primarily an issue where "shared" caching servers such as "proxy" caches are configured on the local network. This configuration is typically found in corporate or educational environments, for instance.

* URL: https://172.23.0.4/robots.txt
  * Node Name: `https://172.23.0.4/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: https://172.23.0.4/sitemap.xml
  * Node Name: `https://172.23.0.4/sitemap.xml`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssrf_xspa/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssrf_xspa/`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/%3Fname=test
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/ (name)`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/ssti/%3Fname=test
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/ssti/ (name)`
  * Method: `GET`
  * Parameter: `Header User-Agent`
  * Attack: `Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)`
  * Evidence: ``
  * Other Info: ``
* URL: https://172.23.0.4:443/xvwa/vulnerabilities/xpath/
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/xpath/`
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

* URL: https://172.23.0.4:443/xvwa/vulnerabilities/idor/%3Fitem=1
  * Node Name: `https://172.23.0.4/xvwa/vulnerabilities/idor/ (item)`
  * Method: `GET`
  * Parameter: `item`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.23.0.4:443/xvwa/vulnerabilities/idor/?item=1

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


