extends Control

onready var username_input = $NinePatchRect/VBoxContainer/UsernameEdit
onready var userpassword_input = $NinePatchRect/VBoxContainer/PasswordEdit
onready var login_button = $NinePatchRect/VBoxContainer/LoginButton

func _ready():
	Gateway.connect("login_failed", self, "_OnLoginFailed")

func _on_LoginButton_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide valid username and password")
	else:
		login_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting login - LoginScreen")
		Gateway.ConnectToServer(username, password)

func _OnLoginFailed():
	login_button.disabled = false
