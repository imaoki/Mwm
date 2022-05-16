/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
プロパティ値の条件式を定義する構造体。
@remarks 作成パラメータ
:   ```maxscript
    ::MwmConditionStruct evaluator
    ```

通知
:   | 通知名              | 通知データ                       | タイミング                               |
    | ------------------- | -------------------------------- | ---------------------------------------- |
    | `#ConditionChanged` | 新たなプロパティオブジェクトの値 | プロパティオブジェクトの値が変更された後 |
    | `#Evaluator`        | 新たな`evaluator`値              | `evaluator`を設定した後                  |
    | `#Properties`       | 新たな`properties`値             | `properties`を設定した後                 |

オブザーバ
:   | 購読先                                       | メソッド               |
    | -------------------------------------------- | ---------------------- |
    | `properties`に追加したプロパティオブジェクト | `PropertyValueChanged` |
*/
struct MwmConditionStruct (
  /*- @prop <MAXScriptFunction> 作成パラメータ1。条件式を定義した関数。既定値は`undefined`。 */
  public _CP1_,

  /*- @prop <MAXScriptFunction> 条件式を定義した関数。既定値は`undefined`。 */
  private evaluator,
  /*- @prop <Array[<Struct:MwmPropertyStruct>]> 条件となるプロパティオブジェクト。既定値は`#()`。 */
  private properties = #(),

  /*
  public fn AddProperty property = (),
  public fn Evaluate = (),
  public fn GetEvaluator = (),
  public fn GetProperties = (),
  public fn GetProperty propertyName = (),
  public fn GetPropertyNames = (),
  public fn HasProperty key = (),
  public fn MakeParams = (),
  public fn PropertyValueChanged type param = (),
  public fn RemoveProperty key = (),
  public fn SetEvaluator input = (),

  private fn findProperty property = (),
  private fn findPropertyByName propertyName = (),
  private fn isValidFunction obj = (),
  private fn isValidProperty obj = (),
  */

  /*-
  条件となるプロパティオブジェクトを追加する。
  @param property <Struct:MwmPropertyStruct> プロパティオブジェクト。
  @returns <BooleanClass> 追加に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は何もしない。
  */
  public fn AddProperty property = (
    if this.isValidProperty property and not this.HasProperty property do (
      append this.properties property
      property.StateChanged.Subscribe this.PropertyValueChanged
      this.StateChanged.Notify #Properties this.properties
    )
    this.HasProperty property
  ),

  /*-
  条件式を評価する。
  @returns <Any>
  */
  public fn Evaluate = (
    local result = undefined
    if this.isValidFunction this.evaluator do (
      result = this.evaluator (this.MakeParams())
    )
    result
  ),

  /*-
  条件式を定義した関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetEvaluator = (
    this.evaluator
  ),

  /*-
  条件となるプロパティオブジェクトを全て取得する。
  @returns <Array[<Struct:MwmPropertyStruct>]>
  */
  public fn GetProperties = (
    this.properties
  ),

  /*-
  条件となるプロパティオブジェクトを取得する。
  @param propertyName <Name> プロパティ名。
  @returns <Struct:MwmPropertyStruct|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn GetProperty propertyName = (
    local property = undefined
    local index = this.findPropertyByName propertyName
    if 1 <= index and index <= this.properties.Count do (
      property = this.properties[index]
    )
    property
  ),

  /*-
  条件となるプロパティオブジェクトのプロパティ名を全て取得する。
  @returns <Array[<Name>]>
  */
  public fn GetPropertyNames = (
    for property in this.properties where this.isValidProperty property collect (
      property.GetPropertyName()
    )
  ),

  /*-
  条件となるプロパティオブジェクトが登録済みかどうかを判定する。
  @param key <Struct:MwmPropertyStruct|Name> プロパティオブジェクトまたはプロパティ名。
  @returns <BooleanClass>
  */
  public fn HasProperty key = (
    local propertyName = key
    if this.isValidProperty key do (
      propertyName = key.GetPropertyName()
    )
    this.findPropertyByName propertyName > 0
  ),

  /*-
  登録したプロパティオブジェクトからプロパティ名とプロパティ値のペアの配列を作成する。
  @returns <Array[<DataPair Name:<Name> Value:<Any>>]>
  */
  public fn MakeParams = (
    for property in this.properties where this.isValidProperty property collect (
      local propertyName = property.GetPropertyName()
      local propertyValue = property.GetPropertyValue()
      DataPair Name:propertyName Value:propertyValue
    )
  ),

  /*-
  登録したプロパティオブジェクトの変更通知を発行する。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  */
  public fn PropertyValueChanged type param = (
    case type of (
      (#PropertyValue): this.StateChanged.Notify #ConditionChanged param
      default: ()
    )
    ok
  ),

  /*-
  条件となるプロパティオブジェクトを除去する。
  @returns <BooleanClass> 除去に成功した場合は`true`、失敗した場合は`false`。
  @remarks 無効な値の場合は何もしない。
  */
  public fn RemoveProperty key = (
    local propertyName = key
    if this.isValidProperty key do (
      propertyName = key.GetPropertyName()
    )
    local index = this.findPropertyByName propertyName
    if 1 <= index and index <= this.properties.Count do (
      local property = this.properties[index]
      if this.isValidProperty property do (
        property.StateChanged.Unsubscribe this.PropertyValueChanged
      )
      deleteItem this.properties index
      this.StateChanged.Notify #Properties this.properties
    )
    not this.HasProperty key
  ),

  /*-
  条件式を定義した関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  指定する関数は次のように実装する。

  ```maxscript
  fn exampleEvaluator params = (
    params.Count == 2 \
        and params[1].Name == #Foo and params[1].Value == 0 \
        and params[2].Name == #Bar and params[2].Value == 1
  )
  ```

  * 引数はプロパティ名とプロパティ値のペアの配列を一つ取る。

    | 引数     | 型                                            |
    | -------- | --------------------------------------------- |
    | `params` | `<Array[<DataPair Name:<Name> Value:<Any>>]>` |
  */
  public fn SetEvaluator input = (
    if this.isValidFunction input or classOf input == UndefinedClass do (
      this.evaluator = input
      this.StateChanged.Notify #Evaluator this.evaluator
    )
    this.GetEvaluator()
  ),

  /*-
  プロパティを検索する。
  @param property <Struct:MwmPropertyStruct>
  @returns <Integer>
  */
  private fn findProperty property = (
    local index = 0
    if this.isValidProperty property do (
      index = this.findPropertyByName (property.GetPropertyName())
    )
    index
  ),

  /*-
  プロパティ名でプロパティを検索する。
  @param propertyName <Name>
  @returns <Integer>
  */
  private fn findPropertyByName propertyName = (
    local index = 0
    if classOf propertyName == Name do (
      for i = 1 to this.properties.Count while index == 0 do (
        if this.isValidProperty this.properties[i] \
            and this.properties[i].GetPropertyName() == propertyName do (
          index = i
        )
      )
    )
    index
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
  private fn isValidProperty obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #MwmPropertyStruct
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmConditionStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmConditionStruct\n" indent to:out
    format "%  evaluator:%\n" indent this.evaluator to:out
    format "%  properties:%\n" indent this.properties.Count to:out
    for i = 1 to this.properties.Count do (
      local property = this.properties[i]
      if this.isValidProperty property then (
        format "%    [%]:\n" indent i to:out
        property.Dump indent:(indent + "      ") out:out
      )
      else (
        format "%    [%]:%\n" indent i property to:out
      )
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
        and isProperty obj #GetEvaluator \
        and classOf obj.GetEvaluator == MAXScriptFunction \
        and obj.GetEvaluator() == this.GetEvaluator() \
        and isProperty obj #GetProperties \
        and classOf obj.GetProperties == MAXScriptFunction

    if isEqualProperties do (
      local ov = obj.GetProperties()
      local tv = this.GetProperties()
      isEqualProperties = classOf ov == Array and classOf tv == Array
      if isEqualProperties do (
        isEqualProperties = ov.Count == tv.Count
      )
      if isEqualProperties do (
        for i = 1 to tv.Count while isEqualProperties do (
          if this.isValidProperty tv[i] then (
            isEqualProperties = tv[i].Equals ov[i]
          )
          else (
            isEqualProperties = ov[i] == tv[i]
          )
        )
      )
    )

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
    this.SetEvaluator this._CP1_
  )
)
