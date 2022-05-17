/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  local commandDef = ::mwmDefinitionPool[@"Model\MwmCommand.ms"]
  local conditionDef = ::mwmDefinitionPool[@"Model\MwmCondition.ms"]
  local converterDef = ::mwmDefinitionPool[@"Model\MwmConverter.ms"]
  local eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local TestModelStruct
  struct TestModelStruct (
    private count = 0,
    private step = 1,

    /*
    public fn Decrement = (),
    public fn GetCount = (),
    public fn GetStep = (),
    public fn Increment = (),
    public fn SetCount input = (),
    public fn SetStep input = (),
    */

    /*-
    @param subtrahend <Integer>
    @returns <OkClass>
    */
    public fn Decrement subtrahend = (
      this.SetCount (this.count - subtrahend)
      ok
    ),

    /*-
    @returns <Integer>
    */
    public fn GetCount = (
      this.count
    ),

    /*-
    @returns <BooleanClass>
    */
    public fn GetStep = (
      this.step
    ),

    /*-
    @param addend <Integer>
    @returns <OkClass>
    */
    public fn Increment addend = (
      this.SetCount (this.count + addend)
      ok
    ),

    /*-
    @param input <Integer>
    @returns <Integer>
    */
    public fn SetCount input = (
      if classOf input == Integer do (
        this.count = input
        this.StateChanged.Notify #Count this.count
      )
      this.GetCount()
    ),

    /*-
    @param input <Integer>
    @returns <Integer>
    */
    public fn SetStep input = (
      if classOf input == Integer do (
        this.step = input
        this.StateChanged.Notify #Step this.step
      )
      this.GetStep()
    ),

    /*- @returns <Name> */
    public fn StructName = #TestModelStruct,

    /*-
    @param indent: <String>
    @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
    @returns <OkClass>
    */
    public fn Dump indent:"" out:listener = (
      format "%TestModelStruct\n" indent to:out
      format "%  count:%\n" indent this.count to:out
      format "%  step:%\n" indent this.step to:out
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
          and isProperty obj #GetCount \
          and classOf obj.GetCount == MAXScriptFunction \
          and obj.GetCount() == this.GetCount() \
          and isProperty obj #GetStep \
          and classOf obj.GetStep == MAXScriptFunction \
          and obj.GetStep() == this.GetStep()

      isEqualStructName and isEqualProperties
    ),

    /*- @prop <Struct:ObservableStruct> */
    public StateChanged,

    on Create do (
      this.StateChanged = ::std.ObservableStruct()
    )
  )

  local MnuTest
  rcMenu MnuTest (
    menuItem Mi "Increment"
  )

  local RltTest
  rollout RltTest "RltTest" (
    editText Edt "Count"
    button Btn "Increment"
  )

  local expectedConverter = undefined
  local expectedMode = 1
  local expectedSource = undefined
  local expectedSourceName = undefined
  local expectedSourceValue = undefined
  local expectedTarget = undefined
  local expectedTargetEnabled = undefined
  local expectedTargetEventName = undefined
  local expectedTargetPropertyName = undefined
  local expectedTargetPropertyValue = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#Converter): (
        actual = ::TestValueStruct (testObj.GetConverter())
        expected = ::TestValueStruct expectedConverter
        assert (actual.Equals expected == true)
      )
      (#Mode): (
        actual = ::TestValueStruct (testObj.GetMode())
        expected = ::TestValueStruct expectedMode
        assert (actual.Equals expected == true)
      )
      (#Source): (
        actual = ::TestValueStruct (testObj.GetSource())
        expected = ::TestValueStruct expectedSource
        assert (actual.Equals expected == true)
      )
      (#SourceName): (
        actual = ::TestValueStruct (testObj.GetSourceName())
        expected = ::TestValueStruct expectedSourceName
        assert (actual.Equals expected == true)
      )
      (#SourceValueChanged): (
        actual = ::TestValueStruct (testObj.GetSourceValue())
        expected = ::TestValueStruct expectedSourceValue
        assert (actual.Equals expected == true)
      )
      (#Target): (
        actual = ::TestValueStruct (testObj.GetTarget())
        expected = ::TestValueStruct expectedTarget
        assert (actual.Equals expected == true)
      )
      (#TargetEnabledChanged): (
        actual = ::TestValueStruct (testObj.GetTargetEnabled())
        expected = ::TestValueStruct expectedTargetEnabled
        assert (actual.Equals expected == true)
      )
      (#TargetEventName): (
        actual = ::TestValueStruct (testObj.GetTargetEventName())
        expected = ::TestValueStruct expectedTargetEventName
        assert (actual.Equals expected == true)
      )
      (#TargetPropertyName): (
        actual = ::TestValueStruct (testObj.GetTargetPropertyName())
        expected = ::TestValueStruct expectedTargetPropertyName
        assert (actual.Equals expected == true)
      )
      (#TargetPropertyValueChanged): (
        actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
        expected = ::TestValueStruct expectedTargetPropertyValue
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local testToSourceFunction
  fn testToSourceFunction input = (
    input as Integer
  )

  local testToTargetFunction
  fn testToTargetFunction input = (
    input as String
  )

  local testCanExecuteFunction
  fn testCanExecuteFunction params = (
    params[1].Value != 0
  )

  local testExecuteFunction
  fn testExecuteFunction model params event = (
    model.Increment params[1].Value
    ok
  )

  local converter = converterDef testToTargetFunction testToSourceFunction
  local model = TestModelStruct()
  local modelAttribute = modelAttributeDef #TestModel
  local countAttribute = modelAttributeDef #TestModel #Count #GetCount #SetCount
  local stepAttribute = modelAttributeDef #TestModel #Step #GetStep #SetStep

  local countProperty = propertyDef #Count 0 countAttribute
  countProperty.SetModel model
  local stepProperty = propertyDef #Step 1 stepAttribute
  stepProperty.SetModel model

  local canExecuteCondition = conditionDef testCanExecuteFunction
  canExecuteCondition.AddProperty stepProperty
  local executeCondition = conditionDef()
  executeCondition.AddProperty stepProperty
  local incrementCommand = commandDef #Increment \
      testExecuteFunction executeCondition canExecuteCondition modelAttribute
  incrementCommand.SetModel model

  createDialog RltTest 160 160 \
      style:#(
        /* #Style_Border, */
        /* #Style_MaximizeBox, */
        /* #Style_MinimizeBox, */
        /* #Style_Resizing, */
        /* #Style_Sunkenedge, */
        /* #Style_TitleBar, */
        #Style_Sysmenu,
        #Style_ToolWindow
      )

  testDef = ::mwmDefinitionPool[@"Model\MwmBinding.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

  /* GetConverter */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConverter())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetMode */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetMode())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* GetSource */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetSource())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetSourceName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetSourceValue */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTarget */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTargetEnabled */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* GetTargetEventName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTargetName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTargetName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTargetPropertyName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTargetPropertyValue */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* Refresh */
  -- 既定値
  actual = ::TestValueStruct (testObj.Refresh())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* SetConverter */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetConverter 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedConverter = converter
  actual = ::TestValueStruct (testObj.SetConverter converter)
  expected = ::TestValueStruct expectedConverter
  assert (actual.Equals expected == true)
  -- 成功（未定義に戻す）
  expectedConverter = undefined
  actual = ::TestValueStruct (testObj.SetConverter undefined)
  expected = ::TestValueStruct expectedConverter
  assert (actual.Equals expected == true)

  /* GetConverter */
  actual = ::TestValueStruct (testObj.GetConverter())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* SetSource */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetSource 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（`step`プロパティオブジェクト）
  expectedSource = stepProperty
  actual = ::TestValueStruct (testObj.SetSource stepProperty)
  expected = ::TestValueStruct expectedSource
  assert (actual.Equals expected == true)
  -- プロパティ値を確認（期待値はコンバータを通していない値）
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (stepProperty.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功（コマンドオブジェクト）
  expectedSource = incrementCommand
  actual = ::TestValueStruct (testObj.SetSource incrementCommand)
  expected = ::TestValueStruct expectedSource
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- コマンドオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (incrementCommand.CanExecuteChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (incrementCommand.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの通知元の購読解除を確認
  actual = ::TestValueStruct (stepProperty.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetSource */
  actual = ::TestValueStruct (testObj.GetSource())
  expected = ::TestValueStruct incrementCommand
  assert (actual.Equals expected == true)

  /* SetSourceName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetSourceName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedSourceName = #Increment
  actual = ::TestValueStruct (testObj.SetSourceName #Increment)
  expected = ::TestValueStruct expectedSourceName
  assert (actual.Equals expected == true)

  /* GetSourceName */
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct #Increment
  assert (actual.Equals expected == true)

  /* SetSourceValue */
  -- コマンドの場合は何もしない
  actual = ::TestValueStruct (testObj.SetSourceValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetSourceValue */
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* SetTarget */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTarget 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedTarget = RltTest.Btn
  expectedTargetEnabled = true
  actual = ::TestValueStruct (testObj.SetTarget RltTest.Btn)
  expected = ::TestValueStruct expectedTarget
  assert (actual.Equals expected == true)
  -- `Enabled`確認
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetTarget */
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct RltTest.Btn
  assert (actual.Equals expected == true)

  /* GetTargetName */
  actual = ::TestValueStruct (testObj.GetTargetName())
  expected = ::TestValueStruct #Btn
  assert (actual.Equals expected == true)

  /* SetTargetEnabled */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTargetEnabled 0)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedTargetEnabled = false
  actual = ::TestValueStruct (testObj.SetTargetEnabled false)
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* GetTargetEnabled */
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* SetTargetEventName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTargetEventName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（期待値はコンバータを通した値）
  expectedTargetEventName = #Pressed
  actual = ::TestValueStruct (testObj.SetTargetEventName #Pressed)
  expected = ::TestValueStruct expectedTargetEventName
  assert (actual.Equals expected == true)

  /* GetTargetEventName */
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct #Pressed
  assert (actual.Equals expected == true)

  /* SetTargetPropertyName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTargetPropertyName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedTargetEnabled = true
  expectedTargetPropertyName = #Caption
  actual = ::TestValueStruct (testObj.SetTargetPropertyName #Caption)
  expected = ::TestValueStruct expectedTargetPropertyName
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Btn.Caption
  expected = ::TestValueStruct "Increment"
  assert (actual.Equals expected == true)

  /* GetTargetPropertyName */
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct #Caption
  assert (actual.Equals expected == true)

  /* SetTargetPropertyValue */
  -- コマンドの場合は何もしない
  actual = ::TestValueStruct (testObj.SetTargetPropertyValue 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetTargetPropertyValue */
  actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* Refresh */
  -- 成功（ソースの状態を反映）
  expectedTargetEnabled = true
  actual = ::TestValueStruct (testObj.Refresh())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)

  /* SourceChanged */
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 成功（通知データは使用しない）
  expectedTargetEnabled = true
  actual = ::TestValueStruct (testObj.SourceChanged #CanExecuteChanged false)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  -- 成功（`step`プロパティオブジェクトの状態を変更）
  expectedTargetEnabled = false
  actual = ::TestValueStruct (stepProperty.SetPropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 成功（通知データは使用しない）
  expectedTargetEnabled = false
  actual = ::TestValueStruct (testObj.SourceChanged #CanExecuteChanged true)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  -- 成功（モデルの状態を変更）
  expectedTargetEnabled = true
  actual = ::TestValueStruct (model.SetStep 1)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Btn.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)

  /* TargetChanged */
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 成功（通知データは使用しない）
  actual = ::TestValueStruct (
    testObj.TargetChanged #TargetChanged (eventDef RltTest.Btn #Pressed #())
  )
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* SetMode */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetMode #2)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 無効な値（範囲外）
  actual = ::TestValueStruct (testObj.SetMode 0)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 無効な値（範囲外）
  actual = ::TestValueStruct (testObj.SetMode 4)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- 成功
  expectedMode = 2
  actual = ::TestValueStruct (testObj.SetMode 2)
  expected = ::TestValueStruct expectedMode
  assert (actual.Equals expected == true)

  /* 作成パラメータ */
  testObj = testDef 3 #Increment RltTest.Btn #Pressed
  testObj.StateChanged.Subscribe testNotification
  -- GetMode
  actual = ::TestValueStruct (testObj.GetMode())
  expected = ::TestValueStruct 3
  assert (actual.Equals expected == true)
  -- GetSourceName
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct #Increment
  assert (actual.Equals expected == true)
  -- GetTarget
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct RltTest.Btn
  assert (actual.Equals expected == true)
  -- GetTargetEventName
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct #Pressed
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef 3 #Increment RltTest.Btn #Pressed)
  assert (actual.Equals expected == true)

  /* メニューアイテムとのバインディング */
  testObj = testDef 3 #Increment MnuTest.Mi #Picked
  testObj.StateChanged.Subscribe testNotification
  -- GetTarget
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct MnuTest.Mi
  assert (actual.Equals expected == true)
  -- GetTargetEnabled
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- GetTargetEventName
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct #Picked
  assert (actual.Equals expected == true)
  -- GetTargetName
  actual = ::TestValueStruct (testObj.GetTargetName())
  expected = ::TestValueStruct #Mi
  assert (actual.Equals expected == true)
  -- GetTargetPropertyName
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- GetTargetPropertyValue
  actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  destroyDialog RltTest
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
