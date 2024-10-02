# CodeSigning
Linux CodeSigning Process using GPG keys

CodeSigning Process

1.	You need to create the GPG first, in the terminal you need to follow the steps below:

	a.	gpg --full-generate-key
	b.	Choose 1 for an RSA and RSA Key
	c.	Choose key size (During testing I selected 4096)
	d.	Provide a name for the key (I suggest SignWise-Automated-Patching), and your name and email address (I did attempt to leave these blank, and that caused an error)
	e.	You will be asked to select a password for the key (As per, I used VM's password but what ever you decide, it must be recorded)
	f.	gpg --list-secret-keys --keyid-format LONG (To Confirm that Key has been successfully created)
	
	Example of Output:
	
	gpg: checking the trustdb
	gpg: marginals needed: 3  completes needed: 1  trust model: pgp
	gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
	gpg: next trustdb check due at 2025-10-02
	/home/tony/.gnupg/pubring.kbx
	-----------------------------
	sec   rsa4096/09544086B54EA763 2024-10-02 [SC] [expires: 2025-10-02]
      3C39429AA5499ED1306CB95C09544086B54EA763
	uid                 [ultimate] <Enter GPG Key Name> (this is only a testing script key) <Email Address>
	ssb   rsa4096/C66E01D6981EB9CC 2024-10-02 [E] [expires: 2025-10-02]
	
	
2.	CodeSigning Process:

	a.	In the terminal enter the following command <SCRIPTNAME>.sh --setup (This will ask you to create credentials to use the script)
	b. 	Once the credentials are stored, then enter the following command <SCRIPTNAME>.sh
	c.	You will be asked to enter the Username and Password you created in step 2a.
	d.	Copy and enter the path to the Patching script.
	e.	You will now be asked to enter the password for the GPG Key (this is a time sensitive phase, and you will only have 5 seconds to enter the password)
	
	Signature Block and TimeStamp Output Example:
	
	# ---- Timestamp: 2024-10-02 22:07:04 ----
	# ---- Auth Code: dbbd9f0e6d44cc2311d775ebc0c05fe598fe8e04039330855c06f461fbe709bf ----
	-----BEGIN PGP SIGNATURE-----

	iQIzBAEBCgAdFiEEPDlCmqVJntEwbLlcCVRAhrVOp2MFAmb9tfgACgkQCVRAhrVO
	p2P06hAAz5T5M4VhL6SD88CuwNa635htDzPh1WKsf8ccjSk0rK4NIsQDGxwa05cN
	9U61CmcVmtS/tf6lOGQQb053tZ4tAYpL0DKnW+/Lm4Q47z0I16lKNEkBPqtAHj6j
	y2+om4STwJ0pvYHpPC7VHmsn9dWh5wP4Ci9AZeJdvL++czBz+c0kBasy4X69FofE
	1LnP2An+PDl2nsQoMIO4MrE7VAnLz1qqSJU4nYXDJ8y+uC7eqagjTgVPKSIpW3JZ
	4g7lasjWoabVubn/4DR9LW+EYapKkW0O118fZsaHGYtQXBye6yyIYjTfTFwAHM4Q
	FD3KMNb5QkaopYlJLYqYzeU9/Wtwlovaw3oCEIst4aRqvgXcXwSV158ZjCmYJA4V
	WMw7kq+40cNzNJOK4esB1EGy2R5mEA/BdSKpQWzER2GxWFO9mDG1KPn/n+XJCF91
	Di2sfrPMvEI4zUTnlqQigbQ/Ek4MULBQIIeCNxBsju4N8V3y3KqkGlLB/tKNPZfs
	sLUwjT4G7sbQhAMP2Hf8hGNSiToqLdDwDcxXRoWSd+VIDlSZELaMZPXca/VQ7WXJ
	z85xx1MPsd3RX98AQ2LIk9ZJ8Bn+sCh9Bwhv/0ai5AR3DpappPuvRvo3p5+GTjvG
	3x6WCWsutmkNkelB4sH5pNAErHVAkWu4BM2z55k0dUtiGOkY+bQ=
	=i1/Z
	-----END PGP SIGNATURE-----

3.	The Script Creates a log file, and will show the time and date of the script signed, and the Auth Code, and GPG Key ID, it also shows the Device.

Output Example:

[2024-10-02 22:03:20] Signed script: <Path to Signed Script>
Auth Code: ad08cb8ac39b0f0c67d49b05aa4440ba26350afd6e89ab7870e7f4700189e83f
GPG Key: 09544086B54EA763
Device: kali
Expiry: 2025-10-02
-----------------------------
[2024-10-02 22:07:04] Signed script: <Path to Signed Script>
Auth Code: dbbd9f0e6d44cc2311d775ebc0c05fe598fe8e04039330855c06f461fbe709bf
GPG Key: 09544086B54EA763
Device: kali
-----------------------------



