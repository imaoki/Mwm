/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
ロールアウトコントロールのイベント情報を格納する構造体。
@remarks インスタンス作成時のパラメータ指定順は以下の通り。

```maxscript
::MwmEventStruct control eventName params
```
*/
struct MwmEventStruct (
  /*- @prop <RolloutClass|RolloutControl> 作成パラメータ1。イベント発生元のロールアウトコントロール。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <Name> 作成パラメータ2。イベント名。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <Array[<Any>]|Any> 作成パラメータ3。イベントデータ。既定値は`#()`。 */
  public _CP3_ = #(),

  /*- @prop <RolloutClass|RolloutControl> イベント発生元のロールアウトコントロール。既定値は`undefined`。 */
  private control,
  /*- @prop <Name> イベント名。既定値は`undefined`。 */
  private eventName,
  /*- @prop <Array[<Any>]> イベントデータ。既定値は`#()`。 */
  private params = #(),

  /*
  public fn GetControl = (),
  public fn GetEventName = (),
  public fn GetParams = (),
  public fn SetControl input = (),
  public fn SetEventName input = (),
  public fn SetParams input = (),
  */

  /*-
  イベント発生元のロールアウトコントロールを取得する。
  @returns <RolloutClass|RolloutControl|UndefinedClass>
  */
  public fn GetControl = (
    this.control
  ),

  /*-
  イベント名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetEventName = (
    this.eventName
  ),

  /*-
  イベントデータを取得する。
  @returns <Array[<Any>]>
  */
  public fn GetParams = (
    this.params
  ),

  /*-
  イベント発生元のロールアウトコントロールを設定する。
  @param input <RolloutClass|RolloutControl>
  @returns <RolloutClass|RolloutControl>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetControl input = (
    if classOf input == RolloutClass or superClassOf input == RolloutControl do (
      this.control = input
    )
    this.GetControl()
  ),

  /*-
  イベント名を設定する。
  @param input <Name>
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetEventName input = (
    if classOf input == Name do (
      this.eventName = input
    )
    this.GetEventName()
  ),

  /*-
  イベントデータを設定する。
  @param input <Array[<Any>]>
  @returns <Array[<Any>]|Any>
  @remarks 配列以外の値を指定した場合は配列にして格納する。
  */
  public fn SetParams input = (
    if classOf input == Array then (
      this.params = input
    )
    else (
      this.params = #(input)
    )
    this.GetParams()
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmEventStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmEventStruct\n" indent to:out
    format "%  control:%\n" indent this.control to:out
    format "%  eventName:%\n" indent this.eventName to:out
    format "%  params:%\n" indent this.params.Count to:out
    for i = 1 to this.params.Count do (
      local param = this.params[i]
      if classOf param == String then (
        format "%    [%]:\"%\"\n" indent i param to:out
      )
      else (
        format "%    [%]:%\n" indent i param to:out
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
        and isProperty obj #GetControl \
        and classOf obj.GetControl == MAXScriptFunction \
        and obj.GetControl() == this.GetControl() \
        and isProperty obj #GetEventName \
        and classOf obj.GetEventName == MAXScriptFunction \
        and obj.GetEventName() == this.GetEventName() \
        and isProperty obj #GetParams \
        and classOf obj.GetParams == MAXScriptFunction

    if isEqualProperties do (
      local ov = obj.GetParams()
      local tv = this.GetParams()
      isEqualProperties = classOf ov == Array and classOf tv == Array
      if isEqualProperties do (
        local ovCount = ov.Count
        local tvCount = tv.Count
        isEqualProperties = ovCount == tvCount
        if isEqualProperties do (
          for i = 1 to tvCount while isEqualProperties do (
            local ovValue = ov[i]
            local tvValue = tv[i]
            if isStruct tvValue \
                and isProperty tvValue #Equals \
                and classOf tvValue.Equals == MAXScriptFunction then (
              isEqualProperties = tvValue.Equals ovValue
            )
            else (
              isEqualProperties = ovValue == tvValue
            )
          )
        )
      )
    )

    isEqualStructName and isEqualProperties
  ),

  on Create do (
    this.SetControl this._CP1_
    this.SetEventName this._CP2_
    this.SetParams this._CP3_
  )
)
