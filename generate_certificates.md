# Where can I get certificates for my server?

There are two possibilities: 1) You apply for a certificate from a CA, like Let's Encrypt. Often CA's have specialized on the WWW. Therefore Gemini often uses 2) self-signed certificates.
In order to use a certificate, you need a key. A key consists of two parts: a public one for encryption and a private one for signing and decryption. A certificate contains a public key and as in 1) signed by a CA and in 2) signed by yourself. There are several ways to create a key and a certificate. You can use openssl on the command line or a GUI like XCA. For simplification I wrote two Ruby scripts which interact with OpenSSL.

## Generate key

My script supports two types of keys: RSA and EC. RSA is actually supported by all Gemini browsers. It is - depending on the key set - secure, but a bit slow. EC is new, not supported by all browsers, but secure and fast.
I will show the generation for both types of keys.

### RSA
With RSA there is a key length. The longer, the more secure. 4096 is (currently) considered secure and is used by many. If you want to be on the safe side, you can use the double, i.e. 8196.
```
$ruby generate_key.rb -t rsa -s 8196 -o private_key.pem
Generating rsa key...
Saved to private_key.pem
```
Depending on the key size and the computer, the generation may take a while.

### EC
With EC, a curve is used instead of a key length. Since I am no crypto expert, I can explain this unfortunately badly.
To get a list of available curves, you can do the following:
```
$ruby generate_key.rb -lc
NAME	DESCRIPTION
secp112r1	SECG/WTLS curve over a 112 bit prime field
secp112r2	SECG curve over a 112 bit prime field
secp128r1	SECG curve over a 128 bit prime field
secp128r2	SECG curve over a 128 bit prime field
secp160k1	SECG curve over a 160 bit prime field
secp160r1	SECG curve over a 160 bit prime field
secp160r2	SECG/WTLS curve over a 160 bit prime field
secp192k1	SECG curve over a 192 bit prime field
secp224k1	SECG curve over a 224 bit prime field
secp224r1	NIST/SECG curve over a 224 bit prime field
secp256k1	SECG curve over a 256 bit prime field
secp384r1	NIST/SECG curve over a 384 bit prime field
secp521r1	NIST/SECG curve over a 521 bit prime field
prime192v1	NIST/X9.62/SECG curve over a 192 bit prime field
prime192v2	X9.62 curve over a 192 bit prime field
prime192v3	X9.62 curve over a 192 bit prime field
prime239v1	X9.62 curve over a 239 bit prime field
prime239v2	X9.62 curve over a 239 bit prime field
prime239v3	X9.62 curve over a 239 bit prime field
prime256v1	X9.62/SECG curve over a 256 bit prime field
sect113r1	SECG curve over a 113 bit binary field
sect113r2	SECG curve over a 113 bit binary field
sect131r1	SECG/WTLS curve over a 131 bit binary field
sect131r2	SECG curve over a 131 bit binary field
.......
.......
.......
```
After selecting a curve, you can then generate the EC key:
```
$ruby generate_key.rb -t ec -c secp384r1 -o private_ec.pem
Generating ec key...
Saved to private_ec.pem
```
Compared to RSA, this process should be faster.

## Generate the certificate
Among other things, a certificate contains details about a site. Among them are domain name and other details. Since I wanted to keep it simple, only domain name and email addresses are given in my script.
I assume that I run the gemini.example.com site and have the email postmaster@example.com.
```
$ruby generate_cert.rb -t rsa -k private_key.pem -d sha256 -c gemini.example.com -m postmaster@example.com -f gemini.example.com -o cert.crt
Parsing arguments...
Generating certificate...
Saved to file cert.crt
```
```
$ruby generate_cert.rb -t ec -k private_ec.pem -d sha384 -c gemini.example.com -m postmaster@example.com -f gemini.example.com -o cert_ec.crt
Parsing arguments...
Generating certificate...
Saved to file cert_ec.crt
```
With -d one specifies a hash function. Normally SHA256 is used. SHA1 is considered unsafe and should no longer be used.

Questions that I ask myself over and over again and maybe others too?!
* SHA256 vs SHA512 - https://security.stackexchange.com/questions/165559/why-would-i-choose-sha-256-over-sha-512-for-a-ssl-tls-certificate
* What curve? - https://security.stackexchange.com/questions/78621/which-elliptic-curve-should-i-use
* https://crypto.stackexchange.com/questions/22967/ecc-considered-secure-in-openssl
* https://soatok.blog/2022/05/19/guidance-for-choosing-an-elliptic-curve-signature-algorithm-in-2022/
