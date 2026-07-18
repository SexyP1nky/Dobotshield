# ZAP Scanning Report

ZAP by [Checkmarx](https://checkmarx.com/).


## Summary of Alerts

| Risk Level | Number of Alerts |
| --- | --- |
| High | 0 |
| Medium | 7 |
| Low | 15 |
| Informational | 7 |




## Insights

| Level | Reason | Site | Description | Statistic |
| --- | --- | --- | --- | --- |
| Low | Warning |  | ZAP warnings logged - see the zap.log file for details | 1    |
| Info | Informational | https://172.18.0.6 | Percentage of responses with status code 2xx | 49 % |
| Info | Informational | https://172.18.0.6 | Percentage of responses with status code 3xx | 9 % |
| Info | Exceeded Low | https://172.18.0.6 | Percentage of responses with status code 4xx | 40 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type application/javascript | 5 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type application/pdf | 2 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type image/png | 2 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type image/vnd.microsoft.icon | 2 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type text/css | 2 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type text/html | 77 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with content type text/plain | 2 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with method GET | 80 % |
| Info | Informational | https://172.18.0.6 | Percentage of endpoints with method POST | 20 % |
| Info | Informational | https://172.18.0.6 | Count of total endpoints | 40    |
| Info | Exceeded Low | https://172.18.0.6 | Percentage of slow responses | 28 % |







## Alerts

| Name | Risk Level | Number of Instances |
| --- | --- | --- |
| Absence of Anti-CSRF Tokens | Medium | Systemic |
| CSP: Failure to Define Directive with No Fallback | Medium | 2 |
| CSP: Wildcard Directive | Medium | 2 |
| CSP: style-src unsafe-inline | Medium | 2 |
| Content Security Policy (CSP) Header Not Set | Medium | Systemic |
| Missing Anti-clickjacking Header | Medium | Systemic |
| Sub Resource Integrity Attribute Missing | Medium | 2 |
| Cookie No HttpOnly Flag | Low | 1 |
| Cookie Without Secure Flag | Low | 1 |
| Cookie without SameSite Attribute | Low | 1 |
| Cross-Domain JavaScript Source File Inclusion | Low | 2 |
| Cross-Origin-Embedder-Policy Header Missing or Invalid | Low | 2 |
| Cross-Origin-Opener-Policy Header Missing or Invalid | Low | 2 |
| Cross-Origin-Resource-Policy Header Missing or Invalid | Low | 5 |
| Dangerous JS Functions | Low | 1 |
| In Page Banner Information Leak | Low | 2 |
| Permissions Policy Header Not Set | Low | Systemic |
| Private IP Disclosure | Low | 1 |
| Server Leaks Version Information via "Server" HTTP Response Header Field | Low | Systemic |
| Strict-Transport-Security Header Not Set | Low | Systemic |
| Timestamp Disclosure - Unix | Low | Systemic |
| X-Content-Type-Options Header Missing | Low | Systemic |
| Authentication Request Identified | Informational | 1 |
| Information Disclosure - Sensitive Information in URL | Informational | 2 |
| Information Disclosure - Suspicious Comments | Informational | 2 |
| Re-examine Cache-control Directives | Informational | Systemic |
| Storable and Cacheable Content | Informational | 4 |
| Storable but Non-Cacheable Content | Informational | Systemic |
| User Controllable HTML Element Attribute (Potential XSS) | Informational | 8 |




## Alert Detail



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

* URL: https://172.18.0.6/vulnerabilities/captcha/
  * Node Name: `https://172.18.0.6/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form action="#" method="POST" style="display:none;">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "Change" "password_conf" "password_new" "step" ].`
* URL: https://172.18.0.6/vulnerabilities/exec/
  * Node Name: `https://172.18.0.6/vulnerabilities/exec/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form name="ping" action="#" method="post">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "ip" "Submit" ].`
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form enctype="multipart/form-data" action="#" method="POST">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "MAX_FILE_SIZE" "Upload" "uploaded" ].`
* URL: https://172.18.0.6/vulnerabilities/weak_id/
  * Node Name: `https://172.18.0.6/vulnerabilities/weak_id/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form method="post">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "" ].`
* URL: https://172.18.0.6/vulnerabilities/xss_s/
  * Node Name: `https://172.18.0.6/vulnerabilities/xss_s/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<form method="post" name="guestform" ">`
  * Other Info: `No known Anti-CSRF token [anticsrf, CSRFToken, __RequestVerificationToken, csrfmiddlewaretoken, authenticity_token, OWASP_CSRFTOKEN, anoncsrf, csrf_token, _csrf, _csrfSecret, __csrf_magic, CSRF, _token, _csrf_token, _csrfToken] was found in the following HTML form: [Form 1: "btnClear" "btnSign" "txtName" ].`

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

* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The directive(s): frame-ancestors, form-action is/are among the directives that do not fallback to default-src.`
* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/ ()(include)`
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

* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `The following directives either allow wildcard sources (or ancestors), are not defined, or are overly broadly defined:
style-src, img-src, connect-src, frame-src, font-src, media-src, object-src, manifest-src`
* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/ ()(include)`
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

* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/`
  * Method: `GET`
  * Parameter: `Content-Security-Policy`
  * Attack: ``
  * Evidence: `script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;`
  * Other Info: `style-src includes unsafe-inline.`
* URL: https://172.18.0.6/vulnerabilities/csp/
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/ ()(include)`
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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/brute/
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/`
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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/brute/
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/sqli_blind/
  * Node Name: `https://172.18.0.6/vulnerabilities/sqli_blind/`
  * Method: `GET`
  * Parameter: `x-frame-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/`
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

### [ Sub Resource Integrity Attribute Missing ](https://www.zaproxy.org/docs/alerts/90003/)



##### Medium (High)

### Description

The integrity attribute is missing on a script or link tag served by an external server. The integrity tag prevents an attacker who have gained access to this server from injecting a malicious content.

* URL: https://172.18.0.6/vulnerabilities/captcha/
  * Node Name: `https://172.18.0.6/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/captcha/
  * Node Name: `https://172.18.0.6/vulnerabilities/captcha/ ()(Change,password_conf,password_new,step)`
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

* URL: https://172.18.0.6/vulnerabilities/weak_id/
  * Node Name: `https://172.18.0.6/vulnerabilities/weak_id/`
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

### [ Cookie Without Secure Flag ](https://www.zaproxy.org/docs/alerts/10011/)



##### Low (Medium)

### Description

A cookie has been set without the secure flag, which means that the cookie can be accessed via unencrypted connections.

* URL: https://172.18.0.6/vulnerabilities/weak_id/
  * Node Name: `https://172.18.0.6/vulnerabilities/weak_id/`
  * Method: `POST`
  * Parameter: `dvwaSession`
  * Attack: ``
  * Evidence: `Set-Cookie: dvwaSession`
  * Other Info: ``


Instances: 1

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

* URL: https://172.18.0.6/vulnerabilities/weak_id/
  * Node Name: `https://172.18.0.6/vulnerabilities/weak_id/`
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

* URL: https://172.18.0.6/vulnerabilities/captcha/
  * Node Name: `https://172.18.0.6/vulnerabilities/captcha/`
  * Method: `GET`
  * Parameter: `https://www.google.com/recaptcha/api.js`
  * Attack: ``
  * Evidence: `<script src='https://www.google.com/recaptcha/api.js'></script>`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/captcha/
  * Node Name: `https://172.18.0.6/vulnerabilities/captcha/ ()(Change,password_conf,password_new,step)`
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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Embedder-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 2

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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Opener-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``


Instances: 2

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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/dvwa/js/add_event_listeners.js
  * Node Name: `https://172.18.0.6/dvwa/js/add_event_listeners.js`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/favicon.ico
  * Node Name: `https://172.18.0.6/favicon.ico`
  * Method: `GET`
  * Parameter: `Cross-Origin-Resource-Policy`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
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

* URL: https://172.18.0.6/dvwa/js/dvwaPage.js
  * Node Name: `https://172.18.0.6/dvwa/js/dvwaPage.js`
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

* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`
* URL: https://172.18.0.6/vulnerabilities/csp/ZAP
  * Node Name: `https://172.18.0.6/vulnerabilities/csp/ZAP`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25`
  * Other Info: `There is a chance that the highlight in the finding is on a value in the headers, versus the actual matched string in the response body.`


Instances: 2

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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/dvwa/js/add_event_listeners.js
  * Node Name: `https://172.18.0.6/dvwa/js/add_event_listeners.js`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/xss_d/
  * Node Name: `https://172.18.0.6/vulnerabilities/xss_d/`
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

* URL: https://172.18.0.6/vulnerabilities/fi/%3Fpage=file3.php
  * Node Name: `https://172.18.0.6/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `172.18.0.11`
  * Other Info: `172.18.0.11
