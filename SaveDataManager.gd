extends Node

signal compatible_version(loaded_version, current_version) #int, int

const SAVE_FILE_PATH := "user://gamedata.save"
const FILE_PASSWORD := "password1234" # 암호화 비밀번호

enum Version { 
		ALPHA = 1, 
		BETA1 = 2, 
		BETA2 = 3, 
		BETA3 = 4
	}

#무조건 최신버전 데이터값으로 덮어씌어지는 저장 데이터 목록
#예를들어, version_code 값은 오래된 예전 저장 데이터를 불러오더라도 무조건 현재의 최신 데이터 값으로 덮어씌어집니다.
const exclude_values := ["version_code"]
	
onready var save_node := SaveData.new()

func get_data() -> Dictionary:
	return save_node.data

func get_data_by_key(key: String):
	if key.empty():
		return save_node.data
	else:
		return save_node.data[key]

func set_data(key: String, value) -> void:
	save_node.data[key] = value

func load_data() -> void:
	var save_file := File.new()
	if !save_file.file_exists(SAVE_FILE_PATH):
		save_data()
		return
		
	var err = save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.READ, FILE_PASSWORD)
	
	if err != OK:
		print_debug("Failure!")
		return
	
	var buffer = save_file.get_as_text()
	save_file.close()
	
	if not validate_json(buffer):
		var load_data = parse_json(buffer)
		merge_data(save_node.data, load_data)

func merge_data(origin_data: Dictionary, load_data: Dictionary) -> void:
	var current_version = origin_data.version_code
	
	if load_data.version_code != current_version:
		emit_signal("compatible_version", load_data.version_code, current_version)
			
	for key in exclude_values:
		if load_data.has(key) and save_node.data.has(key):
			load_data[key] = save_node.data[key]
	merge_dict(origin_data, load_data)
	
func game_reload(load_data: Dictionary) -> void:
	merge_data(save_node.data, load_data)
	save_data()

func save_data() -> void:
	var save_file := File.new()
	var err = save_file.open_encrypted_with_pass(SAVE_FILE_PATH, File.WRITE, FILE_PASSWORD)
	if err != OK:
		print_debug("Failure!")
		return
	save_file.store_string(to_json(save_node.data))
	save_file.close()
	
func merge_dict(dest: Dictionary, source: Dictionary) -> void:
	for key in source:                     
		if dest.has(key):                  
			var dest_value = dest[key]     
			var source_value = source[key]       
			if typeof(dest_value) == TYPE_DICTIONARY:       
				if typeof(source_value) == TYPE_DICTIONARY: 
					merge_dict(dest_value, source_value)  
				else:
					dest[key] = source_value
			else:
				dest[key] = source_value
		else:
			dest[key] = source[key]
