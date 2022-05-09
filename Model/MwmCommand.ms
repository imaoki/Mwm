/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ビューモデルにコマンドを定義するための構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmCommandStruct commandName executeFunction canExecuteFunction modelAttribute
```

通知
:   | 通知名                  | 通知データ                     | タイミング                                     |
    | ----------------------- | ------------------------------ | ---------------------------------------------- |
    | `#CanExecuteChanged`    | `CanExecute`メソッドの戻り値   | `RaiseCanExecuteChanged`メソッドが呼ばれた直後 |
    | `#CanExecuteFunction`   | 新たな`canExecuteFunction`値   | `canExecuteFunction`を設定した後               |
    | `#CanExecuteProperties` | 新たな`canExecuteProperties`値 | `canExecuteProperties`を設定した後             |
    | `#CommandName`          | 新たな`commandName`値          | `commandName`を設定した後                      |
    | `#ExecuteFunction`      | 新たな`executeFunction`値      | `executeFunction`を設定した後                  |
    | `#ExecuteProperties`    | 新たな`executeProperties`値    | `executeProperties`を設定した後                |
    | `#Model`                | 新たな`model`値                | `model`を設定した後                            |
    | `#PostProcessFunction`  | 新たな`postProcessFunction`値  | `postProcessFunction`を設定した後              |
    | `#PreProcessFunction`   | 新たな`preProcessFunction`値   | `preProcessFunction`を設定した後               |

オブザーバ
:   | 購読先                                                 | メソッド                 |
    | ------------------------------------------------------ | ------------------------ |
    | `canExecuteProperties`に追加したプロパティオブジェクト | `RaiseCanExecuteChanged` |
