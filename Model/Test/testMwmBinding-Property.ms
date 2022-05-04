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
  fn testExecuteFunction model params = (
    model.Increment params[1].Value
    ok
  )

  local RltTest
  rollout RltTest "RltTest" (
    editText Edt "Count"
    button Btn "Increment"
  )

  local expectedConverter = undefined
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

  local converter = converterDef testToTargetFunction testToSourceFunction
  local model = TestModelStruct()
  local countAttribute = modelAttributeDef #TestModel #Count #GetCount #SetCount
  local stepAttribute = modelAttributeDef #TestModel #Step #GetStep #SetStep

  local countProperty = propertyDef #Count 0 countAttribute
  countProperty.SetModel model
  local stepProperty = propertyDef #Step 1 stepAttribute
  stepProperty.SetModel model

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
  -- 再度設定
  expectedConverter = converter
  actual = ::TestValueStruct (testObj.SetConverter converter)
  expected = ::TestValueStruct expectedConverter
  assert (actual.Equals expected == true)

  /* GetConverter */
  actual = ::TestValueStruct (testObj.GetConverter())
  expected = ::TestValueStruct converter
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
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct "1"
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (stepProperty.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功（`count`プロパティオブジェクト）
  expectedSource = countProperty
  actual = ::TestValueStruct (testObj.SetSource countProperty)
  expected = ::TestValueStruct expectedSource
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct "0"
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (countProperty.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの通知元の購読解除を確認
  actual = ::TestValueStruct (stepProperty.StateChanged.HasSubscribed testObj.SourceChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)

  /* GetSource */
  actual = ::TestValueStruct (testObj.GetSource())
  expected = ::TestValueStruct countProperty
  assert (actual.Equals expected == true)

  /* SetSourceName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetSourceName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedSourceName = #Count
  actual = ::TestValueStruct (testObj.SetSourceName #Count)
  expected = ::TestValueStruct expectedSourceName
  assert (actual.Equals expected == true)

  /* GetSourceName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct #Count
  assert (actual.Equals expected == true)

  /* SetSourceValue */
  -- 無効な値（期待値はコンバータを通した値）
  expectedSourceValue = "0"
  actual = ::TestValueStruct (testObj.SetSourceValue #Foo)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 成功（期待値はコンバータを通した値）
  expectedSourceValue = "10"
  actual = ::TestValueStruct (testObj.SetSourceValue 10)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)

  /* GetSourceValue */
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)

  /* SetTarget */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTarget 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedTarget = RltTest.Edt
  expectedTargetEnabled = true
  actual = ::TestValueStruct (testObj.SetTarget RltTest.Edt)
  expected = ::TestValueStruct expectedTarget
  assert (actual.Equals expected == true)
  -- `Enabled`確認
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct ""
  assert (actual.Equals expected == true)

  /* GetTarget */
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct RltTest.Edt
  assert (actual.Equals expected == true)

  /* GetTargetName */
  actual = ::TestValueStruct (testObj.GetTargetName())
  expected = ::TestValueStruct #Edt
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
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct ""
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
  expectedTargetEventName = #Entered
  actual = ::TestValueStruct (testObj.SetTargetEventName #Entered)
  expected = ::TestValueStruct expectedTargetEventName
  assert (actual.Equals expected == true)

  /* GetTargetEventName */
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct #Entered
  assert (actual.Equals expected == true)

  /* SetTargetPropertyName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetTargetPropertyName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（期待値はコンバータを通した値）
  expectedTargetEnabled = true
  expectedTargetPropertyName = #Text
  expectedTargetPropertyValue = 10
  actual = ::TestValueStruct (testObj.SetTargetPropertyName #Text)
  expected = ::TestValueStruct expectedTargetPropertyName
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)

  /* GetTargetPropertyName */
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct #Text
  assert (actual.Equals expected == true)

  /* SetTargetPropertyValue */
  -- 無効な値（期待値はコンバータを通した値）
  expectedTargetEnabled = true
  expectedTargetPropertyValue = 10
  actual = ::TestValueStruct (testObj.SetTargetPropertyValue #Foo)
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- 成功（期待値はコンバータを通した値）
  expectedTargetEnabled = true
  expectedTargetPropertyValue = 20
  actual = ::TestValueStruct (testObj.SetTargetPropertyValue "20")
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct "20"
  assert (actual.Equals expected == true)

  /* GetTargetPropertyValue */
  actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
  expected = ::TestValueStruct 20
  assert (actual.Equals expected == true)

  /* Refresh */
  -- 成功（ソースの状態を反映）
  expectedTargetEnabled = true
  expectedTargetPropertyValue = 10
  actual = ::TestValueStruct (testObj.Refresh())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)

  /* SourceChanged */
  -- 成功（通知データは使用しない）
  expectedTargetPropertyValue = 10
  actual = ::TestValueStruct (testObj.SourceChanged #PropertyValue 30)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ターゲットオブジェクトの状態を確認
  actual = ::TestValueStruct RltTest.Edt.Enabled
  expected = ::TestValueStruct expectedTargetEnabled
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct RltTest.Edt.Text
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)

  /* TargetChanged */
  -- 成功（通知データは使用しない）
  expectedSourceValue = "10"
  actual = ::TestValueStruct (
    testObj.TargetChanged #TargetChanged (eventDef RltTest.Edt #Entered "40")
  )
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* 作成パラメータ */
  testObj = testDef #Count RltTest.Edt #Entered #Text
  testObj.StateChanged.Subscribe testNotification

  /* GetSourceName */
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct #Count
  assert (actual.Equals expected == true)

  /* GetTarget */
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct RltTest.Edt
  assert (actual.Equals expected == true)

  /* GetTargetEventName */
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct #Entered
  assert (actual.Equals expected == true)

  /* GetTargetPropertyName */
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct #Text
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef #Count RltTest.Edt #Entered #Text)
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  destroyDialog RltTest
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
