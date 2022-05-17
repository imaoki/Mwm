/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ビューモデルにコマンドを定義するための構造体。
@remarks 作成パラメータ
:   ```maxscript
    ::MwmCommandStruct commandName executeFunction [modelAttribute] [executeCondition] [canExecuteCondition]
    ```

通知
:   | 通知名                 | 通知データ                    | タイミング                                     |
    | ---------------------- | ----------------------------- | ---------------------------------------------- |
    | `#CanExecuteChanged`   | `CanExecute`メソッドの戻り値  | `RaiseCanExecuteChanged`メソッドが呼ばれた直後 |
    | `#CanExecuteCondition` | 新たな`canExecuteCondition`値 | `canExecuteCondition`を設定した後              |
    | `#CommandName`         | 新たな`commandName`値         | `commandName`を設定した後                      |
    | `#ExecuteCondition`    | 新たな`executeCondition`値    | `executeCondition`を設定した後                 |
    | `#ExecuteFunction`     | 新たな`executeFunction`値     | `executeFunction`を設定した後                  |
    | `#Model`               | 新たな`model`値               | `model`を設定した後                            |
    | `#ModelAttribute`      | 新たな`modelAttribute`値      | `modelAttribute`を設定した後                   |

オブザーバ
:   | 購読先                                          | メソッド                 |
    | ----------------------------------------------- | ------------------------ |
    | `canExecuteCondition`に設定した条件オブジェクト | `RaiseCanExecuteChanged` |
