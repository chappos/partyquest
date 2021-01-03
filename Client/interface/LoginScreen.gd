extends Control

onready var login_screen = $NinePatchRect/LoginScreen
onready var create_account_screen = $NinePatchRect/CreateAccount

onready var username_input = $NinePatchRect/LoginScreen/UsernameEdit
onready var userpassword_input = $NinePatchRect/LoginScreen/PasswordEdit
onready var login_button = $NinePatchRect/LoginScreen/LoginButton
onready var create_account_button = $NinePatchRect/LoginScreen/CreateAccountButton

onready var create_username_input = $NinePatchRect/CreateAccount/UsernameEdit
onready var create_password_input = $NinePatchRect/CreateAccount/PasswordEdit
onready var create_confirm_password_input = $NinePatchRect/CreateAccount/PasswordEdit2
onready var create_confirm_button = $NinePatchRect/CreateAccount/ConfirmButton
onready var create_back_button = $NinePatchRect/CreateAccount/BackButton

#TODO: remove this shit
onready var world_node: PackedScene = preload("res://World.tscn")

func _ready():
# warning-ignore:return_value_discarded
	Gateway.connect("login_failed", self, "_OnLoginFailed")
# warning-ignore:return_value_discarded
	Gateway.connect("account_create_succeeded", self, "_OnAccountCreateSucceeded")
# warning-ignore:return_value_discarded
	Gateway.connect("account_create_failed", self, "_OnAccountCreateFailed")
# warning-ignore:return_value_discarded
	GameServer.connect("login_failed", self, "_OnLoginFailed")
	
	#TODO: Move _OnLoginSucceeded functionality to a more appropriate node
# warning-ignore:return_value_discarded
	GameServer.connect("login_succeeded", self, "_OnLoginSucceeded")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		var focused = $NinePatchRect.get_focus_owner()
		if focused == userpassword_input:
			_on_LoginButton_pressed()
		elif focused == create_confirm_password_input:
			_on_ConfirmButton_pressed()
		

func _on_LoginButton_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide valid username and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting login - LoginScreen")
		Gateway.ConnectToServer(username, password, false)

func _OnLoginSucceeded():
	var new_world = world_node.instance()
	get_tree().get_root().add_child(new_world)
	self.call_deferred("queue_free")

func _OnLoginFailed():
	login_button.disabled = false
	create_account_button.disabled = false
	
func _OnAccountCreateSucceeded():
	create_confirm_button.disabled = false
	create_back_button.disabled = false
	create_account_screen.hide()
	login_screen.show()
	
func _OnAccountCreateFailed():
	create_account_button.disabled = false
	create_back_button.disabled = false


#Create Account Confirm Button
func _on_ConfirmButton_pressed():
	if create_username_input.get_text() == "":
		print("Please provide valid username")
	elif create_password_input.get_text() == "":
		print("Please provide valid password")
	elif create_confirm_password_input.get_text() == "":
		print("Please confirm your password")
	elif create_password_input.get_text() != create_confirm_password_input.get_text():
		print("Passwords do not match")
	elif create_password_input.get_text().length() <= 6:
		print("Password must contain at least 7 characters")
	else:
		create_confirm_button.disabled = true
		create_back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_password_input.get_text()
		Gateway.ConnectToServer(username, password, true)

#Create Account Back Button
func _on_BackButton_pressed():
	create_account_screen.hide()
	login_screen.show()
	

#Login Screen Create Account Button
func _on_CreateAccountButton_pressed():
	login_screen.hide()
	create_account_screen.show()
