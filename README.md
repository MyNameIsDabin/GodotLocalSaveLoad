# GodotLocalSaveLoad
local save &amp; load for godot engine


## 준비하기
 - 예제가 필요없다면, 2개의 파일만 프로젝트에 포함시키세요. (***SaveData.gd***, ***SaveDataManager.gd***)
 - **프로젝트-프로젝트 설정**의 **오토로드** 탭에 ***SaveDataManager.gd*** 파일을 싱글톤으로 등록하세요!
 - 프로젝트 전체를 다운받으면 예제를 확인하실 수 있습니다.
 
## SaveData.gd 파일에서 저장할 데이터 구성하기
```
var data: Dictionary = {
		"version_code" : SaveDataManager.Version.ALPHA,
		"option": {
			"bgm_volume": 0,
			"effect_volume": 0, 
			"language": "kr"
		},
		"level": 0,
		"items": [0, 0, 0, 0, 0]
	}
```
data 변수에서 저장할 데이터를 구성합니다. 기본적인 예시로 위와같이 데이터를 구성하였습니다.

## SaveDataManager.gd 파일에서 파일 암호 변경하기
```
const FILE_PASSWORD := "password1234" # 암호화 비밀번호
```
상수로 선언해놓은 파일 패스워드는 변경하시는걸 권장합니다.

## 데이터 저장하기
```
SaveDataManager.set_data("level", 100)
SaveDataManager.set_data("items", [1,2,3,4])
SaveDataManager.save_data() #호출하지 않으면 파일에 저장하지 않음
```
`set_data` 함수로 데이터를 변경하고, `save_data` 함수를 호출하여 데이터를 암호화해서 파일로 저장합니다.

## 파일 불러오기
```
SaveDataManager.load_data()
var current_level: int = SaveDataManager.get_data_by_key("level")
```
암호화된 파일을 복호화해서 불러옵니다. `get_data_by_key` 함수로 데이터를 가져옵니다.

### 옵션 1. 버전 호환하기
```
SaveDataManager.connect("compatible_version", self, "_on_compatible_version")
```
버전호환을 원하는 경우에는 `compatible_version`시그널 연결하여 적절하게 구현하면 됩니다.
```
func _on_compatible_version(loaded_version: int, current_version: int) -> void:
	#버전 호환 구현 예시
	print("불러온 세이브 파일 버전: %d" % loaded_version)
	print("현재 세이브 파일 버전: %d" % current_version)
	#현재 버전코드가 2이상, 불러온 과거 데이터의 버전코드가 2보다 작을 때 (즉, 2 버전보다 오래된 버전에서 넘어온 경우)
	if loaded_version < SaveDataManager.Version.BETA2 \
		and current_version >= SaveDataManager.Version.BETA2:
		pass
	#현재 버전코드가 3이상, 불러온 과거 데이터의 버전코드가 3보다 작을 때 (즉, 3 버전보다 오래된 버전에서 넘어온 경우)
	if loaded_version < SaveDataManager.Version.ALPHA \
		and current_version >= SaveDataManager.Version.ALPHA:
		pass
```
위와같이 불러온 파일의 버전 코드와 현재 버전 코드 정보를 매개변수로 전달받을 수 있습니다.

[!]주의 : 해당 시그널은 load_data() 함수에서 호출하기 때문에, 데이터를 불러오기 직전에 시그널을 연결해둔 상태여야 합니다.

### 옵션 2. 예전버전의 데이터를 무시하고 무조건 현재 버전의 데이터 값으로 불러오기
```
const exclude_values := ["version_code"]
```
SaveDataManager.gd의 17번 라인의 배열에 데이터 키값을 넣으면 해당 데이터는 불러올 때 저장된 데이터를 불러오지 않고 현재 버전의 기본값으로 덮어씌어지도록 합니다. 버전코드의 경우 예전에 불러온 파일의 버전코드를 무시하고 무조건 현재 버전의 저장 데이터 기본값을 유지하도록 해야합니다.
