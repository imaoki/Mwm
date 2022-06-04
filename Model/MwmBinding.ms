/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*-
データバインディングの仕組みを提供する。
@remarks 作成パラメータ
:   ```maxscript
    MwmBindingStruct mode sourceName target targetPropertyName [targetEventName]
    ```

通知
:   | 通知名                        | 通知データ                                      | タイミング                                           |
    | ----------------------------- | ----------------------------------------------- | ---------------------------------------------------- |
    | `#Converter`                  | 新たな`converter`値                             | `converter`を設定した後                              |
    | `#Mode`                       | 新たな`mode`値                                  | `mode`を設定した後                                   |
    | `#Source`                     | 新たな`source`値                                | `source`を設定した後                                 |
    | `#SourceName`                 | 新たな`sourceName`値                            | `sourceName`を設定した後                             |
    | `#SourceValueChanged`         | `undefined`                                     | ソースの値を設定した後                               |
    | `#Target`                     | 新たな`target`値                                | `target`を設定した後                                 |
    | `#TargetEnabledChanged`       | ターゲットオブジェクトの`Enabled`プロパティの値 | ターゲットオブジェクトが使用可能かどうかを設定した後 |
    | `#TargetEventName`            | 新たな`targetEventName`値                       | `targetEventName`を設定した後                        |
    | `#TargetPropertyName`         | 新たな`targetPropertyName`値                    | `targetPropertyName`を設定した後                     |
    | `#TargetPropertyValueChanged` | 設定後のプロパティ値                            | ターゲットオブジェクトのプロパティ値を設定した後     |

オブザーバ
:   | 購読先                               | メソッド        |
    | ------------------------------------ | --------------- |
    | `MwmCommandStruct.CanExecuteChanged` | `SourceChanged` |
    | `MwmCommandStruct.StateChanged`      | `SourceChanged` |
    | `MwmPropertyStruct.EnabledChanged`   | `SourceChanged` |
    | `MwmPropertyStruct.StateChanged`     | `SourceChanged` |
    | `MwmViewModelStruct.targetChanged`   | `TargetChanged` |