*/
struct MwmCommandStruct (
  /*- @prop <Name> 作成パラメータ1。コマンド名。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <MAXScriptFunction|UndefinedClass> 作成パラメータ2。コマンドの内容を定義した関数。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> 作成パラメータ3。モデル属性。既定値は`undefined`。 */
  public _CP3_,
  /*- @prop <Struct:MwmConditionStruct|UndefinedClass> 作成パラメータ4。コマンドで使用するプロパティを格納した条件オブジェクト。既定値は`undefined`。 */
  public _CP4_,
  /*- @prop <Struct:MwmConditionStruct|UndefinedClass> 作成パラメータ5。コマンドが実行可能かどうかを判定する条件オブジェクト。既定値は`undefined`。 */
  public _CP5_,

  /*- @prop <Struct:MwmConditionStruct|UndefinedClass> コマンドが実行可能かどうかを判定する条件オブジェクト。既定値は`undefined`。 */
  private canExecuteCondition,
  /*- @prop <Name> コマンド名。バインディングのソース名。既定値は`undefined`。 */
  private commandName,
  /*- @prop <Struct:MwmConditionStruct|UndefinedClass> コマンドで使用するプロパティを格納した条件オブジェクト。既定値は`undefined`。 */
  private executeCondition,
  /*- @prop <MAXScriptFunction|UndefinedClass> コマンドの内容を定義した関数。既定値は`undefined`。 */
  private executeFunction,
  /*- @prop <Struct|UndefinedClass> モデルオブジェクト。既定値は`undefined`。 */
  private model,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> モデル属性。既定値は`undefined`。 */
  private modelAttribute,

  /*
  public fn CanExecute = (),
  public fn Execute = (),
  public fn GetCanExecuteCondition = (),
  public fn GetCommandName = (),
  public fn GetExecuteCondition = (),
  public fn GetExecuteFunction = (),
  public fn GetModel = (),
  public fn GetModelAttribute = (),
  public fn RaiseCanExecuteChanged type param = (),
  public fn SetCanExecuteCondition condition = (),
  public fn SetCommandName input = (),
  public fn SetExecuteCondition condition = (),
  public fn SetExecuteFunction input = (),
  public fn SetModel obj = (),
  public fn SetModelAttribute obj = (),

  private fn isValidCondition obj = (),
  private fn isValidFunction obj = (),
  private fn isValidModel obj = (),
  private fn isValidModelAttribute obj = (),
  private fn isValidObservable obj = (),
  private fn isValidProperty obj = (),
  private fn subscribeCanExecuteCondition = (),
  private fn unsubscribeCanExecuteCondition = (),
  */

  /*-
  コマンドが実行可能かどうかを判定する。
  @returns <BooleanClass>
  @remarks 条件式が真偽値以外を返した場合は`true`を返す。
  */
  public fn CanExecute = (
    local result = true
    if this.isValidCondition this.canExecuteCondition do (
      result = this.canExecuteCondition.Evaluate()
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
      local params = #()
      if this.isValidCondition this.executeCondition do (
        params = this.executeCondition.MakeParams()
      )
      if this.isValidFunction this.executeFunction do (
        this.executeFunction this.model params event
      )
    )
    ok
  ),

  /*-
  コマンドが実行可能かどうかを判定する条件オブジェクトを取得する。
  @returns <Struct:MwmConditionStruct|UndefinedClass>
  */
  public fn GetCanExecuteCondition = (
    this.canExecuteCondition
  ),

  /*-
  コマンド名を取得する。
  @returns <Name>
  */
  public fn GetCommandName = (
    this.commandName
  ),

  /*-
  コマンドで使用するプロパティを格納した条件オブジェクトを取得する。
  @returns <Struct:MwmConditionStruct|UndefinedClass>
  */
  public fn GetExecuteCondition = (
    this.executeCondition
  ),

  /*-
  コマンドの内容を定義した関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetExecuteFunction = (
    this.executeFunction
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
  コマンドが実行可能かどうかの変更通知を発行する。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  */
  public fn RaiseCanExecuteChanged type param = (
    case type of (
      (#ConditionChanged): (
        this.CanExecuteChanged.Notify #CanExecuteChanged (this.CanExecute())
      )
      default: ()
    )
    ok
  ),

  /*-
  コマンドが実行可能かどうかを判定する条件オブジェクトを設定する。
  @param condition <Struct:MwmConditionStruct>
  @returns <Struct:MwmConditionStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetCanExecuteCondition condition = (
    if this.isValidCondition condition do (
      this.unsubscribeCanExecuteCondition()
      this.canExecuteCondition = condition
      this.subscribeCanExecuteCondition()
      this.StateChanged.Notify #CanExecuteCondition this.canExecuteCondition
    )
    this.GetCanExecuteCondition()
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
  コマンドで使用するプロパティを格納した条件オブジェクトを設定する。
  @param condition <Struct:MwmConditionStruct>
  @returns <Struct:MwmConditionStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetExecuteCondition condition = (
    if this.isValidCondition condition do (
      this.executeCondition = condition
      this.StateChanged.Notify #ExecuteCondition this.executeCondition
    )
    this.GetExecuteCondition()
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
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidCondition obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmConditionStruct
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
  コマンドが実行可能かどうかを判定する条件オブジェクトを購読する。
  @returns <OkClass>
  */
  private fn subscribeCanExecuteCondition = (
    if this.isValidCondition this.canExecuteCondition \
        and this.isValidObservable this.canExecuteCondition.StateChanged do (
      this.canExecuteCondition.StateChanged.Subscribe this.RaiseCanExecuteChanged
    )
    ok
  ),

  /*-
  コマンドが実行可能かどうかを判定する条件オブジェクトの購読を解除する。
  @returns <OkClass>
  */
  private fn unsubscribeCanExecuteCondition = (
    if this.isValidCondition this.canExecuteCondition \
        and this.isValidObservable this.canExecuteCondition.StateChanged do (
      this.canExecuteCondition.StateChanged.Unsubscribe this.RaiseCanExecuteChanged
    )
    ok
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
    if this.isValidCondition this.canExecuteCondition then (
      format "%  canExecuteCondition:\n" indent to:out
      this.canExecuteCondition.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  canExecuteCondition:%\n" indent this.canExecuteCondition to:out
    )
    format "%  commandName:%\n" indent this.commandName to:out
    if this.isValidCondition this.executeCondition then (
      format "%  executeCondition:\n" indent to:out
      this.executeCondition.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  executeCondition:%\n" indent this.executeCondition to:out
    )
    format "%  executeFunction:%\n" indent this.executeFunction to:out
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
        and isProperty obj #GetCanExecuteCondition \
        and classOf obj.GetCanExecuteCondition == MAXScriptFunction \
        and isProperty obj #GetCommandName \
        and classOf obj.GetCommandName == MAXScriptFunction \
        and obj.GetCommandName() == this.GetCommandName() \
        and isProperty obj #GetExecuteCondition \
        and classOf obj.GetExecuteCondition == MAXScriptFunction \
        and isProperty obj #GetExecuteFunction \
        and classOf obj.GetExecuteFunction == MAXScriptFunction \
        and obj.GetExecuteFunction() == this.GetExecuteFunction() \
        and isProperty obj #GetModel \
        and classOf obj.GetModel == MAXScriptFunction \
        and isProperty obj #GetModelAttribute \
        and classOf obj.GetModelAttribute == MAXScriptFunction

    if isEqualProperties do (
      local ov = obj.GetCanExecuteCondition()
      local tv = this.GetCanExecuteCondition()
      if this.isValidCondition tv then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
      )
    )

    if isEqualProperties do (
      local ov = obj.GetExecuteCondition()
      local tv = this.GetExecuteCondition()
      if this.isValidCondition tv then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
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
    this.SetModelAttribute this._CP3_
    this.SetExecuteCondition this._CP4_
    this.SetCanExecuteCondition this._CP5_
  )
)
