extends Node2D

onready var level_label := $Label

func _ready() -> void:
	SaveDataManager.connect("compatible_version", self, "_on_compatible_version") # 버전호환 기능을 사용할 경우에만 시그널 연결..
	SaveDataManager.load_data()
	print_level()

func _on_Button_pressed() -> void:
	var current_level: int = SaveDataManager.get_data_by_key("level")
	current_level += 1
	SaveDataManager.set_data("level", current_level)
	SaveDataManager.save_data()
	print_level()

func print_level() -> void:
	var current_level: int = SaveDataManager.get_data_by_key("level")
	print("level : %d" % current_level)
	level_label.text = String(current_level)

func _on_compatible_version(loaded_version: int, current_version: int) -> void:
	#버전 호환 구현 예시
	print("불러온 세이브 파일 버전: %d" % loaded_version)
	print("현재 세이브 파일 버전: %d" % current_version)
	#현재 버전코드가 2이상, 불러온 과거 데이터의 버전코드가 2보다 작을 때
	if loaded_version < SaveDataManager.Version.BETA2 \
		and current_version >= SaveDataManager.Version.BETA2:
		pass
	#현재 버전코드가 3이상, 불러온 과거 데이터의 버전코드가 3보다 작을 때
	if loaded_version < SaveDataManager.Version.ALPHA \
		and current_version >= SaveDataManager.Version.ALPHA:
		pass
