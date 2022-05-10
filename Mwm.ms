/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  local hasMetRequirements
  fn hasMetRequirements = (
    isStruct ::std \
        and isProperty ::std #StructName \
        and classOf ::std.StructName == MAXScriptFunction \
        and ::std.StructName() == #StandardStruct
  )
  if not hasMetRequirements() do (
    local fileClass = DotNetClass "System.IO.File"
    local pathClass = DotNetClass "System.IO.Path"
    local currentDir = pathClass.GetDirectoryName (getSourceFileName())
    local standardFile = currentDir + @"\Standard.min.ms"
    if fileClass.Exists standardFile do fileIn standardFile
  )
  if not hasMetRequirements() do (
    format "[error]Requirement not met.\n"
  )
)
fileIn @"definitionPool.ms"
/*- @var <Struct:MwmStruct> */
global mwm
/*-
MVVMフレームワーク。
*/
struct MwmStruct (
  /*- @prop <Dictionary <Name> <Struct:MwmConverterStruct>> 汎用的なコンバータに名前を付けて格納。既定値は`undefined`。 */
  private converterTable,

  /*- @prop <StructDef:MwmApplicationStruct> */
  private applicationDef,
  /*- @prop <StructDef:MwmBindingStruct> */
  private bindingDef,
  /*- @prop <StructDef:MwmCommandStruct> */
  private commandDef,
  /*- @prop <StructDef:MwmConverterStruct> */
  private converterDef,
  /*- @prop <StructDef:MwmEventStruct> */
  private eventDef,
  /*- @prop <StructDef:MwmModelAttributeStruct> */
  private modelAttributeDef,
  /*- @prop <StructDef:MwmPropertyStruct> */
  private propertyDef,
  /*- @prop <StructDef:MwmViewModelStruct> */
  private viewModelDef,

  /*
  public fn AddConverter converterName converter = (),
  public fn CreateApplication applicationName startupViewName applicationFile:undefined = (),
  public fn CreateCommand commandName executeFunction:undefined canExecuteFunction:undefined modelAttribute:undefined = (),
  public fn CreateCommandBinding commandName target targetEventName = (),
  public fn CreateConverter toTargetFunction toSourceFunction = (),
  public fn CreateEvent control eventName params = (),
  public fn CreateModelAttribute modelName propertyName:undefined getterName:undefined setterName:undefined = (),
  public fn CreateProperty propertyName propertyValue modelAttribute:undefined = (),
  public fn CreatePropertyBinding propertyName target targetEventName targetPropertyName = (),
  public fn CreateViewModel viewModelName = (),
  public fn GetConverter converterName = (),
  public fn GetConverterNames = (),
  public fn Install = (),
  public fn IsValidViewModel obj = (),
  public fn Uninstall = (),

  private fn isValidControl obj = (),
  private fn isValidConverter obj = (),
  private fn isValidMenuItem obj = (),
  private fn isValidModelAttribute obj = (),
  private fn isValidRCMenu obj = (),
  private fn isValidRollout obj = (),
  private fn isValidRolloutControl obj = (),
  */

  /*-
  汎用的なコンバータを追加する。
  @param converterName <Name> コンバータ名。
  @param converter <Struct:MwmConverterStruct> コンバータオブジェクト。
  @returns <Struct:MwmConverterStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  既に登録済みのコンバータ名を指定した場合は内容が上書きされる。
  */
  public fn AddConverter converterName converter = (
    if classOf converterName == Name and this.isValidConverter converter do (
      this.converterTable[converterName] = converter
    )
    this.GetConverter converterName
  ),

  /*-
  アプリケーションを作成する。
  @param applicationName <Name> アプリケーション名。
  @param startupViewName <Name> 起動時に表示されるビューの名前。
  @param applicationFile: <String> アプリケーションファイルのパス。既定値は`undefined`。
  @returns <Struct:MwmApplicationStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateApplication applicationName startupViewName applicationFile:undefined = (
    local application = undefined
    if classOf applicationName == Name \
        and classOf startupViewName == Name \
        and (
          classOf applicationFile == UndefinedClass \
              or classOf applicationFile == String
        ) do (
      application = this.applicationDef \
          applicationName startupViewName applicationFile
    )
    application
  ),

  /*-
  コマンドを作成する。
  @param commandName <Name> コマンド名。
  @param executeFunction: <MAXScriptFunction|UndefinedClass> コマンドの内容を定義した関数。既定値は`undefined`。
  @param canExecuteFunction: <MAXScriptFunction|UndefinedClass> コマンドが実行可能かどうかを判定する関数。既定値は`undefined`。
  @param modelAttribute: <Struct:MwmModelAttributeStruct|UndefinedClass> モデル属性。既定値は`undefined`。
  @returns <Struct:MwmCommandStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateCommand commandName executeFunction:undefined canExecuteFunction:undefined modelAttribute:undefined = (
    local command = undefined
    if classOf commandName == Name do (
      command = this.commandDef commandName executeFunction canExecuteFunction modelAttribute
    )
    command
  ),

  /*-
  ターゲットオブジェクトとコマンドとのバインディングを作成する。
  @param commandName <Name> コマンド名。
  @param target <RolloutClass|RolloutControl> ターゲットオブジェクト。
  @param targetEventName <Name> ターゲットオブジェクトのイベント名。
  @returns <Struct:MwmBindingStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateCommandBinding commandName target targetEventName = (
    local binding = undefined
    if classOf commandName == Name \
        and this.isValidControl target \
        and classOf targetEventName == Name do (
      binding = this.bindingDef 1 commandName target targetEventName
    )
    binding
  ),

  /*-
  コンバータを作成する。
  @param toTargetFunction <MAXScriptFunction> 値をターゲット用に変換する関数。
  @param toSourceFunction <MAXScriptFunction> 値をソース用に変換する関数。
  @returns <Struct:MwmConverterStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateConverter toTargetFunction toSourceFunction = (
    local converter = undefined
    if classOf toTargetFunction == MAXScriptFunction \
        and classOf toSourceFunction == MAXScriptFunction do (
      converter = this.converterDef toTargetFunction toSourceFunction
    )
    converter
  ),

  /*-
  イベントを作成する。
  @param control <RolloutClass|RolloutControl> イベント発生元のロールアウトコントロール。
  @param eventName <Name> イベント名。
  @param params <Array[<Any>]|Any> イベントデータ。
  @returns <Struct:MwmEventStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateEvent control eventName params = (
    local event = undefined
    if this.isValidControl control and classOf eventName == Name do (
      event = this.eventDef control eventName params
    )
    event
  ),

  /*-
  モデル属性を作成する。
  @param modelName <Name> モデル名。
  @param propertyName: <Name|UndefinedClass> モデルのプロパティ名。既定値は`undefined`。
  @param getterName: <Name|UndefinedClass> モデルのプロパティ値取得メソッド名。既定値は`undefined`。
  @param setterName: <Name|UndefinedClass> モデルのプロパティ値設定メソッド名。既定値は`undefined`。
  @returns <Struct:MwmModelAttributeStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateModelAttribute modelName propertyName:undefined getterName:undefined setterName:undefined = (
    local modelAttribute = undefined
    if classOf modelName == Name do (
      modelAttribute = this.modelAttributeDef modelName propertyName getterName setterName
    )
    modelAttribute
  ),

  /*-
  プロパティを作成する。
  @param propertyName <Name> プロパティ名。
  @param propertyValue <Any> プロパティ値。
  @param modelAttribute: <Struct:MwmModelAttributeStruct|UndefinedClass> モデル属性。既定値は`undefined`。
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateProperty propertyName propertyValue modelAttribute:undefined = (
    local property = undefined
    if classOf propertyName == Name do (
      property = this.propertyDef propertyName propertyValue modelAttribute
    )
    property
  ),

  /*-
  ターゲットオブジェクトとプロパティとのバインディングを作成する。
  @param mode <Integer> バインディングにおけるデータフローの方向。
  有効な値は次の通り。

  | 値  | 名前             | 動作                                                                 |
  | --- | ---------------- | -------------------------------------------------------------------- |
  | `1` | `TwoWay`         | ソースまたはターゲットのいずれかが変更されるともう一方も更新される。 |
  | `2` | `OneWay`         | ソースが変更されるとターゲットも更新される。                         |
  | `3` | `OneWayToSource` | ターゲットが変更されるとソースも更新される。                         |
  @param propertyName <Name> プロパティ名。
  @param target <RolloutClass|RolloutControl> ターゲットオブジェクト。
  @param targetEventName <Name> ターゲットオブジェクトのイベント名。
  @param targetPropertyName <Name> ターゲットオブジェクトのプロパティ名。
  @returns <Struct:MwmBindingStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreatePropertyBinding mode propertyName target targetEventName targetPropertyName = (
    local binding = undefined
    if classOf mode == Integer \
        and classOf propertyName == Name \
        and this.isValidControl target \
        and classOf targetEventName == Name \
        and classOf targetPropertyName == Name do (
      binding = this.bindingDef mode propertyName target targetEventName targetPropertyName
    )
    binding
  ),

  /*-
  ビューモデルを作成する。
  @param viewModelName <Name> ビューモデル名。
  @returns <Struct:MwmViewModelStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn CreateViewModel viewModelName = (
    local viewModel = undefined
    if classOf viewModelName == Name do (
      viewModel = this.viewModelDef viewModelName
    )
    viewModel
  ),

  /*-
  汎用コンバータを取得する。
  @param converterName <Name>
  @returns <Struct:MwmConverterStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetConverter converterName = (
    local converter = undefined
    if classOf converterName == Name \
        and hasDictValue this.converterTable converterName do (
      converter = this.converterTable[converterName]
    )
    converter
  ),

  /*-
  全ての汎用コンバータの名前を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetConverterNames = (
    local converterNames = for key in this.converterTable.Keys collect key
    sort converterNames
    converterNames
  ),

  /*-
  インストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Install = (
    ::MwmStruct()
    fileIn @"generalConverter.ms"
    if isProperty ::startupLoader #RegisterFile do (
      ::startupLoader.RegisterFile (getSourceFileName()) installer:true
    )
    format "[install]::mwm\n"
    ok
  ),

  /*-
  指定されたオブジェクトがビューモデルかどうかを判定する。
  @param obj <Any>
  @returns <BooleanClass>
  */
  public fn IsValidViewModel obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmViewModelStruct
  ),

  /*-
  アンインストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Uninstall = (
    if isProperty ::startupLoader #UnregisterFile do (
      ::startupLoader.UnregisterFile (getSourceFileName())
    )
    ::mwm = undefined
    format "[uninstall]::mwm\n"
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidControl obj = (
    this.isValidRollout obj \
        or this.isValidRolloutControl obj \
        or this.isValidRCMenu obj \
        or this.isValidMenuItem obj
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidConverter obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmConverterStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidMenuItem obj = (
    classOf obj == Value \
        and matchPattern (obj as String) pattern:"MenuItem:*" ignoreCase:true
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidModelAttribute obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmModelAttributeStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidRCMenu obj = (
    (classOf obj as String) as Name == #RCMenu \
        and matchPattern (obj as String) pattern:"RCMenu:*" ignoreCase:true
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidRollout obj = (
    classOf obj == RolloutClass
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidRolloutControl obj = (
    superClassOf obj == RolloutControl
  ),

  /*- @prop <String> バージョン番号。メジャー、マイナー、パッチの順。 */
  private version = "2.1.0",

  /*- @returns <Name> */
  public fn StructName = #MwmStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmStruct\n" indent to:out
    format "%  converterTable:%\n" indent this.converterTable.Count to:out
    for converterName in this.converterTable.Keys do (
      format "%    [%]:\n" indent converterName to:out
      this.converterTable[converterName].Dump indent:(indent + "      ") out:out
    )
    format "%  applicationDef:%\n" indent this.applicationDef to:out
    format "%  bindingDef:%\n" indent this.bindingDef to:out
    format "%  commandDef:%\n" indent this.commandDef to:out
    format "%  converterDef:%\n" indent this.converterDef to:out
    format "%  eventDef:%\n" indent this.eventDef to:out
    format "%  modelAttributeDef:%\n" indent this.modelAttributeDef to:out
    format "%  propertyDef:%\n" indent this.propertyDef to:out
    format "%  viewModelDef:%\n" indent this.viewModelDef to:out
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    local isEqualProperties = true

    isEqualStructName and isEqualProperties
  ),

  /*-
  @returns <String>
  */
  public fn GetVersion = (
    this.version
  ),

  on Create do (
    ::mwm = this
    this.converterTable = Dictionary #Name
    this.applicationDef = ::mwmDefinitionPool[@"Model\MwmApplication.ms"]
    this.bindingDef = ::mwmDefinitionPool[@"Model\MwmBinding.ms"]
    this.commandDef = ::mwmDefinitionPool[@"Model\MwmCommand.ms"]
    this.converterDef = ::mwmDefinitionPool[@"Model\MwmConverter.ms"]
    this.eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
    this.modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
    this.propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]
    this.viewModelDef = ::mwmDefinitionPool[@"Model\MwmViewModel.ms"]
  )
)
