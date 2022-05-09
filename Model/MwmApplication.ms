/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
アプリケーションをカプセル化するための構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmApplicationStruct applicationName startupViewName applicationFile
```

* アプリケーションファイルの拡張子を`.mxsconfig`に変えたものが設定ファイルのパスとなる。

* 設定ファイルを作りたくない場合はアプリケーションファイルを未定義にする。

通知
:   | 通知名                 | 通知データ                                        | タイミング                     |
    | ---------------------- | ------------------------------------------------- | ------------------------------ |
    | `#ApplicationFile`     | 新たな`applicationFile`値                         | `applicationFile`を設定した後  |
    | `#ApplicationName`     | 新たな`applicationName`値                         | `applicationName`を設定した後  |
    | `#ApplicationRan`      | ビューオブジェクトの`IsDisplayed`メソッドの戻り値 | アプリケーションを開始した直後 |
    | `#ApplicationShutdown` | ビューオブジェクトの`IsDisplayed`メソッドの戻り値 | アプリケーションを終了した直後 |
    | `#ConfigRead`          | `undefined`                                       | 設定ファイルを読み込んだ後     |
    | `#ConfigWrote`         | `undefined`                                       | 設定ファイルを書き込んだ後     |
    | `#ModelTable`          | 新たな`modelTable`値                              | `modelTable`を設定した後       |
    | `#StartupViewName`     | 新たな`startupViewName`値                         | `startupViewName`を設定した後  |
    | `#ViewModelTable`      | 新たな`viewModelTable`値                          | `viewModelTable`を設定した後   |
    | `#ViewTable`           | 新たな`viewTable`値                               | `viewTable`を設定した後        |

`RolloutClass`のイベントを受ける既定のコマンド
:   | イベント名 | コマンド名        |
    | ---------- | ----------------- |
    | `#Close`   | `#RolloutClose`   |
    | `#Moved`   | `#RolloutMoved`   |
    | `#Open`    | `#RolloutOpen`    |
    | `#Resized` | `#RolloutResized` |

    * これらのコマンドは内部的に自動生成される。
