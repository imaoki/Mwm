/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ビューモデルにプロパティを定義するための構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmPropertyStruct propertyName propertyValue [modelAttribute]
```

通知
:   | 通知名            | 通知データ               | タイミング                   |
    | ----------------- | ------------------------ | ---------------------------- |
    | `#Model`          | 新たな`model`値          | `model`を設定した後          |
    | `#ModelAttribute` | 新たな`modelAttribute`値 | `modelAttribute`を設定した後 |
    | `#PropertyName`   | 新たな`propertyName`値   | `propertyName`を設定した後   |
    | `#PropertyValue`  | 新たな`propertyValue`値  | `propertyValue`を設定した後  |

オブザーバ
:   | 購読先                                        | メソッド               |
    | --------------------------------------------- | ---------------------- |
    | `modelAttribute`で指定した`model`のプロパティ | `SynchronizeWithModel` |
*/
struct MwmPropertyStruct (
  /*- @prop <Name> 作成パラメータ1。プロパティ名。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <Any> 作成パラメータ2。プロパティ値。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> 作成パラメータ3。モデルのプロパティ情報。既定値は`undefined`。 */
  public _CP3_,

  /*- @prop <Struct|UndefinedClass> モデルオブジェクト。既定値は`undefined`。 */
  private model,
  /*- @prop <Struct:MwmModelAttributeStruct|UndefinedClass> モデルのプロパティ情報。既定値は`undefined`。 */
  private modelAttribute,
  /*- @prop <Name> プロパティ名。バインディングのソース名。既定値は`undefined`。 */
  private propertyName,
  /*- @prop <Any> プロパティ値。既定値は`undefined`。 */
  private propertyValue,

  /*
  public fn GetModel = (),
  public fn GetModelAttribute = (),
  public fn GetPropertyName = (),
  public fn GetPropertyValue = (),
  public fn SetModel obj = (),
  public fn SetModelAttribute obj = (),
  public fn SetPropertyName input = (),
  public fn SetPropertyValue input = (),
  public fn SynchronizeWithModel type param = (),

  private fn getGetterMethod = (),
  private fn getModelObservable = (),
  private fn getSetterMethod = (),
  private fn isValidModel obj = (),
  private fn isValidModelAttribute obj = (),
  private fn isValidObservable obj = (),
  private fn subscribeModel = (),
  private fn synchronizePropertyValue getterMethod = (),
  private fn unsubscribeModel = (),
  */

  /*-
  モデルオブジェクトを取得する。
  @returns <Struct|UndefinedClass>
  */
  public fn GetModel = (
    this.model
  ),

  /*-
  モデルのプロパティ情報を取得する。
  @returns <Struct:MwmModelAttributeStruct|UndefinedClass>
  */
  public fn GetModelAttribute = (
    this.modelAttribute
  ),

  /*-
  プロパティ名を取得する。
  @returns <Name>
  */
  public fn GetPropertyName = (
    this.propertyName
  ),

  /*-
  プロパティ値を取得する。
  @returns <Any>
  */
  public fn GetPropertyValue = (
    this.propertyValue
  ),

  /*-
  モデルオブジェクトを設定する。
  @param obj <Struct|UndefinedClass>
  @returns <Struct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetModel obj = (
    if this.isValidModel obj or classOf obj == UndefinedClass do (
      this.unsubscribeModel()
      this.model = obj
      this.subscribeModel()
      this.synchronizePropertyValue (this.getGetterMethod())
      this.StateChanged.Notify #Model this.model
    )
    this.GetModel()
  ),

  /*-
  モデルのプロパティ情報を設定する。
  @param obj <Struct:MwmModelAttributeStruct|UndefinedClass>
  @returns <Struct:MwmModelAttributeStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetModelAttribute obj = (
    if this.isValidModelAttribute obj or classOf obj == UndefinedClass do (
      this.unsubscribeModel()
      this.modelAttribute = obj
      this.subscribeModel()
      this.synchronizePropertyValue (this.getGetterMethod())
      this.StateChanged.Notify #ModelAttribute this.modelAttribute
    )
    this.GetModelAttribute()
  ),

  /*-
  プロパティ名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetPropertyName input = (
    if classOf input == Name do (
      this.propertyName = input
      this.StateChanged.Notify #PropertyName this.propertyName
    )
    this.GetPropertyName()
  ),

  /*-
  プロパティ値を設定する。
  @param input <Any>
  @returns <OkClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetPropertyValue input = (
    local setterMethod = this.getSetterMethod()
    if classOf setterMethod == MAXScriptFunction then (
      setterMethod input
    )
    else (
      this.propertyValue = input
      this.StateChanged.Notify #PropertyValue this.propertyValue
    )
    ok
  ),

  /*-
  自己のプロパティ値をモデルのプロパティ値に同期させる。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  */
  public fn SynchronizeWithModel type param = (
    local getterMethod = undefined
    if this.isValidModelAttribute this.modelAttribute \
        and type == this.modelAttribute.GetPropertyName() do (
      getterMethod = this.getGetterMethod()
    )
    this.synchronizePropertyValue getterMethod
    ok
  ),

  /*-
  モデルのプロパティ値取得メソッドを取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  private fn getGetterMethod = (
    local getterMethod = undefined
    if this.isValidModel this.model \
        and this.isValidModelAttribute this.modelAttribute do (
      local getterName = this.modelAttribute.GetGetterName()
      if classOf getterName == Name do (
        getterMethod = getProperty this.model getterName
      )
    )
    getterMethod
  ),

  /*-
  モデルの通知元オブジェクトを取得する。
  @returns <Struct:ObservableStruct|UndefinedClass>
  */
  private fn getModelObservable = (
    local modelObservable = undefined
    if this.isValidModel this.model \
        and this.isValidModelAttribute this.modelAttribute do (
      local observableName = this.modelAttribute.GetObservableName()
      if classOf observableName == Name \
          and isProperty this.model observableName do (
        modelObservable = getProperty this.model observableName
      )
    )
    modelObservable
  ),

  /*-
  モデルのプロパティ値設定メソッドを取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  private fn getSetterMethod = (
    local setterMethod = undefined
    if this.isValidModel this.model \
        and this.isValidModelAttribute this.modelAttribute do (
      local setterName = this.modelAttribute.GetSetterName()
      if classOf setterName == Name do (
        setterMethod = getProperty this.model setterName
      )
    )
    setterMethod
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
  モデルのプロパティ通知を購読する。
  @returns <OkClass>
  */
  private fn subscribeModel = (
    local modelObservable = this.getModelObservable()
    if this.isValidObservable modelObservable do (
      modelObservable.Subscribe this.SynchronizeWithModel
    )
    ok
  ),

  /*-
  プロパティ値をモデルと同期する。
  @param getterMethod <MAXScriptFunction>
  @returns <OkClass>
  */
  private fn synchronizePropertyValue getterMethod = (
    if classOf getterMethod == MAXScriptFunction do (
      this.propertyValue = getterMethod()
      this.StateChanged.Notify #PropertyValue this.propertyValue
    )
    ok
  ),

  /*-
  モデルのプロパティ通知の購読を解除する。
  @returns <OkClass>
  */
  private fn unsubscribeModel = (
    local modelObservable = this.getModelObservable()
    if this.isValidObservable modelObservable do (
      modelObservable.Unsubscribe this.SynchronizeWithModel
    )
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmPropertyStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmPropertyStruct\n" indent to:out
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
    format "%  propertyName:%\n" indent this.propertyName to:out
    if isStruct this.propertyValue \
        and isProperty this.propertyValue #StructName \
        and classOf this.propertyValue.StructName == MAXScriptFunction \
        and isProperty this.propertyValue #Dump \
        and classOf this.propertyValue.Dump == MAXScriptFunction then (
      format "%  propertyValue:\n" indent to:out
      this.propertyValue.Dump indent:(indent + "    ") out:out
    )
    else (
      if classOf this.propertyValue == String then (
        format "%  propertyValue:\"%\"\n" indent this.propertyValue to:out
      )
      else (
        format "%  propertyValue:%\n" indent this.propertyValue to:out
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
        and isProperty obj #GetModel \
        and classOf obj.GetModel == MAXScriptFunction \
        and isProperty obj #GetModelAttribute \
        and classOf obj.GetModelAttribute == MAXScriptFunction \
        and isProperty obj #GetPropertyName \
        and classOf obj.GetPropertyName == MAXScriptFunction \
        and obj.GetPropertyName() == this.GetPropertyName() \
        and isProperty obj #GetPropertyValue \
        and classOf obj.GetPropertyValue == MAXScriptFunction

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

    if isEqualProperties do (
      local ov = obj.GetPropertyValue()
      local tv = this.GetPropertyValue()
      if isStruct tv \
          and isProperty tv #Equals \
          and classOf tv.Equals == MAXScriptFunction then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
      )
    )

    isEqualStructName and isEqualProperties
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
    this.SetPropertyName this._CP1_
    this.SetPropertyValue this._CP2_
    this.SetModelAttribute this._CP3_
  )
)