`


Instances: 1

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

* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.6/favicon.ico
  * Node Name: `https://172.18.0.6/favicon.ico`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `Apache/2.4.25 (Debian)`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/brute/
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/`
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

### [ Strict-Transport-Security Header Not Set ](https://www.zaproxy.org/docs/alerts/10035/)



##### Low (High)

### Description

HTTP Strict Transport Security (HSTS) is a web security policy mechanism whereby a web server declares that complying user agents (such as a web browser) are to interact with it using only secure HTTPS connections (i.e. HTTP layered over TLS/SSL). HSTS is an IETF standards track protocol and is specified in RFC 6797.

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/favicon.ico
  * Node Name: `https://172.18.0.6/favicon.ico`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
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

### [ Timestamp Disclosure - Unix ](https://www.zaproxy.org/docs/alerts/10096/)



##### Low (Low)

### Description

A timestamp was disclosed by the application/web server. - Unix

* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1473231341`
  * Other Info: `1473231341, which evaluates to: 2016-09-07 06:55:41.`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1732584193`
  * Other Info: `1732584193, which evaluates to: 2024-11-26 01:23:13.`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1732584194`
  * Other Info: `1732584194, which evaluates to: 2024-11-26 01:23:14.`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1770035416`
  * Other Info: `1770035416, which evaluates to: 2026-02-02 12:30:16.`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `1958414417`
  * Other Info: `1958414417, which evaluates to: 2032-01-22 20:00:17.`

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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.6/favicon.ico
  * Node Name: `https://172.18.0.6/favicon.ico`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
  * Method: `GET`
  * Parameter: `x-content-type-options`
  * Attack: ``
  * Evidence: ``
  * Other Info: `This issue still applies to error type pages (401, 403, 500, etc.) as those pages are often still affected by injection issues, in which case there is still concern for browsers sniffing pages away from their actual content type.
At "High" threshold this scan rule will not alert on client or server error responses.`
* URL: https://172.18.0.6/vulnerabilities/brute/
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/`
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

* URL: https://172.18.0.6/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `Login`
  * Attack: ``
  * Evidence: `password`
  * Other Info: `userParam=Login
userValue=Login
passwordParam=password
referer=https://172.18.0.6/vulnerabilities/brute/`


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

* URL: https://172.18.0.6/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/ (Login,password,username)`
  * Method: `GET`
  * Parameter: `password`
  * Attack: ``
  * Evidence: `password`
  * Other Info: `The URL contains potentially sensitive information. The following string was found via the pattern: pass
password`
* URL: https://172.18.0.6/vulnerabilities/brute/%3FLogin=Login&password=ZAP&username=ZAP
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/ (Login,password,username)`
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

* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/`
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
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/ ()(phrase,send,token)`
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

### [ Re-examine Cache-control Directives ](https://www.zaproxy.org/docs/alerts/10015/)



##### Informational (Low)

### Description

The cache-control header has not been set properly or is missing, allowing the browser and proxies to cache content. For static assets like css, js, or image files this might be intended, however, the resources should be reviewed to ensure that no sensitive content will be cached.

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: `cache-control`
  * Attack: ``
  * Evidence: `no-cache, must-revalidate`
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: `cache-control`
  * Attack: ``
  * Evidence: `no-cache, must-revalidate`
  * Other Info: ``
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
  * Method: `GET`
  * Parameter: `cache-control`
  * Attack: ``
  * Evidence: ``
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/brute/
  * Node Name: `https://172.18.0.6/vulnerabilities/brute/`
  * Method: `GET`
  * Parameter: `cache-control`
  * Attack: ``
  * Evidence: `no-cache, must-revalidate`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/`
  * Method: `GET`
  * Parameter: `cache-control`
  * Attack: ``
  * Evidence: `no-cache, must-revalidate`
  * Other Info: ``

Instances: Systemic


### Solution

For secure content, ensure the cache-control HTTP header is set with "no-cache, no-store, must-revalidate". If an asset should be cached consider setting the directives "public, max-age, immutable".

### Reference


* [ https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html#web-content-caching ](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html#web-content-caching)
* [ https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control ](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control)
* [ https://grayduck.mn/2021/09/13/cache-control-recommendations/ ](https://grayduck.mn/2021/09/13/cache-control-recommendations/)


#### CWE Id: [ 525 ](https://cwe.mitre.org/data/definitions/525.html)


#### WASC Id: 13

#### Source ID: 3

### [ Storable and Cacheable Content ](https://www.zaproxy.org/docs/alerts/10049/)



##### Informational (Medium)

### Description

The response contents are storable by caching components such as proxy servers, and may be retrieved directly from the cache, rather than from the origin server by the caching servers, in response to similar requests from other users. If the response data is sensitive, personal or user-specific, this may result in sensitive information being leaked. In some cases, this may even result in a user gaining complete control of the session of another user, depending on the configuration of the caching components in use in their environment. This is primarily an issue where "shared" caching servers such as "proxy" caches are configured on the local network. This configuration is typically found in corporate or educational environments, for instance.

* URL: https://172.18.0.6/dvwa/js/add_event_listeners.js
  * Node Name: `https://172.18.0.6/dvwa/js/add_event_listeners.js`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: https://172.18.0.6/favicon.ico
  * Node Name: `https://172.18.0.6/favicon.ico`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: https://172.18.0.6/robots.txt
  * Node Name: `https://172.18.0.6/robots.txt`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`
* URL: https://172.18.0.6/sitemap.xml
  * Node Name: `https://172.18.0.6/sitemap.xml`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: ``
  * Other Info: `In the absence of an explicitly specified caching lifetime directive in the response, a liberal lifetime heuristic of 1 year was assumed. This is permitted by rfc7234.`