*/
struct MwmCommandStruct (
  /*- @prop <Name> 作成パラメータ1。コマンド名。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <MAXScriptFunction|UndefinedClass> 作成パラメータ2。コマンドの内容を定義した関数。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <MAXScriptFunction|UndefinedClass> 作成パラメータ3。コマンドが実行可能かどうかを判定する関数。既定値は`undefined`。 */
  public _CP3_,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> 作成パラメータ4。モデル属性。既定値は`undefined`。 */
  public _CP4_,

  /*- @prop <MAXScriptFunction|UndefinedClass> コマンドが実行可能かどうかを判定する関数。既定値は`undefined`。 */
  private canExecuteFunction,
  /*- @prop <Array[<Struct:MwmPropertyStruct>]> コマンドが実行可能かどうかの判定に使用するプロパティ。既定値は`#()`。 */
  private canExecuteProperties = #(),
  /*- @prop <Name> コマンド名。バインディングのソース名。既定値は`undefined`。 */
  private commandName,
  /*- @prop <MAXScriptFunction|UndefinedClass> コマンドの内容を定義した関数。既定値は`undefined`。 */
  private executeFunction,
  /*- @prop <Array[<Struct:MwmPropertyStruct>]> コマンドで使用するプロパティ。既定値は`#()`。 */
  private executeProperties = #(),
  /*- @prop <Struct|UndefinedClass> モデルオブジェクト。既定値は`undefined`。 */
  private model,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> モデル属性。既定値は`undefined`。 */
  private modelAttribute,
  /*- @prop <MAXScriptFunction|UndefinedClass> コマンドを実行する後に呼び出される関数。既定値は`undefined`。 */
  private postProcessFunction,
  /*- @prop <MAXScriptFunction|UndefinedClass> コマンドを実行する前に呼び出される関数。既定値は`undefined`。 */
  private preProcessFunction,

  /*
  public fn AddCanExecuteProperty property = (),
  public fn AddExecuteProperty property = (),
  public fn CanExecute = (),
  public fn Execute = (),
  public fn GetCanExecuteFunction = (),
  public fn GetCanExecuteProperties = (),
  public fn GetCanExecuteProperty propertyName = (),
  public fn GetCanExecutePropertyNames = (),
  public fn GetCommandName = (),
  public fn GetExecuteFunction = (),
  public fn GetExecuteProperties = (),
  public fn GetExecuteProperty propertyName = (),
  public fn GetExecutePropertyNames = (),
  public fn GetModel = (),
  public fn GetModelAttribute = (),
  public fn GetPostProcessFunction = (),
  public fn GetPreProcessFunction = (),
  public fn HasCanExecuteProperty key = (),
  public fn HasExecuteProperty key = (),
  public fn RaiseCanExecuteChanged type param = (),
  public fn SetCanExecuteFunction input = (),
  public fn SetCommandName input = (),
  public fn SetExecuteFunction input = (),
  public fn SetModel obj = (),
  public fn SetModelAttribute obj = (),
  public fn SetPostProcessFunction input = (),
  public fn SetPreProcessFunction input = (),

  private fn findProperty properties property = (),
  private fn findPropertyByName properties propertyName = (),
  private fn getPropertyByName properties propertyName = (),
  private fn isValidFunction obj = (),
  private fn isValidModel obj = (),
  private fn isValidModelAttribute obj = (),
  private fn isValidObservable obj = (),
  private fn isValidProperty obj = (),
  private fn propertiesAsNames properties = (),
  private fn propertiesAsParams properties = (),
  */

  /*-
  コマンドが実行可能かどうかの判定に使用するプロパティを追加する。
  @param property <Struct:MwmPropertyStruct> プロパティオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は何もしない。
  */
  public fn AddCanExecuteProperty property = (
    if this.isValidProperty property do (
      if this.findProperty this.canExecuteProperties property == 0 do (
        append this.canExecuteProperties property
        if this.isValidObservable property.StateChanged do (
          property.StateChanged.Subscribe this.RaiseCanExecuteChanged
        )
        this.StateChanged.Notify #CanExecuteProperties this.canExecuteProperties
      )
    )
    this.findProperty this.canExecuteProperties property > 0
  ),

  /*-
  コマンドの実行に使用するプロパティを追加する。
  @param property <Struct:MwmPropertyStruct> プロパティオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は何もしない。
  */
  public fn AddExecuteProperty property = (
    if this.isValidProperty property do (
      if this.findProperty this.executeProperties property == 0 do (
        append this.executeProperties property
        this.StateChanged.Notify #ExecuteProperties this.executeProperties
      )
    )
    this.findProperty this.executeProperties property > 0
  ),

  /*-
  コマンドが実行可能かどうかを判定する。
  @returns <BooleanClass>
  @remarks `canExecuteFunction`が未指定の場合は`true`を返す。
  */
  public fn CanExecute = (
    local result = true
    if this.isValidFunction this.canExecuteFunction do (
      local params = this.propertiesAsParams this.canExecuteProperties
      result = this.canExecuteFunction params
      if classOf result != BooleanClass do (
        result = true
      )
    )
    result
  ),

  /*-
  コマンドを実行する。
  @param event <Struct:MwmEventStruct|UndefinedClass> イベント情報。
  @returns <OkClass>
  */
  public fn Execute event = (
    if this.CanExecute() do (
      local params = this.propertiesAsParams this.executeProperties
      if this.isValidFunction this.preProcessFunction do (
        this.preProcessFunction this.model params event
      )
      if this.isValidFunction this.executeFunction do (
        this.executeFunction this.model params event
      )
      if this.isValidFunction this.postProcessFunction do (
        this.postProcessFunction this.model params event
      )
    )
    ok
  ),

  /*-
  コマンドが実行可能かどうかを判定する関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetCanExecuteFunction = (
    this.canExecuteFunction
  ),

  /*-
  コマンドが実行可能かどうかの判定に使用するプロパティを全て取得する。
  @returns <Array[<Struct:MwmPropertyStruct>]>
  */
  public fn GetCanExecuteProperties = (
    this.canExecuteProperties
  ),

  /*-
  コマンドが実行可能かどうかの判定に使用するプロパティを取得する。
  @param propertyName <Name> プロパティ名。
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetCanExecuteProperty propertyName = (
    this.getPropertyByName this.canExecuteProperties propertyName
  ),

  /*-
  コマンドが実行可能かどうかの判定に使用するプロパティのプロパティ名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetCanExecutePropertyNames = (
    this.propertiesAsNames this.canExecuteProperties
  ),

  /*-
  コマンド名を取得する。
  @returns <Name>
  */
  public fn GetCommandName = (
    this.commandName
  ),

  /*-
  コマンドの内容を定義した関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetExecuteFunction = (
    this.executeFunction
  ),

  /*-
  コマンドで使用するプロパティを全て取得する。
  @returns <Array[<Struct:MwmPropertyStruct>]>
  */
  public fn GetExecuteProperties = (
    this.executeProperties
  ),

  /*-
  コマンドで使用するプロパティを取得する。
  @param propertyName <Name> プロパティ名。
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetExecuteProperty propertyName = (
    this.getPropertyByName this.executeProperties propertyName
  ),

  /*-
  コマンドで使用するプロパティのプロパティ名を取得する。
  @returns <Array[<Name>]>
  */
  public fn GetExecutePropertyNames = (
    this.propertiesAsNames this.executeProperties
  ),

  /*-
  モデルオブジェクトを取得する。
  @returns <Struct|UndefinedClass>
  */
  public fn GetModel = (
    this.model
  ),

  /*-
  モデル属性を取得する。
  @returns <Struct:MwmModelAttributeStruct|UndefinedClass>
  */
  public fn GetModelAttribute = (
    this.modelAttribute
  ),

  /*-
  コマンドを実行する後に呼び出される関数を設定する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetPostProcessFunction = (
    this.postProcessFunction
  ),

  /*-
  コマンドを実行する前に呼び出される関数を設定する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetPreProcessFunction = (
    this.preProcessFunction
  ),

  /*-
  コマンドが実行可能かどうかの判定に使用するプロパティが登録済みかどうかを判定する。
  @param key <Struct:MwmPropertyStruct|Name> プロパティオブジェクトまたはプロパティ名。
  @returns <BooleanClass>
  */
  public fn HasCanExecuteProperty key = (
    local propertyName = key
    if this.isValidProperty key do (
      propertyName = key.GetPropertyName()
    )
    this.findPropertyByName this.canExecuteProperties propertyName > 0
  ),

  /*-
  コマンドで使用するプロパティが登録済みかどうかを判定する。
  @param key <Struct:MwmPropertyStruct|Name> プロパティオブジェクトまたはプロパティ名。
  @returns <BooleanClass>
  */
  public fn HasExecuteProperty key = (
    local propertyName = key
    if this.isValidProperty key do (
      propertyName = key.GetPropertyName()
    )
    this.findPropertyByName this.executeProperties propertyName > 0
  ),

  /*-
  コマンドが実行可能かどうかの変更通知を発行する。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  */
  public fn RaiseCanExecuteChanged type param = (
    case type of (
      (#PropertyValue): (
        this.CanExecuteChanged.Notify #CanExecuteChanged (this.CanExecute())
      )
      default: ()
    )
    ok
  ),

  /*-
  コマンドが実行可能かどうかを判定する関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  指定する関数は次のように実装する。

  ```maxscript
  fn exampleCanExecuteFunction params = (
    params.Count == 2 \
        and params[1].Name == #Foo and params[1].Value == 0 \
        and params[2].Name == #Bar and params[2].Value == 1
  )
  ```

  * 引数はプロパティ名とプロパティ値のペアの配列を一つ取る。

    | 引数     | 型                                            |
    | -------- | --------------------------------------------- |
    | `params` | `<Array[<DataPair Name:<Name> Value:<Any>>]>` |

  * 真偽値を返す。既定の戻り値は`false`。
  */
  public fn SetCanExecuteFunction input = (
    if this.isValidFunction input do (
      this.canExecuteFunction = input
      this.StateChanged.Notify #CanExecuteFunction this.canExecuteFunction
    )
    this.GetCanExecuteFunction()
  ),

  /*-
  コマンド名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetCommandName input = (
    if classOf input == Name do (
      this.commandName = input
      this.StateChanged.Notify #CommandName this.commandName
    )
    this.GetCommandName()
  ),

  /*-
  コマンドの内容を定義した関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  指定する関数は次のように実装する。

  ```maxscript
  fn exampleExecuteFunction model params event = (
    model.Foo params[1].Value params[2].Value
    ok
  )
  ```

  * 第一引数にコマンドに関連付けられたモデルオブジェクト、第二引数にプロパティ名とプロパティ値のペアの配列を取る。

    | 引数     | 型                                            |
    | -------- | --------------------------------------------- |
    | `model`  | `<Struct>`                                    |
    | `params` | `<Array[<DataPair Name:<Name> Value:<Any>>]>` |
    | `event`  | `<Struct:MwmEventStruct|UndefinedClass>`      |

  * 任意の値を返す。
  */
  public fn SetExecuteFunction input = (
    if this.isValidFunction input do (
      this.executeFunction = input
      this.StateChanged.Notify #ExecuteFunction this.executeFunction
    )
    this.GetExecuteFunction()
  ),

  /*-
  モデルオブジェクトを設定する。
  @param obj <Struct|UndefinedClass>
  @returns <Struct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetModel obj = (
    if this.isValidModel obj or classOf obj == UndefinedClass do (
      this.model = obj
      this.StateChanged.Notify #Model this.model
    )
    this.GetModel()
  ),

  /*-
  モデル属性を設定する。
  @param obj <Struct:MwmModelAttributeStruct|UndefinedClass>
  @returns <Struct:MwmModelAttributeStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetModelAttribute obj = (
    if this.isValidModelAttribute obj or classOf obj == UndefinedClass do (
      this.modelAttribute = obj
      this.StateChanged.Notify #ModelAttribute this.modelAttribute
    )
    this.GetModelAttribute()
  ),

  /*-
  コマンドを実行する後に呼び出される関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  指定する関数は`SetExecuteFunction`と同様に実装する。
  */
  public fn SetPostProcessFunction input = (
    if this.isValidFunction input do (
      this.postProcessFunction = input
      this.StateChanged.Notify #PostProcessFunction this.postProcessFunction
    )
    this.GetPostProcessFunction()
  ),

  /*-
  コマンドを実行する前に呼び出される関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  指定する関数は`SetExecuteFunction`と同様に実装する。
  */
  public fn SetPreProcessFunction input = (
    if this.isValidFunction input do (
      this.preProcessFunction = input
      this.StateChanged.Notify #PreProcessFunction this.preProcessFunction
    )
    this.GetPreProcessFunction()
  ),

  /*-
  プロパティを検索する。
  @param properties <Array[<Struct:MwmPropertyStruct>]>
  @param property <Struct:MwmPropertyStruct>
  @returns <Integer>
  */
  private fn findProperty properties property = (
    local index = 0
    if this.isValidProperty property do (
      index = this.findPropertyByName properties (property.GetPropertyName())
    )
    index
  ),

  /*-
  プロパティ名でプロパティを検索する。
  @param properties <Array[<Struct:MwmPropertyStruct>]>
  @param propertyName <Name>
  @returns <Integer>
  */
  private fn findPropertyByName properties propertyName = (
    local index = 0
    if classOf propertyName == Name do (
      for i = 1 to properties.Count while index == 0 do (
        if this.isValidProperty properties[i] \
            and properties[i].GetPropertyName() == propertyName do (
          index = i
        )
      )
    )
    index
  ),

  /*-
  プロパティ名からプロパティを取得する。
  @param properties <Array[<Struct:MwmPropertyStruct>]>
  @param propertyName <Name>
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  */
  private fn getPropertyByName properties propertyName = (
    local property = undefined
    local index = this.findPropertyByName properties propertyName
    if 1 <= index and index <= properties.Count do (
      property = properties[index]
    )
    property
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidFunction obj = (
    classOf obj == MAXScriptFunction
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
  private fn isValidObservable obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #ObservableStruct
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
  プロパティ配列をプロパティ名の配列に変換する。
  @param properties <Array[<Struct:MwmPropertyStruct>]>
  @returns <Array[<Name>]>
  */
  private fn propertiesAsNames properties = (
    for property in properties where this.isValidProperty property collect (
      property.GetPropertyName()
    )
  ),

  /*-
  プロパティ配列をプロパティ名とプロパティ値のペアの配列に変換する。
  @param properties <Array[<Struct:MwmPropertyStruct>]>
  @returns <Array[<DataPair Name:<Name> Value:<Any>>]>
  */
  private fn propertiesAsParams properties = (
    for property in properties where this.isValidProperty property collect (
      local propertyName = property.GetPropertyName()
      local propertyValue = property.GetPropertyValue()
      DataPair Name:propertyName Value:propertyValue
    )
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmCommandStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmCommandStruct\n" indent to:out
    format "%  canExecuteFunction:%\n" indent this.canExecuteFunction to:out
    format "%  canExecuteProperties:%\n" indent this.canExecuteProperties.Count to:out
    for i = 1 to this.canExecuteProperties.Count do (
      format "%    [%]:\n" indent i to:out
      this.canExecuteProperties[i].Dump indent:(indent + "      ") out:out
    )
    format "%  commandName:%\n" indent this.commandName to:out
    format "%  executeFunction:%\n" indent this.executeFunction to:out
    format "%  executeProperties:%\n" indent this.executeProperties.Count to:out
    for i = 1 to this.executeProperties.Count do (
      format "%    [%]:\n" indent i to:out
      this.executeProperties[i].Dump indent:(indent + "      ") out:out
    )
    if this.isValidModel this.model \
        and isProperty this.model #StructName \
        and classOf this.model.StructName == MAXScriptFunction \
        and isProperty this.model #Dump \
        and classOf this.model.Dump == MAXScriptFunction then (
      format "%  model:\n" indent to:out
      this.model.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  model:%\n" indent this.model to:out
    )
    if this.isValidModelAttribute this.modelAttribute then (
      format "%  modelAttribute:\n" indent to:out
      this.modelAttribute.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  modelAttribute:%\n" indent this.modelAttribute to:out
    )
    format "%  postProcessFunction:%\n" indent this.postProcessFunction to:out
    format "%  preProcessFunction:%\n" indent this.preProcessFunction to:out
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
        and isProperty obj #GetCanExecuteFunction \
        and classOf obj.GetCanExecuteFunction == MAXScriptFunction \
        and obj.GetCanExecuteFunction() == this.GetCanExecuteFunction() \
        and isProperty obj #GetCanExecuteProperties \
        and classOf obj.GetCanExecuteProperties == MAXScriptFunction \
        and isProperty obj #GetCommandName \
        and classOf obj.GetCommandName == MAXScriptFunction \
        and obj.GetCommandName() == this.GetCommandName() \
        and isProperty obj #GetExecuteFunction \
        and classOf obj.GetExecuteFunction == MAXScriptFunction \
        and obj.GetExecuteFunction() == this.GetExecuteFunction() \
        and isProperty obj #GetExecuteProperties \
        and classOf obj.GetExecuteProperties == MAXScriptFunction \
        and isProperty obj #GetModel \
        and classOf obj.GetModel == MAXScriptFunction \
        and isProperty obj #GetModelAttribute \
        and classOf obj.GetModelAttribute == MAXScriptFunction \
        and isProperty obj #GetPostProcessFunction \
        and classOf obj.GetPostProcessFunction == MAXScriptFunction \
        and obj.GetPostProcessFunction() == this.GetPostProcessFunction() \
        and isProperty obj #GetPreProcessFunction \
        and classOf obj.GetPreProcessFunction == MAXScriptFunction \
        and obj.GetPreProcessFunction() == this.GetPreProcessFunction()

    if isEqualProperties do (
      local ov = obj.GetCanExecuteProperties()
      local tv = this.GetCanExecuteProperties()
      isEqualProperties = classOf ov == Array and classOf tv == Array
      if isEqualProperties do (
        isEqualProperties = ov.Count == tv.Count
      )
      if isEqualProperties do (
        for i = 1 to tv.Count while isEqualProperties do (
          isEqualProperties = this.isValidProperty tv[i] and tv[i].Equals ov[i]
        )
      )
    )

    if isEqualProperties do (
      local ov = obj.GetExecuteProperties()
      local tv = this.GetExecuteProperties()
      isEqualProperties = classOf ov == Array and classOf tv == Array
      if isEqualProperties do (
        isEqualProperties = ov.Count == tv.Count
      )
      if isEqualProperties do (
        for i = 1 to tv.Count while isEqualProperties do (
          isEqualProperties = this.isValidProperty tv[i] and tv[i].Equals ov[i]
        )
      )
    )

    if isEqualProperties do (
      local ov = obj.GetModel()
      local tv = this.GetModel()
      if this.isValidModel tv \
          and isProperty tv #Equals \
          and classOf tv.Equals == MAXScriptFunction then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
      )
    )

    if isEqualProperties do (
      local ov = obj.GetModelAttribute()
      local tv = this.GetModelAttribute()
      if this.isValidModelAttribute tv then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
      )
    )

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public CanExecuteChanged,
  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.CanExecuteChanged = ::std.ObservableStruct()
    this.StateChanged = ::std.ObservableStruct()
    this.SetCommandName this._CP1_
    this.SetExecuteFunction this._CP2_
    this.SetCanExecuteFunction this._CP3_
    this.SetModelAttribute this._CP4_
  )
)
