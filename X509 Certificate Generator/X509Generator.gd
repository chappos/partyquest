extends Node

var X509_cert_filename = "X509_Certificate.crt" #use the name of the application.crt
var X509_key_filename = "X509_Key.key" #use the name of the application.key
onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
onready var X509_key_path = "user://Certificate/" + X509_key_filename

#"CN=myserver, O=myorganisation,C=IT"

var CN = "PartyQuest"
var O = "Chappos"
var C = "AUS"
var not_before = "20210101000000"
var not_after = "20211231235900"

func _ready():
	var directory = Directory.new()
	if directory.dir_exists("user://Certificate"):
		pass
	else:
		directory.make_dir("user://Certificate")
	CreateX509Cert()
	print("Certificate Created")
	
func CreateX509Cert():
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