Instances: 4

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

* URL: https://172.18.0.6:443
  * Node Name: `https://172.18.0.6`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: https://172.18.0.6/
  * Node Name: `https://172.18.0.6/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/fi/%3Fpage=include.php
  * Node Name: `https://172.18.0.6/vulnerabilities/fi/ (page)`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/`
  * Method: `GET`
  * Parameter: ``
  * Attack: ``
  * Evidence: `no-cache`
  * Other Info: ``
* URL: https://172.18.0.6/vulnerabilities/xss_d/
  * Node Name: `https://172.18.0.6/vulnerabilities/xss_d/`
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

* URL: https://172.18.0.6/vulnerabilities/sqli/%3FSubmit=Submit&id=ZAP
  * Node Name: `https://172.18.0.6/vulnerabilities/sqli/ (Submit,id)`
  * Method: `GET`
  * Parameter: `Submit`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/sqli/?Submit=Submit&id=ZAP

appears to include user input in:
a(n) [input] tag [type] attribute

The user input found was:
Submit=Submit

The user-controlled value was:
submit`
* URL: https://172.18.0.6/vulnerabilities/exec/
  * Node Name: `https://172.18.0.6/vulnerabilities/exec/ ()(Submit,ip)`
  * Method: `POST`
  * Parameter: `Submit`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/exec/

appears to include user input in:
a(n) [input] tag [type] attribute

The user input found was:
Submit=Submit

The user-controlled value was:
submit`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/ ()(phrase,send,token)`
  * Method: `POST`
  * Parameter: `phrase`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/javascript/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
phrase=ChangeMe

The user-controlled value was:
changeme`
* URL: https://172.18.0.6/vulnerabilities/javascript/
  * Node Name: `https://172.18.0.6/vulnerabilities/javascript/ ()(phrase,send,token)`
  * Method: `POST`
  * Parameter: `send`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/javascript/

appears to include user input in:
a(n) [input] tag [type] attribute

The user input found was:
send=Submit

The user-controlled value was:
submit`
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/ ()(MAX_FILE_SIZE,Upload,uploaded)`
  * Method: `POST`
  * Parameter: `MAX_FILE_SIZE`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/upload/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
MAX_FILE_SIZE=100000

The user-controlled value was:
100000`
* URL: https://172.18.0.6/vulnerabilities/upload/
  * Node Name: `https://172.18.0.6/vulnerabilities/upload/ ()(MAX_FILE_SIZE,Upload,uploaded)`
  * Method: `POST`
  * Parameter: `Upload`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/upload/

appears to include user input in:
a(n) [input] tag [name] attribute

The user input found was:
Upload=Upload

The user-controlled value was:
uploaded`
* URL: https://172.18.0.6/vulnerabilities/xss_s/
  * Node Name: `https://172.18.0.6/vulnerabilities/xss_s/ ()(btnClear,mtxMessage,txtName)`
  * Method: `POST`
  * Parameter: `btnClear`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/xss_s/

appears to include user input in:
a(n) [input] tag [value] attribute

The user input found was:
btnClear=Clear Guestbook

The user-controlled value was:
clear guestbook`
* URL: https://172.18.0.6/vulnerabilities/xss_s/
  * Node Name: `https://172.18.0.6/vulnerabilities/xss_s/ ()(btnSign,mtxMessage,txtName)`
  * Method: `POST`
  * Parameter: `btnSign`
  * Attack: ``
  * Evidence: ``
  * Other Info: `User-controlled HTML attribute values were found. Try injecting special characters to see if XSS might be possible. The page at the following URL:

https://172.18.0.6/vulnerabilities/xss_s/

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