*/
struct MwmApplicationStruct (
  /*- @prop <Name> 作成パラメータ1。アプリケーションの名前。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <Name> 作成パラメータ2。起動時に表示されるビューの名前。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <String|UndefinedClass> 作成パラメータ3。アプリケーションファイルのパス。既定値は`undefined`。 */
  public _CP3_,

  /*- @prop <String|UndefinedClass> アプリケーションファイルのパス。既定値は`undefined`。 */
  private applicationFile,
  /*- @prop <Name> アプリケーションの名前。既定値は`undefined`。 */
  private applicationName,
  /*- @prop <Struct:ConfigStruct> 設定オブジェクト。既定値は`undefined`。 */
  private config,
  /*- @prop <Dictionary <Name> <Struct>> モデルオブジェクトに名前を付けて格納。既定値は`undefined`。 */
  private modelTable,
  /*- @prop <Name> 起動時に表示されるビューの名前。既定値は`undefined`。 */
  private startupViewName,
  /*- @prop <Dictionary <Name> <Struct:MwmViewModelStruct>> ビューモデルオブジェクトを格納。既定値は`undefined`。 */
  private viewModelTable,
  /*- @prop <Dictionary <Name> <Struct:DialogStruct>> ビューオブジェクトを格納。既定値は`undefined`。 */
  private viewTable,

  /*- @prop <StructDef:MwmBindingStruct> */
  private bindingDef,
  /*- @prop <StructDef:MwmCommandStruct> */
  private commandDef,
  /*- @prop <StructDef:MwmModelAttributeStruct> */
  private modelAttributeDef,

  /*
  public fn AddModel modelName obj = (),
  public fn AddView obj = (),
  public fn AddViewModel obj = (),
  public fn GetApplicationFile = (),
  public fn GetApplicationName = (),
  public fn GetConfig = (),
  public fn GetModel modelName = (),
  public fn GetStartupViewName = (),
  public fn GetView viewName = (),
  public fn GetViewModel viewModelName = (),
  public fn HasModel key = (),
  public fn HasView key = (),
  public fn HasViewModel key = (),
  public fn ReadConfig = (),
  public fn Run = (),
  public fn SetApplicationFile input = (),
  public fn SetApplicationName input = (),
  public fn SetStartupViewName input = (),
  public fn Shutdown = (),
  public fn WriteConfig = (),

  private fn bindRolloutEventToView = (),
  private fn initializeConfig = (),
  private fn isValidConfig obj = (),
  private fn isValidDialog obj = (),
  private fn isValidEvent obj = (),
  private fn isValidModel obj = (),
  private fn isValidView obj = (),
  private fn isValidViewModel obj = (),
  private fn onRolloutClose model params event = (),
  private fn onRolloutMoved model params event = (),
  private fn onRolloutOpen model params event = (),
  private fn onRolloutResized model params event = (),
  */

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
      this.StateChanged.Notify #ModelTable this.modelTable
    )
    this.HasModel obj
  ),

  /*-
  ビューオブジェクトを追加する。
  @param obj <Struct:DialogStruct> ビューオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  ビューオブジェクトの最小限のデータ構造は以下の通り。

  * `::std.DialogStruct`

    * `RolloutClass`

      * ```maxscript
        -- 対応するビューモデルオブジェクトの名前で初期化する
        local DataContext = #ViewModelName
        ```

      * ```maxscript
        fn Initialize obj = (
          if ::mwm.IsValidViewModel obj do (
            DataContext = obj
          )
          ok
        )
        ```
  */
  public fn AddView obj = (
    local viewName = undefined
    if this.isValidView obj do (
      viewName = obj.GetRolloutName()
    )
    if classOf viewName == Name do (
      this.viewTable[viewName] = obj
      this.bindRolloutEventToView()
      this.StateChanged.Notify #ViewTable this.viewTable
    )
    this.HasView obj
  ),

  /*-
  ビューモデルオブジェクトを追加する。
  @param obj <Struct:MwmViewModelStruct> ビューモデルオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn AddViewModel obj = (
    local viewModelName = undefined
    if this.isValidViewModel obj do (
      viewModelName = obj.GetViewModelName()
    )
    if classOf viewModelName == Name do (
      this.viewModelTable[viewModelName] = obj
      this.bindRolloutEventToView()
      this.StateChanged.Notify #ViewModelTable this.viewModelTable
    )
    this.HasViewModel obj
  ),

  /*-
  アプリケーションファイルのパスを取得する。
  @returns <String|UndefinedClass>
  */
  public fn GetApplicationFile = (
    this.applicationFile
  ),

  /*-
  アプリケーションの名前を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetApplicationName = (
    this.applicationName
  ),

  /*-
  設定オブジェクトを取得する。
  @returns <Struct:ConfigStruct|UndefinedClass>
  */
  public fn GetConfig = (
    this.config
  ),

  /*-
  モデルオブジェクトを取得する。
  @param modelName <Name> モデル名。
  @returns <Struct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetModel modelName = (
    local model = undefined
    if classOf modelName == Name and hasDictValue this.modelTable modelName do (
      model = this.modelTable[modelName]
    )
    model
  ),

  /*-
  起動時に表示されるビューの名前を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetStartupViewName = (
    this.startupViewName
  ),

  /*-
  ビューオブジェクトを取得する。
  @param viewName <Name> ビュー名。
  @returns <Struct:DialogStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetView viewName = (
    local view = undefined
    if classOf viewName == Name and hasDictValue this.viewTable viewName do (
      view = this.viewTable[viewName]
    )
    view
  ),

  /*-
  ビューモデルオブジェクトを取得する。
  @param viewModelName <Name> ビューモデル名。
  @returns <Struct:MwmViewModelStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetViewModel viewModelName = (
    local viewModel = undefined
    if classOf viewModelName == Name \
        and hasDictValue this.viewModelTable viewModelName do (
      viewModel = this.viewModelTable[viewModelName]
    )
    viewModel
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
  ビューオブジェクトが存在するかどうかを判定する。
  @param key <Struct:DialogStruct|Name> ビューオブジェクトまたはビュー名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasView key = (
    local viewName = key
    if this.isValidView key do (
      viewName = key.GetRolloutName()
    )
    classOf viewName == Name and hasDictValue this.viewTable viewName
  ),

  /*-
  ビューモデルオブジェクトが存在するかどうかを判定する。
  @param key <Struct:MwmViewModelStruct|Name> ビューモデルオブジェクトまたはビューモデル名。
  @returns <BooleanClass>
  @remarks 無効な値の場合は`false`を返す。
  */
  public fn HasViewModel key = (
    local viewModelName = key
    if this.isValidViewModel key do (
      viewModelName = key.GetViewModelName()
    )
    classOf viewModelName == Name \
        and hasDictValue this.viewModelTable viewModelName
  ),

  /*-
  設定ファイルから設定を読み込む。
  @returns <BooleanClass> 読み込みに成功した場合は`true`、失敗した場合は`false`。
  @remarks アプリケーションファイルのパスが未指定の場合は何もしない。
  */
  public fn ReadConfig = (
    local isSuccessful = false
    if this.isValidConfig this.config and this.config.Read() do (
      for modelName in this.modelTable.Keys do (
        local model = this.modelTable[modelName]
        if this.isValidModel model \
            and isProperty model #Load \
            and classOf model.Load == MAXScriptFunction do (
          model.Load this.config
        )
      )
      for viewModelName in this.viewModelTable.Keys do (
        local viewModel = this.viewModelTable[viewModelName]
        if this.isValidViewModel viewModel do (
          viewModel.Load this.config
        )
      )
      for viewName in this.viewTable.Keys do (
        local view = this.viewTable[viewName]
        if this.isValidView view do (
          view.Load this.config
        )
      )
      this.StateChanged.Notify #ConfigRead undefined
      isSuccessful = true
    )
    isSuccessful
  ),

  /*-
  アプリケーションを開始する。
  @returns <OkClass>
  */
  public fn Run = (
    this.ReadConfig()
    if classOf this.startupViewName == Name \
        and hasDictValue this.viewTable this.startupViewName do (
      local view = this.viewTable[this.startupViewName]
      if this.isValidView view do (
        local viewModel = undefined
        local rolloutDef = view.GetRolloutDef()
        if classOf rolloutDef == RolloutClass do (
          local dataContext = rolloutDef.DataContext
          if classOf dataContext == Name then (
            viewModel = this.GetViewModel dataContext
          )
          else (
            viewModel = dataContext
          )
        )
        if this.isValidViewModel viewModel do (
          if view.Create() do (
            rolloutDef.Initialize viewModel
            this.StateChanged.Notify #ApplicationRan (view.IsDisplayed())
          )
        )
      )
    )
    ok
  ),

  /*-
  アプリケーションファイルのパスを設定する。
  @param input <String|UndefinedClass>
  @returns <String|UndefinedClass>
  @remarks アプリケーションファイルの拡張子を`.mxsconfig`に変えたものが設定ファイルのパスとなる。
  */
  public fn SetApplicationFile input = (
    if (classOf input == String and ::std.FileUtility.FileExists input) \
        or classOf input == UndefinedClass do (
      this.applicationFile = input
      this.StateChanged.Notify #ApplicationFile this.applicationFile
    )
    this.initializeConfig()
    this.GetApplicationFile()
  ),

  /*-
  アプリケーションの名前を設定する。
  @param input <Name>
  @returns <Name|UndefinedClass>
  */
  public fn SetApplicationName input = (
    if classOf input == Name do (
      this.applicationName = input
      this.StateChanged.Notify #ApplicationName this.applicationName
    )
    this.GetApplicationName()
  ),

  /*-
  起動時に表示されるビューの名前を設定する。
  @param input <Name>
  @returns <Name|UndefinedClass>
  */
  public fn SetStartupViewName input = (
    if classOf input == Name do (
      this.startupViewName = input
      this.StateChanged.Notify #StartupViewName this.startupViewName
    )
    this.GetStartupViewName()
  ),

  /*-
  アプリケーションを終了する。
  @returns <OkClass>
  */
  public fn Shutdown = (
    if classOf this.startupViewName == Name \
        and hasDictValue this.viewTable this.startupViewName do (
      local view = this.viewTable[this.startupViewName]
      if this.isValidView view do (
        if view.IsDisplayed() do (
          view.Destroy()
        )
        this.StateChanged.Notify #ApplicationShutdown (view.IsDisplayed())
      )
    )
    ok
  ),

  /*-
  設定ファイルに設定を書き込む。
  @returns <BooleanClass> 書き出しに成功した場合は`true`、失敗した場合は`false`。
  @remarks アプリケーションファイルのパスが未指定の場合は何もしない。
  */
  public fn WriteConfig = (
    local isSuccessful = false
    if this.isValidConfig this.config do (
      for modelName in this.modelTable.Keys do (
        local model = this.modelTable[modelName]
        if this.isValidModel model \
            and isProperty model #Save \
            and classOf model.Save == MAXScriptFunction do (
          model.Save this.config
        )
      )
      for viewModelName in this.viewModelTable.Keys do (
        local viewModel = this.viewModelTable[viewModelName]
        if this.isValidViewModel viewModel do (
          viewModel.Save this.config
        )
      )
      for viewName in this.viewTable.Keys do (
        local view = this.viewTable[viewName]
        if this.isValidView view do (
          view.Save this.config
        )
      )
      isSuccessful = this.config.Write()
      if isSuccessful do (
        this.StateChanged.Notify #ConfigWrote undefined
      )
    )
    isSuccessful
  ),

  /*-
  `RolloutClass`のイベントをビューオブジェクトにバインドする。
  @returns <OkClass>
  */
  private fn bindRolloutEventToView = (
    for viewName in this.viewTable.Keys do (
      local view = this.viewTable[viewName]
      if this.isValidView view do (
        local viewModel = undefined
        local rolloutDef = view.GetRolloutDef()
        if classOf rolloutDef == RolloutClass do (
          local dataContext = rolloutDef.DataContext
          if classOf dataContext == Name do (
            viewModel = this.GetViewModel dataContext
          )
        )
        local viewName = view.GetRolloutName()
        if classOf viewName == Name and this.isValidViewModel viewModel do (
          local commandAttribute = this.modelAttributeDef viewName
          local closeCommand = this.commandDef \
              #RolloutClose this.onRolloutClose undefined commandAttribute
          local movedCommand = this.commandDef \
              #RolloutMoved this.onRolloutMoved undefined commandAttribute
          local openCommand = this.commandDef \
              #RolloutOpen this.onRolloutOpen undefined commandAttribute
          local resizedCommand = this.commandDef \
              #RolloutResized this.onRolloutResized undefined commandAttribute

          local closeBinding = this.bindingDef #RolloutClose rolloutDef #Close
          local movedBinding = this.bindingDef #RolloutMoved rolloutDef #Moved
          local openBinding = this.bindingDef #RolloutOpen rolloutDef #Open
          local resizedBinding = this.bindingDef #RolloutResized rolloutDef #Resized

          viewModel.AddModel viewName view
          viewModel.AddCommand closeCommand
          viewModel.AddCommand movedCommand
          viewModel.AddCommand openCommand
          viewModel.AddCommand resizedCommand
          viewModel.SetBinding closeBinding
          viewModel.SetBinding movedBinding
          viewModel.SetBinding openBinding
          viewModel.SetBinding resizedBinding
        )
      )
    )
    ok
  ),

  /*-
  設定オブジェクトを初期化する。
  @returns <OkClass>
  @remarks アプリケーションファイルのパスが未指定の場合は設定オブジェクトを作成しない。
  */
  private fn initializeConfig = (
    this.config = undefined
    if classOf this.applicationFile == String \
        and ::std.FileUtility.FileExists this.applicationFile do (
      this.config = ::std.ConfigStruct this.applicationFile
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidConfig obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #ConfigStruct
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidDialog obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #DialogStruct
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
  private fn isValidView obj = (
    local isValid = this.isValidDialog obj
    if isValid do (
      local rolloutDef = obj.GetRolloutDef()
      isValid = classOf rolloutDef == RolloutClass \
          and isProperty rolloutDef #DataContext \
          and isProperty rolloutDef #Initialize \
          and classOf rolloutDef.Initialize == MAXScriptFunction
    )
    if isValid do (
      isValid = classOf rolloutDef.DataContext == Name \
          or this.isValidViewModel rolloutDef.DataContext
    )
    isValid
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidViewModel obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmViewModelStruct
  ),

  /*-
  `RolloutClass`の`Close`イベントに対応したコマンド用関数。
  @param model <Struct:DialogStruct>
  @param params <Array[<DataPair Name:<Name> Value:<Any>>]>
  @param event <Struct:MwmEventStruct|UndefinedClass>
  @returns <OkClass>
  */
  private fn onRolloutClose model params event = (
    this.WriteConfig()
    ok
  ),

  /*-
  `RolloutClass`の`Moved`イベントに対応したコマンド用関数。
  @param model <Struct:DialogStruct>
  @param params <Array[<DataPair Name:<Name> Value:<Any>>]>
  @param event <Struct:MwmEventStruct|UndefinedClass>
  @returns <OkClass>
  */
  private fn onRolloutMoved model params event = (
    if this.isValidDialog model and this.isValidEvent event do (
      local eventParams = event.GetParams()
      if classOf eventParams == Array and eventParams.Count == 1 do (
        model.SetInitPosition eventParams[1]
      )
    )
    ok
  ),

  /*-
  `RolloutClass`の`Open`イベントに対応したコマンド用関数。
  @param model <Struct:DialogStruct>
  @param params <Array[<DataPair Name:<Name> Value:<Any>>]>
  @param event <Struct:MwmEventStruct|UndefinedClass>
  @returns <OkClass>
  */
  private fn onRolloutOpen model params event = (
    for viewModelName in this.viewModelTable.Keys do (
      local viewModel = this.viewModelTable[viewModelName]
      if this.isValidViewModel viewModel do (
        viewModel.RefreshBinding()
      )
    )
    ok
  ),

  /*-
  `RolloutClass`の`Resized`イベントに対応したコマンド用関数。
  @param model <Struct:DialogStruct>
  @param params <Array[<DataPair Name:<Name> Value:<Any>>]>
  @param event <Struct:MwmEventStruct|UndefinedClass>
  @returns <OkClass>
  */
  private fn onRolloutResized model params event = (
    if this.isValidDialog model and this.isValidEvent event do (
      local eventParams = event.GetParams()
      if classOf eventParams == Array and eventParams.Count == 1 do (
        model.SetInitSize eventParams[1]
      )
    )
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmApplicationStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmApplicationStruct\n" indent to:out
    if classOf this.applicationFile == String then (
      format "%  applicationFile:@\"%\"\n" indent this.applicationFile to:out
    )
    else (
      format "%  applicationFile:%\n" indent this.applicationFile to:out
    )
    format "%  applicationName:%\n" indent this.applicationName to:out
    if this.isValidConfig this.config then (
      format "%  config:\n" indent to:out
      this.config.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  config:%\n" indent this.config to:out
    )
    format "%  modelTable:%\n" indent this.modelTable.Count to:out
    for key in this.modelTable.Keys do (
      local model = this.modelTable[key]
      if this.isValidModel model \
          and isProperty model #StructName \
          and classOf model.StructName == MAXScriptFunction \
          and isProperty model #Dump \
          and classOf model.Dump == MAXScriptFunction then (
        format "%    [%]:\n" indent key to:out
        model.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent key model to:out
      )
    )
    format "%  startupViewName:%\n" indent this.startupViewName to:out
    format "%  viewModelTable:%\n" indent this.viewModelTable.Count to:out
    for key in this.viewModelTable.Keys do (
      local viewModel = this.viewModelTable[key]
      if this.isValidViewModel viewModel then (
        format "%    [%]:\n" indent key to:out
        viewModel.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent key viewModel to:out
      )
    )
    format "%  viewTable:%\n" indent this.viewTable.Count to:out
    for key in this.viewTable.Keys do (
      local view = this.viewTable[key]
      if this.isValidView view then (
        format "%    [%]:\n" indent key to:out
        view.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent key view to:out
      )
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  `applicationFile`、`applicationName`、`startupViewName`のみ比較する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    local isEqualProperties = true \
        and isProperty obj #GetApplicationFile \
        and classOf obj.GetApplicationFile == MAXScriptFunction \
        and obj.GetApplicationFile() == this.GetApplicationFile() \
        and isProperty obj #GetApplicationName \
        and classOf obj.GetApplicationName == MAXScriptFunction \
        and obj.GetApplicationName() == this.GetApplicationName() \
        and isProperty obj #GetStartupViewName \
        and classOf obj.GetStartupViewName == MAXScriptFunction \
        and obj.GetStartupViewName() == this.GetStartupViewName()

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
    this.bindingDef = ::mwmDefinitionPool[@"Model\MwmBinding.ms"]
    this.commandDef = ::mwmDefinitionPool[@"Model\MwmCommand.ms"]
    this.modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
    this.modelTable = Dictionary #Name
    this.viewModelTable = Dictionary #Name
    this.viewTable = Dictionary #Name
    this.SetApplicationName this._CP1_
    this.SetStartupViewName this._CP2_
    this.SetApplicationFile this._CP3_
  )
)
