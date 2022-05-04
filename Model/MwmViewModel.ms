/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ビューモデルを定義するための構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmViewModelStruct viewModelName
```

通知
:   | 通知名           | 通知データ              | タイミング                                 |
    | ---------------- | ----------------------- | ------------------------------------------ |
    | `#BindingTable`  | 新たな`bindingTable`値  | `bindingTable`を設定した後                 |
    | `#CommandTable`  | 新たな`commandTable`値  | `commandTable`を設定した後                 |
    | `#ModelTable`    | 新たな`modelTable`値    | `modelTable`を設定した後                   |
    | `#PropertyTable` | 新たな`propertyTable`値 | `propertyTable`を設定した後                |
    | `#TargetChanged` | イベントオブジェクト    | ターゲットオブジェクトの変更が通知された後 |
    | `#ViewModelName` | 新たな`viewModelName`値 | `viewModelName`を設定した後                |

注意点
:   * コマンドオブジェクトとプロパティオブジェクトの名前はビューモデル内において一意でなければならない。
*/
struct MwmViewModelStruct (
  /*- @prop <Name> 作成パラメータ1。ビューモデル名。既定値は`undefined`。 */
  public _CP1_,

  /*- @prop <Dictionary <Name> <Dictionary <Name> <Struct:MwmBindingStruct>>> バインディングオブジェクトをソース名とターゲットオブジェクト名に紐付けて格納。既定値は`undefined`。 */
  private bindingTable,
  /*- @prop <Dictionary <Name> <Struct:MwmCommandStruct>> コマンドオブジェクトをコマンド名に紐付けて格納。既定値は`undefined`。 */
  private commandTable,
  /*- @prop <Dictionary <Name> <Struct>> モデルオブジェクトをモデル名に紐付けて格納。既定値は`undefined`。 */
  private modelTable,
  /*- @prop <Dictionary <Name> <Struct:MwmPropertyStruct>> プロパティオブジェクトをプロパティ名に紐付けて格納。既定値は`undefined`。 */
  private propertyTable,
  /*- @prop <Name> ビューモデル名。既定値は`undefined`。 */
  private viewModelName,

  /*
  public fn AddCommand command = (),
  public fn AddModel modelName obj = (),
  public fn AddProperty property = (),
  public fn CanExecuteCommand commandName = (),
  public fn ClearBinding binding = (),
  public fn ExecuteCommand commandName = (),
  public fn GetBinding sourceName targetName = (),
  public fn GetBindingSourceNames = (),
  public fn GetBindingTargetNames sourceName = (),
  public fn GetCommand commandName = (),
  public fn GetCommandNames = (),
  public fn GetModel modelName = (),
  public fn GetModelNames = (),
  public fn GetProperty propertyName = (),
  public fn GetPropertyNames = (),
  public fn GetPropertyValue propertyName = (),
  public fn GetViewModelName = (),
  public fn HasBinding binding = (),
  public fn HasBindingByName sourceName targetName = (),
  public fn HasCommand key = (),
  public fn HasModel key = (),
  public fn HasProperty key = (),
  public fn RaiseTargetChanged event = (),
  public fn RefreshBinding = (),
  public fn SetBinding binding = (),
  public fn SetPropertyValue propertyName propertyValue = (),
  public fn SetViewModelName input = (),

  private fn isValidBinding obj = (),
  private fn isValidCommand obj = (),
  private fn isValidControl obj = (),
  private fn isValidEvent obj = (),
  private fn isValidModel obj = (),
  private fn isValidModelAttribute obj = (),
  private fn isValidProperty obj = (),
  private fn setCommandTo obj = (),
  private fn setModelTo obj = (),
  private fn setPropertyTo obj = (),
  */

  /*-
  コマンドオブジェクトを追加する。
  @param command <Struct:MwmCommandStruct> コマンドオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn AddCommand command = (
    if this.isValidCommand command do (
      local commandName = command.GetCommandName()
      if classOf commandName == Name do (
        this.commandTable[commandName] = command
        this.setModelTo command
        for sourceName in this.bindingTable.Keys do (
          for targetName in this.bindingTable[sourceName].Keys do (
            this.setCommandTo this.bindingTable[sourceName][targetName]
          )
        )
        this.StateChanged.Notify #CommandTable this.commandTable
      )
    )
    this.HasCommand command
  ),

  /*-
  モデルオブジェクトを追加する。
  @param modelName <Name> モデル名。
  @param obj <Struct> モデルオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn AddModel modelName obj = (
    if classOf modelName == Name and this.isValidModel obj do (
      this.modelTable[modelName] = obj
      for commandName in this.commandTable.Keys do (
        this.setModelTo this.commandTable[commandName]
      )
      for propertyName in this.propertyTable.Keys do (
        this.setModelTo this.propertyTable[propertyName]
      )
      this.StateChanged.Notify #ModelTable this.modelTable
    )
    this.HasModel obj
  ),

  /*-
  プロパティオブジェクトを追加する。
  @param property <Struct:MwmPropertyStruct> プロパティオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn AddProperty property = (
    if this.isValidProperty property do (
      local propertyName = property.GetPropertyName()
      if classOf propertyName == Name do (
        this.propertyTable[propertyName] = property
        this.setModelTo property
        for sourceName in this.bindingTable.Keys do (
          for targetName in this.bindingTable[sourceName].Keys do (
            this.setPropertyTo this.bindingTable[sourceName][targetName]
          )
        )
        this.StateChanged.Notify #PropertyTable this.propertyTable
      )
    )
    this.HasProperty property
  ),

  /*-
  コマンドが実行可能かどうかを判定する。
  @param commandName <Name> コマンド名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn CanExecuteCommand commandName = (
    this.HasCommand commandName \
        and this.isValidCommand this.commandTable[commandName] \
        and this.commandTable[commandName].CanExecute()
  ),

  /*-
  バインディングオブジェクトを削除する。
  @param binding <Struct:MwmBindingStruct> バインディングオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn ClearBinding binding = (
    if this.isValidBinding binding do (
      local sourceName = binding.GetSourceName()
      local targetName = binding.GetTargetName()
      if classOf sourceName == Name and classOf targetName == Name do (
        if hasDictValue this.bindingTable sourceName \
            and hasDictValue this.bindingTable[sourceName] targetName do (
          removeDictValue this.bindingTable[sourceName] targetName
          if this.bindingTable[sourceName].Count == 0 do (
            removeDictValue this.bindingTable sourceName
          )
          this.targetChanged.Unsubscribe binding.TargetChanged
          binding.SetSource undefined
          this.StateChanged.Notify #BindingTable this.bindingTable
        )
      )
    )
    not this.HasBinding binding
  ),

  /*-
  コマンドを実行する。
  @param commandName <Name> コマンド名。
  @returns <OkClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn ExecuteCommand commandName = (
    if this.HasCommand commandName \
        and this.isValidCommand this.commandTable[commandName] do (
      this.commandTable[commandName].Execute undefined
    )
    ok
  ),

  /*-
  バインディングオブジェクトを取得する。
  @param sourceName <Name> ソース名。プロパティオブジェクトまたはコマンドオブジェクトの名前。
  @param targetName <Name> ターゲットオブジェクトの名前。
  @returns <Struct:MwmBindingStruct|UndefinedClass>
  @remarks バインディングオブジェクトが存在しない場合は`undefined`を返す。
  */
  public fn GetBinding sourceName targetName = (
    local binding = undefined
    if this.HasBindingByName sourceName targetName do (
      binding = this.bindingTable[sourceName][targetName]
    )
    binding
  ),

  /*-
  登録されているバインディングオブジェクトのソース名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetBindingSourceNames = (
    local sourceNames = for key in this.bindingTable.Keys collect key
    sort sourceNames
    sourceNames
  ),

  /*-
  登録されているバインディングオブジェクトのターゲット名を取得する。
  @param sourceName <Name> ソース名。プロパティオブジェクトまたはコマンドオブジェクトの名前。
  @returns <Array[<Name>]>
  @remarks 無効な値の場合は空の配列を返す。
  */
  public fn GetBindingTargetNames sourceName = (
    local targetNames = #()
    if classOf sourceName == Name and hasDictValue this.bindingTable sourceName do (
      targetNames = for key in this.bindingTable[sourceName].Keys collect key
      sort targetNames
    )
    targetNames
  ),

  /*-
  コマンドオブジェクトを取得する。
  @param commandName <Name> コマンド名。
  @returns <Struct:MwmCommandStruct|UndefinedClass>
  @remarks コマンドオブジェクトが存在しない場合は`undefined`を返す。
  */
  public fn GetCommand commandName = (
    local command = undefined
    if this.HasCommand commandName do (
      command = this.commandTable[commandName]
    )
    command
  ),

  /*-
  登録されているコマンドオブジェクトのコマンド名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetCommandNames = (
    local commandNames = for key in this.commandTable.Keys collect key
    sort commandNames
    commandNames
  ),

  /*-
  モデルオブジェクトを取得する。
  @param modelName <Name> モデル名。
  @returns <Struct|UndefinedClass>
  @remarks モデルオブジェクトが存在しない場合は`undefined`を返す。
  */
  public fn GetModel modelName = (
    local model = undefined
    if this.HasModel modelName do (
      model = this.modelTable[modelName]
    )
    model
  ),

  /*-
  登録されているモデルオブジェクトのモデル名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetModelNames = (
    local modelNames = for key in this.modelTable.Keys collect key
    sort modelNames
    modelNames
  ),

  /*-
  プロパティオブジェクトを取得する。
  @param propertyName <Name> プロパティ名。
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  @remarks プロパティオブジェクトが存在しない場合は`undefined`を返す。
  */
  public fn GetProperty propertyName = (
    local property = undefined
    if this.HasProperty propertyName do (
      property = this.propertyTable[propertyName]
    )
    property
  ),

  /*-
  登録されているプロパティオブジェクトのプロパティ名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetPropertyNames = (
    local propertyNames = for key in this.propertyTable.Keys collect key
    sort propertyNames
    propertyNames
  ),

  /*-
  プロパティオブジェクトのプロパティ値を取得する。
  @param propertyName <Name> プロパティ名。
  @returns <Any>
  @remarks プロパティオブジェクトが存在しない場合は`undefined`を返す。
  */
  public fn GetPropertyValue propertyName = (
    local propertyValue = undefined
    if this.HasProperty propertyName \
        and this.isValidProperty this.propertyTable[propertyName] do (
      propertyValue = this.propertyTable[propertyName].GetPropertyValue()
    )
    propertyValue
  ),

  /*-
  ビューモデル名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetViewModelName = (
    this.viewModelName
  ),

  /*-
  バインディングオブジェクトが存在するかどうかを判定する。
  @param binding <Struct:MwmBindingStruct>
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasBinding binding = (
    this.isValidBinding binding \
        and this.HasBindingByName (binding.GetSourceName()) (binding.GetTargetName())
  ),

  /*-
  名前からバインディングオブジェクトが存在するかどうかを判定する。
  @param sourceName <Name> ソース名。プロパティオブジェクトまたはコマンドオブジェクトの名前。
  @param targetName <Name> ターゲットオブジェクトの名前。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasBindingByName sourceName targetName = (
    classOf sourceName == Name and classOf targetName == Name \
        and hasDictValue this.bindingTable sourceName \
        and hasDictValue this.bindingTable[sourceName] targetName
  ),

  /*-
  コマンドオブジェクトが存在するかどうかを判定する。
  @param key <Struct:MwmCommandStruct|Name> コマンドオブジェクトまたはコマンド名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasCommand key = (
    local commandName = key
    if this.isValidCommand key do (
      commandName = key.GetCommandName()
    )
    classOf commandName == Name and hasDictValue this.commandTable commandName
  ),

  /*-
  モデルオブジェクトが存在するかどうかを判定する。
  @param key <Struct|Name> モデルオブジェクトまたはモデル名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasModel key = (
    if classOf key == Name then (
      hasDictValue this.modelTable key
    )
    else (
      local isFound = false
      for modelName in this.modelTable.Keys while not isFound do (
        isFound = this.modelTable[modelName] == key
      )
      isFound
    )
  ),

  /*-
  プロパティオブジェクトが存在するかどうかを判定する。
  @param key <Struct:MwmPropertyStruct|Name> プロパティオブジェクトまたはプロパティ名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasProperty key = (
    local propertyName = key
    if this.isValidProperty key do (
      propertyName = key.GetPropertyName()
    )
    classOf propertyName == Name and hasDictValue this.propertyTable propertyName
  ),

  /*-
  ターゲットオブジェクトの変更通知を発行する。
  @param event <Struct:MwmEventStruct> イベントオブジェクト。
  @returns <OkClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn RaiseTargetChanged event = (
    if this.isValidEvent event do (
      this.targetChanged.Notify #TargetChanged event
    )
    ok
  ),

  /*-
  バインディングオブジェクトを更新してターゲットを最新の状態にする。
  @returns <OkClass>
  */
  public fn RefreshBinding = (
    for sourceName in this.bindingTable.Keys do (
      for targetName in this.bindingTable[sourceName].Keys do (
        local binding = this.bindingTable[sourceName][targetName]
        if this.isValidBinding binding do (
          binding.Refresh()
        )
      )
    )
    ok
  ),

  /*-
  バインディングオブジェクトを追加する。
  @param binding <Struct:MwmBindingStruct> バインディングオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn SetBinding binding = (
    if this.isValidBinding binding do (
      local sourceName = binding.GetSourceName()
      local targetName = binding.GetTargetName()
      if classOf sourceName == Name and classOf targetName == Name do (
        if not hasDictValue this.bindingTable sourceName do (
          this.bindingTable[sourceName] = Dictionary #Name
        )
        if not hasDictValue this.bindingTable[sourceName] targetName do (
          this.bindingTable[sourceName][targetName] = binding
          this.targetChanged.Subscribe binding.TargetChanged
          this.setCommandTo binding
          this.setPropertyTo binding
          this.StateChanged.Notify #BindingTable this.bindingTable
        )
      )
    )
    this.HasBinding binding
  ),

  /*-
  プロパティオブジェクトのプロパティ値を設定する。
  @param propertyName <Name> プロパティ名。
  @param propertyValue <Any> プロパティ値。
  @returns <BooleanClass> 設定に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetPropertyValue propertyName propertyValue = (
    local isSuccessful = false
    if this.HasProperty propertyName \
        and this.isValidProperty this.propertyTable[propertyName] do (
      this.propertyTable[propertyName].SetPropertyValue propertyValue
      isSuccessful = true
    )
    isSuccessful
  ),

  /*-
  ビューモデル名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetViewModelName input = (
    if classOf input == Name do (
      this.viewModelName = input
      this.StateChanged.Notify #ViewModelName this.viewModelName
    )
    this.GetViewModelName()
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidBinding obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmBindingStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidCommand obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmCommandStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidControl obj = (
    classOf obj == RolloutClass or superClassOf obj == RolloutControl
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidEvent obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmEventStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidModel obj = (
    isStruct obj
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
  private fn isValidProperty obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmPropertyStruct
  ),

  /*-
  バインディングオブジェクトのソースにコマンドオブジェクトを設定し、コマンドオブジェクトの通知元オブジェクトにバイディングの対応メソッドを購読させる。
  @param obj <Struct:MwmBindingStruct>
  @returns <BooleanClass> 設定に成功した場合は`true`、失敗した場合は`false`。
  */
  private fn setCommandTo obj = (
    local isSuccessful = false
    if this.isValidBinding obj do (
      local commandName = obj.GetSourceName()
      if classOf commandName == Name \
          and this.HasCommand commandName \
          and this.isValidCommand this.commandTable[commandName] do (
        obj.SetSource this.commandTable[commandName]
        isSuccessful = true
      )
    )
    isSuccessful
  ),

  /*-
  モデルのプロパティ情報を持つオブジェクトにモデルオブジェクトを設定する。
  @param obj <Struct>
  @returns <BooleanClass> 設定に成功した場合は`true`、失敗した場合は`false`。
  */
  private fn setModelTo obj = (
    local isSuccessful = false
    if isStruct obj \
        and isProperty obj #GetModelAttribute \
        and classOf obj.GetModelAttribute == MAXScriptFunction \
        and isProperty obj #SetModel \
        and classOf obj.SetModel == MAXScriptFunction do (
      local modelAttribute = obj.GetModelAttribute()
      if this.isValidModelAttribute modelAttribute do (
        local modelName = modelAttribute.GetModelName()
        if classOf modelName == Name \
            and this.HasModel modelName \
            and this.isValidModel this.modelTable[modelName] do (
          obj.SetModel this.modelTable[modelName]
          isSuccessful = true
        )
      )
    )
    isSuccessful
  ),

  /*-
  バインディングオブジェクトのソースにプロパティオブジェクトを設定し、プロパティオブジェクトの通知元オブジェクトにバイディングの対応メソッドを購読させる。
  @param obj <Struct:MwmBindingStruct>
  @returns <BooleanClass> 設定に成功した場合は`true`、失敗した場合は`false`。
  */
  private fn setPropertyTo obj = (
    local isSuccessful = false
    if this.isValidBinding obj do (
      local propertyName = obj.GetSourceName()
      if classOf propertyName == Name \
          and this.HasProperty propertyName \
          and this.isValidProperty this.propertyTable[propertyName] do (
        obj.SetSource this.propertyTable[propertyName]
        isSuccessful = true
      )
    )
    isSuccessful
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmViewModelStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmViewModelStruct\n" indent to:out
    format "%  bindingTable:%\n" indent this.bindingTable.Count to:out
    for sourceName in this.bindingTable.Keys do (
      format "%    [%]:%\n" indent sourceName this.bindingTable[sourceName].Count to:out
      for targetName in this.bindingTable[sourceName].Keys do (
        local binding = this.bindingTable[sourceName][targetName]
        if this.isValidBinding binding then (
          format "%      [%]:\n" indent targetName to:out
          binding.Dump indent:(indent + "        ") out:out
        )
        else (
          format "%      [%]:%\n" indent targetName binding to:out
        )
      )
    )
    format "%  commandTable:%\n" indent this.commandTable.Count to:out
    for commandName in this.commandTable.Keys do (
      local command = this.commandTable[commandName]
      if this.isValidCommand command then (
        format "%    [%]:\n" indent commandName to:out
        command.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent commandName command to:out
      )
    )
    format "%  modelTable:%\n" indent this.modelTable.Count to:out
    for modelName in this.modelTable.Keys do (
      local model = this.modelTable[modelName]
      if this.isValidModel model \
          and isProperty model #StructName \
          and classOf model.StructName == MAXScriptFunction \
          and isProperty model #Dump \
          and classOf model.Dump == MAXScriptFunction then (
        format "%    [%]:\n" indent modelName to:out
        model.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent modelName model to:out
      )
    )
    format "%  propertyTable:%\n" indent this.propertyTable.Count to:out
    for propertyName in this.propertyTable.Keys do (
      local property = this.propertyTable[propertyName]
      if this.isValidProperty property then (
        format "%    [%]:\n" indent propertyName to:out
        property.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent propertyName property to:out
      )
    )
    format "%  viewModelName:%\n" indent this.viewModelName to:out
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

    local isEqualProperties = true \
        and isProperty obj #GetBinding \
        and classOf obj.GetBinding == MAXScriptFunction \
        and isProperty obj #GetBindingSourceNames \
        and classOf obj.GetBindingSourceNames == MAXScriptFunction \
        and isProperty obj #GetBindingTargetNames \
        and classOf obj.GetBindingTargetNames == MAXScriptFunction \
        and isProperty obj #GetCommand \
        and classOf obj.GetCommand == MAXScriptFunction \
        and isProperty obj #GetCommandNames \
        and classOf obj.GetCommandNames == MAXScriptFunction \
        and isProperty obj #GetModel \
        and classOf obj.GetModel == MAXScriptFunction \
        and isProperty obj #GetModelNames \
        and classOf obj.GetModelNames == MAXScriptFunction \
        and isProperty obj #GetProperty \
        and classOf obj.GetProperty == MAXScriptFunction \
        and isProperty obj #GetPropertyNames \
        and classOf obj.GetPropertyNames == MAXScriptFunction \
        and isProperty obj #GetViewModelName \
        and classOf obj.GetViewModelName == MAXScriptFunction \
        and obj.GetViewModelName() == this.GetViewModelName()

    if isEqualProperties do (
      local oSourceNames = obj.GetBindingSourceNames()
      local tSourceNames = this.GetBindingSourceNames()
      isEqualProperties = classOf oSourceNames == Array \
          and classOf tSourceNames == Array \
          and oSourceNames.Count == tSourceNames.Count
      for i = 1 to tSourceNames.Count while isEqualProperties do (
        isEqualProperties = oSourceNames[i] == tSourceNames[i]
        if isEqualProperties do (
          local oTargetNames = obj.GetBindingTargetNames oSourceNames[i]
          local tTargetNames = this.GetBindingTargetNames tSourceNames[i]
          isEqualProperties = classOf oTargetNames == Array \
              and classOf tTargetNames == Array \
              and oTargetNames.Count == tTargetNames.Count
          for j = 1 to tTargetNames.Count while isEqualProperties do (
            local oBinding = obj.GetBinding oSourceNames[i] oTargetNames[j]
            local tBinding = this.GetBinding tSourceNames[i] tTargetNames[j]
            if this.isValidBinding tBinding then (
              isEqualProperties = tBinding.Equals oBinding
            )
            else (
              isEqualProperties = oBinding == tBinding
            )
          )
        )
      )
    )

    if isEqualProperties do (
      local oCommandNames = obj.GetCommandNames()
      local tCommandNames = this.GetCommandNames()
      isEqualProperties = classOf oCommandNames == Array \
          and classOf tCommandNames == Array \
          and oCommandNames.Count == tCommandNames.Count
      for i = 1 to tCommandNames.Count while isEqualProperties do (
        isEqualProperties = oCommandNames[i] == tCommandNames[i]
        if isEqualProperties do (
          local oCommand = obj.GetCommand oCommandNames[i]
          local tCommand = this.GetCommand tCommandNames[i]
          if this.isValidCommand tCommand then (
            isEqualProperties = tCommand.Equals oCommand
          )
          else (
            isEqualProperties = oCommand == tCommand
          )
        )
      )
    )

    if isEqualProperties do (
      local oModelNames = obj.GetModelNames()
      local tModelNames = this.GetModelNames()
      isEqualProperties = classOf oModelNames == Array \
          and classOf tModelNames == Array \
          and oModelNames.Count == tModelNames.Count
      for i = 1 to tModelNames.Count while isEqualProperties do (
        isEqualProperties = oModelNames[i] == tModelNames[i]
        if isEqualProperties do (
          local oModel = obj.GetModel oModelNames[i]
          local tModel = this.GetModel tModelNames[i]
          if this.isValidModel tModel then (
            isEqualProperties = tModel.Equals oModel
          )
          else (
            isEqualProperties = oModel == tModel
          )
        )
      )
    )

    if isEqualProperties do (
      local oPropertyNames = obj.GetPropertyNames()
      local tPropertyNames = this.GetPropertyNames()
      isEqualProperties = classOf oPropertyNames == Array \
          and classOf tPropertyNames == Array \
          and oPropertyNames.Count == tPropertyNames.Count
      for i = 1 to tPropertyNames.Count while isEqualProperties do (
        isEqualProperties = oPropertyNames[i] == tPropertyNames[i]
        if isEqualProperties do (
          local oProperty = obj.GetProperty oPropertyNames[i]
          local tProperty = this.GetProperty tPropertyNames[i]
          if this.isValidProperty tProperty then (
            isEqualProperties = tProperty.Equals oProperty
          )
          else (
            isEqualProperties = oProperty == tProperty
          )
        )
      )
    )

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  /*- @prop <Struct:ObservableStruct> */
  private targetChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
    this.targetChanged = ::std.ObservableStruct()
    this.bindingTable = Dictionary #Name
    this.commandTable = Dictionary #Name
    this.modelTable = Dictionary #Name
    this.propertyTable = Dictionary #Name
    this.SetViewModelName this._CP1_
  )
)