*/
struct MwmBindingStruct (
  /*- @prop <Name> 作成パラメータ1。バインディングにおけるデータフローの方向。既定値は`1`。 */
  public _CP1_ = 1,
  /*- @prop <Name> 作成パラメータ2。ソース名。プロパティオブジェクトまたはコマンドオブジェクトの名前。既定値は`undefined`。 */
  public _CP2_,
  /*- @prop <RolloutClass|RolloutControl|RCMenu|MenuItem> 作成パラメータ3。ターゲットオブジェクト。既定値は`undefined`。 */
  public _CP3_,
  /*- @prop <Name|UndefinedClass> 作成パラメータ4。ターゲットオブジェクトのプロパティ名。既定値は`undefined`。 */
  public _CP4_,
  /*- @prop <Name|UndefinedClass> 作成パラメータ5。ターゲットオブジェクトのイベント名。既定値は`undefined`。 */
  public _CP5_,

  /*- @prop <Struct:MwmConverterStruct> ソース-ターゲット間の値のコンバータ。既定値は`undefined`。 */
  private converter,
  /*- @prop <Integer> バインディングにおけるデータフローの方向。既定値は`1`。 */
  private mode = 1,
  /*- @prop <Struct:MwmCommandStruct|Struct:MwmPropertyStruct> ソースオブジェクト。既定値は`undefined`。 */
  private source,
  /*- @prop <Name> ソース名。プロパティオブジェクトまたはコマンドオブジェクトの名前。既定値は`undefined`。 */
  private sourceName,
  /*- @prop <RolloutClass|RolloutControl|RCMenu|MenuItem> ターゲットオブジェクト。既定値は`undefined`。 */
  private target,
  /*- @prop <Name|UndefinedClass> ターゲットオブジェクトのイベント名。既定値は`undefined`。 */
  private targetEventName,
  /*- @prop <Name|UndefinedClass> ターゲットオブジェクトのプロパティ名。既定値は`undefined`。 */
  private targetPropertyName,

  /*
  public fn GetConverter = (),
  public fn GetMode = (),
  public fn GetSource = (),
  public fn GetSourceName = (),
  public fn GetSourceValue = (),
  public fn GetTarget = (),
  public fn GetTargetEnabled = (),
  public fn GetTargetEventName = (),
  public fn GetTargetName = (),
  public fn GetTargetPropertyName = (),
  public fn GetTargetPropertyValue = (),
  public fn Refresh = (),
  public fn SetConverter obj = (),
  public fn SetMode input = (),
  public fn SetSource obj = (),
  public fn SetSourceName input = (),
  public fn SetSourceValue input = (),
  public fn SetTarget obj = (),
  public fn SetTargetEnabled input = (),
  public fn SetTargetEventName input = (),
  public fn SetTargetPropertyName input = (),
  public fn SetTargetPropertyValue input = (),
  public fn SourceChanged type param = (),
  public fn TargetChanged type param = (),

  private fn isTypeEqual actual expected = (),
  private fn isValidCommand obj = (),
  private fn isValidConverter obj = (),
  private fn isValidEvent obj = (),
  private fn isValidMenuItem obj = (),
  private fn isValidProperty obj = (),
  private fn isValidRCMenu obj = (),
  private fn isValidRollout obj = (),
  private fn isValidRolloutControl obj = (),
  private fn isValidTarget obj = (),
  private fn subscribeSource = (),
  private fn unsubscribeSource = (),
  private fn updateTargetEnabled = (),
  private fn updateTargetPropertyValue = (),
  */

  /*-
  ソース-ターゲット間の値のコンバータを取得する。
  @returns <Struct:MwmConverterStruct|UndefinedClass>
  */
  public fn GetConverter = (
    this.converter
  ),

  /*-
  バインディングにおけるデータフローの方向を取得する。
  @returns <Integer>
  */
  public fn GetMode = (
    this.mode
  ),

  /*-
  ソースオブジェクトを取得する。
  @returns <Struct:MwmCommandStruct|Struct:MwmPropertyStruct|UndefinedClass>
  */
  public fn GetSource = (
    this.source
  ),

  /*-
  ソース名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetSourceName = (
    this.sourceName
  ),

  /*-
  ソースがプロパティオブジェクトの場合に値を取得する。
  @returns <Any>
  @remarks コンバータが設定されている場合はターゲット用に変換した値を返す。
  ソースがプロパティオブジェクト以外の場合は`undefined`を返す。
  */
  public fn GetSourceValue = (
    local sourceValue = undefined
    if this.isValidProperty this.source do (
      sourceValue = this.source.GetPropertyValue()
      if this.isValidConverter this.converter do (
        sourceValue = this.converter.ToTarget sourceValue
      )
    )
    sourceValue
  ),

  /*-
  ターゲットオブジェクトを取得する。
  @returns <RolloutClass|RolloutControl|RCMenu|MenuItem|UndefinedClass>
  */
  public fn GetTarget = (
    this.target
  ),

  /*-
  ターゲットオブジェクトが使用可能かどうかを取得する。
  @returns <BooleanClass>
  @remarks ターゲットオブジェクトがロールアウトコントロール以外の場合は`false`を返す。
  */
  public fn GetTargetEnabled = (
    (this.isValidRolloutControl this.target or this.isValidMenuItem this.target) \
        and this.target.Enabled
  ),

  /*-
  ターゲットオブジェクトのイベント名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetTargetEventName = (
    this.targetEventName
  ),

  /*-
  ターゲットオブジェクトの名前を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetTargetName = (
    local targetName = undefined
    if this.isValidTarget this.target do (
      if this.isValidRollout this.target \
          or this.isValidRolloutControl this.target then (
        targetName = this.target.Name as Name
      )
      else (
        if this.isValidRCMenu this.target \
            or this.isValidMenuItem this.target do (
          local names = filterString (this.target as String) ":"
          if names.Count == 2 do (
            targetName = names[2] as Name
          )
        )
      )
    )
    targetName
  ),

  /*-
  ターゲットオブジェクトのプロパティ名を取得する。
  @returns <Name|UndefinedClass>
  */
  public fn GetTargetPropertyName = (
    this.targetPropertyName
  ),

  /*-
  ターゲットオブジェクトのプロパティ値を取得する。
  @returns <Any>
  @remarks コンバータが設定されている場合はソース用に変換した値を返す。
  ソースがプロパティオブジェクト以外の場合、および該当のプロパティが存在しない場合は`undefined`を返す。
  */
  public fn GetTargetPropertyValue = (
    local targetPropertyValue = undefined
    if this.isValidProperty this.source \
        and this.isValidTarget this.target \
        and classOf this.targetPropertyName == Name \
        and isProperty this.target this.targetPropertyName do (
      targetPropertyValue = getProperty this.target this.targetPropertyName
      if this.isValidConverter this.converter do (
        targetPropertyValue = this.converter.ToSource targetPropertyValue
      )
    )
    targetPropertyValue
  ),

  /*-
  ソースオブジェクトの状態をターゲットオブジェクトに反映する。
  @returns <OkClass>
  */
  public fn Refresh = (
    this.updateTargetEnabled()
    this.updateTargetPropertyValue()
    ok
  ),

  /*-
  ソース-ターゲット間の値のコンバータを設定する。
  @param obj <Struct:MwmConverterStruct|UndefinedClass>
  @returns <Struct:MwmConverterStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetConverter obj = (
    if this.isValidConverter obj or classOf obj == UndefinedClass do (
      this.converter = obj
      this.StateChanged.Notify #Converter this.converter
    )
    this.GetConverter()
  ),

  /*-
  バインディングにおけるデータフローの方向を設定する。
  @param input <Integer> 有効な値は次の通り。

  | 値  | 名前             | 動作                                                                 |
  | --- | ---------------- | -------------------------------------------------------------------- |
  | `1` | `TwoWay`         | ソースまたはターゲットのいずれかが変更されるともう一方も更新される。 |
  | `2` | `OneWay`         | ソースが変更されるとターゲットも更新される。                         |
  | `3` | `OneWayToSource` | ターゲットが変更されるとソースも更新される。                         |
  @returns <Integer>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetMode input = (
    if classOf input == Integer and 1 <= input and input <= 3 do (
      this.mode = input
      this.StateChanged.Notify #Mode this.mode
    )
    this.GetMode()
  ),

  /*-
  ソースオブジェクトを設定する。
  @param obj <Struct:MwmCommandStruct|Struct:MwmPropertyStruct>
  @returns <Struct:MwmCommandStruct|Struct:MwmPropertyStruct|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetSource obj = (
    if this.isValidCommand obj \
        or this.isValidProperty obj \
        or classOf obj == UndefinedClass do (
      this.unsubscribeSource()
      this.source = obj
      this.subscribeSource()
      this.Refresh()
      this.StateChanged.Notify #Source this.source
    )
    this.GetSource()
  ),

  /*-
  ソース名を設定する。
  @param input <Name> プロパティオブジェクトまたはコマンドオブジェクトの名前。
  @returns <Name>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetSourceName input = (
    if classOf input == Name do (
      this.sourceName = input
      this.StateChanged.Notify #SourceName this.sourceName
    )
    this.GetSourceName()
  ),

  /*-
  ソースがプロパティオブジェクトの場合に値を設定する。
  @param input <Any>
  @returns <Any>
  @remarks ソースがプロパティオブジェクト以外の場合は何もしない。
  */
  public fn SetSourceValue input = (
    if this.isValidProperty this.source do (
      this.source.SetPropertyValue input
      this.StateChanged.Notify #SourceValueChanged undefined
    )
    ok
  ),

  /*-
  ターゲットオブジェクトを設定する。
  @param obj <RolloutClass|RolloutControl|RCMenu|MenuItem>
  @returns <RolloutClass|RolloutControl|RCMenu|MenuItem>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetTarget obj = (
    if this.isValidTarget obj do (
      this.target = obj
      this.Refresh()
      this.StateChanged.Notify #Target this.target
    )
    this.GetTarget()
  ),

  /*-
  ターゲットオブジェクトが使用可能かどうかを設定する。
  @param input <BooleanClass>
  @returns <BooleanClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetTargetEnabled input = (
    if classOf input == BooleanClass \
        and (
          this.isValidRolloutControl this.target \
              or this.isValidMenuItem this.target
        ) do (
      this.target.Enabled = input
      this.StateChanged.Notify #TargetEnabledChanged this.target.Enabled
    )
    this.GetTargetEnabled()
  ),

  /*-
  ターゲットオブジェクトのイベント名を設定する。
  @param input <Name|UndefinedClass>
  @returns <Name|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetTargetEventName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.targetEventName = input
      this.StateChanged.Notify #TargetEventName this.targetEventName
    )
    this.GetTargetEventName()
  ),

  /*-
  ターゲットオブジェクトのプロパティ名を設定する。
  @param input <Name|UndefinedClass>
  @returns <Name|UndefinedClass>
  @remarks 無効な値の場合は何もしない。
  */
  public fn SetTargetPropertyName input = (
    if classOf input == Name or classOf input == UndefinedClass do (
      this.targetPropertyName = input
      this.Refresh()
      this.StateChanged.Notify #TargetPropertyName this.targetPropertyName
    )
    this.GetTargetPropertyName()
  ),

  /*-
  ターゲットオブジェクトのプロパティ値を設定する。
  @param input <Any>
  @returns <Any>
  @remarks ソースがプロパティオブジェクト以外の場合、および入力値とプロパティ値の型が異なる場合は何もしない。
  ただし`Integer`と`Float`については`Number`として扱うので異なっていても可とする。
  */
  public fn SetTargetPropertyValue input = (
    if this.isValidProperty this.source \
        and this.isValidTarget this.target \
        and classOf this.targetPropertyName == Name \
        and isProperty this.target this.targetPropertyName do (
      local targetPropertyValue = getProperty this.target this.targetPropertyName
      if this.isTypeEqual input targetPropertyValue do (
        setProperty this.target this.targetPropertyName input
        this.StateChanged.Notify #TargetPropertyValueChanged \
            (getProperty this.target this.targetPropertyName)
      )
    )
    this.GetTargetPropertyValue()
  ),

  /*-
  ソース更新の通知を受け取る。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  */
  public fn SourceChanged type param = (
    case type of (
      (#CanExecuteChanged): this.updateTargetEnabled()
      (#EnabledChanged): this.updateTargetEnabled()
      (#PropertyValue): (
        if #{1, 2}[this.mode] do (
          this.updateTargetPropertyValue()
        )
      )
      default: ()
    )
    ok
  ),

  /*-
  ターゲット更新の通知を受け取る。
  @param type <Name>
  @param param <Any>
  @returns <OkClass>
  @remarks 通常`param`引数にはイベントデータが渡される。
  */
  public fn TargetChanged type param = (
    case type of (
      (#TargetChanged): (
        if this.isValidEvent param \
            and param.GetControl() == this.target \
            and param.GetEventName() == this.targetEventName do (
          if this.isValidCommand this.source then (
            this.source.Execute param
          )
          else (
            if this.isValidProperty this.source and #{1, 3}[this.mode] do (
              this.SetSourceValue (this.GetTargetPropertyValue())
            )
          )
        )
      )
      default: ()
    )
    ok
  ),

  /*-
  @param actual <Any>
  @param expected <Any>
  @returns <BooleanClass>
  */
  private fn isTypeEqual actual expected = (
    classOf actual == classOf expected \
        or (superClassOf expected == Number and superClassOf actual == Number)
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
  private fn isValidMenuItem obj = (
    classOf obj == Value \
        and matchPattern (obj as String) pattern:"MenuItem:*" ignoreCase:true
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

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidTarget obj = (
    this.isValidRollout obj \
        or this.isValidRolloutControl obj \
        or this.isValidRCMenu obj \
        or this.isValidMenuItem obj
  ),

  /*-
  ソースオブジェクトを購読する。
  @returns <OkClass>
  */
  private fn subscribeSource = (
    if this.isValidCommand this.source then (
      this.source.CanExecuteChanged.Subscribe this.SourceChanged
      this.source.StateChanged.Subscribe this.SourceChanged
    )
    else (
      if this.isValidProperty this.source do (
        this.source.EnabledChanged.Subscribe this.SourceChanged
        this.source.StateChanged.Subscribe this.SourceChanged
      )
    )
    ok
  ),

  /*-
  ソースオブジェクトの購読を解除する。
  @returns <OkClass>
  */
  private fn unsubscribeSource = (
    if this.isValidCommand this.source then (
      this.source.CanExecuteChanged.Unsubscribe this.SourceChanged
      this.source.StateChanged.Unsubscribe this.SourceChanged
    )
    else (
      if this.isValidProperty this.source do (
        this.source.EnabledChanged.Unsubscribe this.SourceChanged
        this.source.StateChanged.Unsubscribe this.SourceChanged
      )
    )
    ok
  ),

  /*-
  ターゲットオブジェクトが使用可能かどうかの状態を更新する。
  @returns <OkClass>
  */
  private fn updateTargetEnabled = (
    local isEnabled = true
    if this.isValidCommand this.source then (
      isEnabled = this.source.CanExecute()
    )
    else (
      if this.isValidProperty this.source do (
        isEnabled = this.source.IsEnabled()
      )
    )
    this.SetTargetEnabled isEnabled
    ok
  ),

  /*-
  ターゲットオブジェクトのプロパティ値の状態を更新する。
  @returns <OkClass>
  */
  private fn updateTargetPropertyValue = (
    this.SetTargetPropertyValue (this.GetSourceValue())
    ok
  ),

  /*- @returns <Name> */
  public fn StructName = #MwmBindingStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MwmBindingStruct\n" indent to:out
    if this.isValidConverter this.converter then (
      format "%  converter:\n" indent to:out
      this.converter.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  converter:%\n" indent this.converter to:out
    )
    format "%  mode:%\n" indent this.mode to:out
    if this.isValidCommand this.source or this.isValidProperty this.source then (
      format "%  source:\n" indent to:out
      this.source.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  source:%\n" indent this.source to:out
    )
    format "%  sourceName:%\n" indent this.sourceName to:out
    format "%  target:%\n" indent this.target to:out
    format "%  targetEventName:%\n" indent this.targetEventName to:out
    format "%  targetPropertyName:%\n" indent this.targetPropertyName to:out
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
        and isProperty obj #GetConverter \
        and classOf obj.GetConverter == MAXScriptFunction \
        and isProperty obj #GetMode \
        and classOf obj.GetMode == MAXScriptFunction \
        and obj.GetMode() == this.GetMode() \
        and isProperty obj #GetSource \
        and classOf obj.GetSource == MAXScriptFunction \
        and isProperty obj #GetSourceName \
        and classOf obj.GetSourceName == MAXScriptFunction \
        and obj.GetSourceName() == this.GetSourceName() \
        and isProperty obj #GetTarget \
        and classOf obj.GetTarget == MAXScriptFunction \
        and obj.GetTarget() == this.GetTarget() \
        and isProperty obj #GetTargetEventName \
        and classOf obj.GetTargetEventName == MAXScriptFunction \
        and obj.GetTargetEventName() == this.GetTargetEventName() \
        and isProperty obj #GetTargetPropertyName \
        and classOf obj.GetTargetPropertyName == MAXScriptFunction \
        and obj.GetTargetPropertyName() == this.GetTargetPropertyName()

    if isEqualProperties do (
      local ov = obj.GetConverter()
      local tv = this.GetConverter()
      if this.isValidConverter tv then (
        isEqualProperties = tv.Equals ov
      )
      else (
        isEqualProperties = ov == tv
      )
    )

    if isEqualProperties do (
      local ov = obj.GetSource()
      local tv = this.GetSource()
      if this.isValidCommand tv or this.isValidProperty tv then (
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
    this.SetMode this._CP1_
    this.SetSourceName this._CP2_
    this.SetTarget this._CP3_
    this.SetTargetPropertyName this._CP4_
    this.SetTargetEventName this._CP5_
  )
)
