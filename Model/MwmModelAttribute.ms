/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
モデル属性を格納する構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmModelAttributeStruct modelName propertyName getterName setterName
```

通知
:   | 通知名            | 通知データ               | タイミング                     |
    | ----------------- | ------------------------ | ------------------------------ |
    | `#GetterName`     | 新たな`getterName`値     | `getterName`が設定された後     |
    | `#ModelName`      | 新たな`modelName`値      | `modelName`が設定された後      |
    | `#ObservableName` | 新たな`observableName`値 | `observableName`が設定された後 |
    | `#PropertyName`   | 新たな`propertyName`値   | `propertyName`が設定された後   |
    | `#SetterName`     | 新たな`setterName`値     | `setterName`が設定された後     |
*/
struct MwmModelAttributeStruct (
  /*- @prop <Name> 作成パラメータ1。モデル名。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <Name|UndefinedClass> 作成パラメータ2。プロパティ名。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <Name|UndefinedClass> 作成パラメータ3。モデルのプロパティ値取得メソッド名。既定値は`undefined`。 */
  public _CP3_,
  /*- @prop <Name|UndefinedClass> 作成パラメータ4。モデルのプロパティ値設定メソッド名。既定値は`undefined`。 */
  public _CP4_,

  /*- @prop <Name|UndefinedClass> モデルのプロパティ値取得メソッド名。既定値は`undefined`。 */
  private getterName,
  /*- @prop <Name> モデル名。既定値は`undefined`。 */
  private modelName,
  /*- @prop <Name> モデルの通知元オブジェクトのプロパティ名。既定値は`#StateChanged`。 */
  private observableName = #StateChanged,
  /*- @prop <Name|UndefinedClass> モデルのプロパティ名。既定値は`undefined`。 */
  private propertyName,
  /*- @prop <Name|UndefinedClass> モデルのプロパティ値設定メソッド名。既定値は`undefined`。 */
  private setterName,

  /*
  public fn GetGetterName = (),
  public fn GetModelName = (),
  public fn GetObservableName = (),
  public fn GetPropertyName = (),
  public fn GetSetterName = (),
  public fn SetGetterName input = (),
  public fn SetModelName input = (),
  public fn SetObservableName input = (),
  public fn SetPropertyName input = (),
  public fn SetSetterName input = (),
  */

  /*-
  モデルのプロパティ値取得メソッド名を取得する。
  @returns <Name>
  */
  public fn GetGetterName = (
    this.getterName
  ),

  /*-
  モデル名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetModelName = (
    this.modelName
  ),

  /*-
  モデルの通知元オブジェクトのプロパティ名を取得する。
  @returns <Name>
  */
  public fn GetObservableName = (
    this.observableName
  ),

  /*-
  モデルのプロパティ名を取得する。
  @returns <Name>
  */
  public fn GetPropertyName = (
    this.propertyName
  ),

  /*-
  モデルのプロパティ値設定メソッド名を取得する。
  @returns <Name>
  */
  public fn GetSetterName = (
    this.setterName
  ),

  /*-
  モデルのプロパティ値取得メソッド名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetGetterName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.getterName = input
      this.StateChanged.Notify #GetterName this.getterName
    )
    this.GetGetterName()
  ),

  /*-
  モデル名を設定する。
  @param input <Name|UndefinedClass>
  @returns <Name|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetModelName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.modelName = input
      this.StateChanged.Notify #ModelName this.modelName
    )
    this.GetModelName()
  ),

  /*-
  モデルの通知元オブジェクトのプロパティ名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetObservableName input = (
    if classOf input == Name do (
      this.observableName = input
      this.StateChanged.Notify #ObservableName this.observableName
    )
    this.GetObservableName()
  ),

  /*-
  モデルのプロパティ名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetPropertyName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.propertyName = input
      this.StateChanged.Notify #PropertyName this.propertyName
    )
    this.GetPropertyName()
  ),

  /*-
  モデルのプロパティ値設定メソッド名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetSetterName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.setterName = input
      this.StateChanged.Notify #SetterName this.setterName
    )
    this.GetSetterName()
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmModelAttributeStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmModelAttributeStruct\n" indent to:out
    format "%  getterName:%\n" indent this.getterName to:out
    format "%  modelName:%\n" indent this.modelName to:out
    format "%  observableName:%\n" indent this.observableName to:out
    format "%  propertyName:%\n" indent this.propertyName to:out
    format "%  setterName:%\n" indent this.setterName to:out
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
        and isProperty obj #GetGetterName \
        and classOf obj.GetGetterName == MAXScriptFunction \
        and obj.GetGetterName() == this.GetGetterName() \
        and isProperty obj #GetModelName \
        and classOf obj.GetModelName == MAXScriptFunction \
        and obj.GetModelName() == this.GetModelName() \
        and isProperty obj #GetObservableName \
        and classOf obj.GetObservableName == MAXScriptFunction \
        and obj.GetObservableName() == this.GetObservableName() \
        and isProperty obj #GetPropertyName \
        and classOf obj.GetPropertyName == MAXScriptFunction \
        and obj.GetPropertyName() == this.GetPropertyName() \
        and isProperty obj #GetSetterName \
        and classOf obj.GetSetterName == MAXScriptFunction \
        and obj.GetSetterName() == this.GetSetterName()

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
    this.SetModelName this._CP1_
    this.SetPropertyName this._CP2_
    this.SetGetterName this._CP3_
    this.SetSetterName this._CP4_
  )
)
