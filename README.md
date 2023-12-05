# SSLPinningWebView

This is a simple demo for SSL pinning checks.

We use `google.com` and `medium.com` as test websites. Before running the code, you should export the certificates of `google.com` and `medium.com` from your preferred browser. Then import these certificates into the project.

Note that you must export the certificates using `DER encoding`. Otherwise, the verification of the certificates will fail.

**Step 1**<br>
<img src="illustration_get_certificate_1.png" width="500">

**Step 2**<br> 
<img src="illustration_get_certificate_2.png" width="500">

**Step 3**<br> 
<img src="illustration_get_certificate_3.png" width="500">

**Step 4**<br> 
<img src="illustration_get_certificate_4.png" width="500">

Test cases
---------
1. testURLSessionTask 
   - sends a URLRequest to the target URL
2. showWebPage 
   - simply loads a web page.
