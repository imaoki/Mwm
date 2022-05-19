/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
値の変換機能を提供する構造体。
@remarks 作成パラメータ
:   ```maxscript
    MwmConverterStruct toTargetFunction toSourceFunction
    ```
*/
struct MwmConverterStruct (
  /*- @prop <MAXScriptFunction> 作成パラメータ1。値をターゲット用に変換する関数。既定値は`undefined`。 */
  public _CP1_,
  /*- @prop <MAXScriptFunction> 作成パラメータ2。値をソース用に変換する関数。既定値は`undefined`。 */
  public _CP2_,

  /*- @prop <MAXScriptFunction|UndefinedClass> 値をソース用に変換する関数。既定値は`undefined`。 */
  private toSourceFunction,
  /*- @prop <MAXScriptFunction|UndefinedClass> 値をターゲット用に変換する関数。既定値は`undefined`。 */
  private toTargetFunction,

  /*
  public fn GetToSourceFunction = (),
  public fn GetToTargetFunction = (),
  public fn SetToSourceFunction input = (),
  public fn SetToTargetFunction input = (),
  public fn ToSource input = (),
  public fn ToTarget input = (),

  private fn isValidFunction obj = (),
  */

  /*-
  値をソース用に変換する関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetToSourceFunction = (
    this.toSourceFunction
  ),

  /*-
  値をターゲット用に変換する関数を取得する。
  @returns <MAXScriptFunction|UndefinedClass>
  */
  public fn GetToTargetFunction = (
    this.toTargetFunction
  ),

  /*-
  値をソース用に変換する関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetToSourceFunction input = (
    if this.isValidFunction input do (
      this.toSourceFunction = input
    )
    this.GetToSourceFunction()
  ),

  /*-
  値をターゲット用に変換する関数を設定する。
  @param input <MAXScriptFunction>
  @returns <MAXScriptFunction|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetToTargetFunction input = (
    if this.isValidFunction input do (
      this.toTargetFunction = input
    )
    this.GetToTargetFunction()
  ),

  /*-
  値をソース用に変換する。
  @param input <Any>
  @returns <Any>
  @remarks 変換用の関数が未指定の場合は何もせず値をそのまま返す。
  */
  public fn ToSource input = (
    if this.isValidFunction this.toSourceFunction then (
      this.toSourceFunction input
    )
    else (
      input
    )
  ),

  /*-
  値をターゲット用に変換する。
  @param input <Any>
  @returns <Any>
  @remarks 変換用の関数が未指定の場合は何もせず値をそのまま返す。
  */
  public fn ToTarget input = (
    if this.isValidFunction this.toTargetFunction then (
      this.toTargetFunction input
    )
    else (
      input
    )
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidFunction obj = (
    classOf obj == MAXScriptFunction
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmConverterStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmConverterStruct\n" indent to:out
    format "%  toSourceFunction:%\n" indent this.toSourceFunction to:out
    format "%  toTargetFunction:%\n" indent this.toTargetFunction to:out
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
        and isProperty obj #GetToSourceFunction \
        and classOf obj.GetToSourceFunction == MAXScriptFunction \
        and obj.GetToSourceFunction() == this.GetToSourceFunction() \
        and isProperty obj #GetToTargetFunction \
        and classOf obj.GetToTargetFunction == MAXScriptFunction \
        and obj.GetToTargetFunction() == this.GetToTargetFunction()

    isEqualStructName and isEqualProperties
  ),

  on Create do (
    this.SetToTargetFunction this._CP1_
    this.SetToSourceFunction this._CP2_
  )
)
