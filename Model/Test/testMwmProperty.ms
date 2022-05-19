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
  local conditionDef = ::mwmDefinitionPool[@"Model\MwmCondition.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]

  local TestModelStruct
  struct TestModelStruct (
    private count = 0,
    private step = 1,

    /*
    public fn Decrement subtrahend = (),
    public fn GetCount = (),
    public fn GetStep = (),
    public fn Increment addend = (),
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

  local expectedEnabledCondition = undefined
  local expectedIsEnabled = true
  local expectedModel = undefined
  local expectedModelAttribute = undefined
  local expectedPropertyName = undefined
  local expectedPropertyValue = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#EnabledChanged): (
        actual = ::TestValueStruct (testObj.IsEnabled())
        expected = ::TestValueStruct expectedIsEnabled
        assert (actual.Equals expected == true)
      )
      (#EnabledCondition): (
        actual = ::TestValueStruct (testObj.GetEnabledCondition())
        expected = ::TestValueStruct expectedEnabledCondition
        assert (actual.Equals expected == true)
      )
      (#Model): (
        actual = ::TestValueStruct (testObj.GetModel())
        expected = ::TestValueStruct expectedModel
        assert (actual.Equals expected == true)
      )
      (#ModelAttribute): (
        actual = ::TestValueStruct (testObj.GetModelAttribute())
        expected = ::TestValueStruct expectedModelAttribute
        assert (actual.Equals expected == true)
      )
      (#PropertyName): (
        actual = ::TestValueStruct (testObj.GetPropertyName())
        expected = ::TestValueStruct expectedPropertyName
        assert (actual.Equals expected == true)
      )
      (#PropertyValue): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedPropertyValue
        assert (actual.Equals expected == true)
        actual = ::TestValueStruct (testObj.GetPropertyValue())
        expected = ::TestValueStruct expectedPropertyValue
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local testEnabledFunction
  fn testEnabledFunction params = (
    params[1].Value != 0
  )

  local config = ::std.ConfigStruct()
  local model = TestModelStruct()
  local countAttribute = modelAttributeDef #TestModel #Count #GetCount #SetCount
  local stepAttribute = modelAttributeDef #TestModel #Step #GetStep #SetStep

  local dummyEnabledCondition = conditionDef()
  local enabledCondition = conditionDef testEnabledFunction
  local stepProperty = undefined

  testDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.EnabledChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification

  /* GetEnabledCondition */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetEnabledCondition())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModel())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetModelAttribute */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModelAttribute())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetPropertyName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetPropertyValue */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* IsEnabled */
  -- 既定値
  actual = ::TestValueStruct (testObj.IsEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Load */
  -- プロパティ名未定義なので失敗
  actual = ::TestValueStruct (testObj.Load config #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* RaiseEnabledChanged */
  -- プロパティが使用可能かどうかを判定する条件オブジェクトが未定義なので失敗
  expectedIsEnabled = true
  actual = ::TestValueStruct (testObj.RaiseEnabledChanged #ConditionChanged 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* Save */
  -- プロパティ名未定義なので失敗
  actual = ::TestValueStruct (testObj.Save config #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 設定オブジェクトのキーを確認
  actual = ::TestValueStruct (config.HasValue #'TestViewModel.Count')
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* SetEnabledCondition */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetEnabledCondition 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedEnabledCondition = dummyEnabledCondition
  actual = ::TestValueStruct (testObj.SetEnabledCondition dummyEnabledCondition)
  expected = ::TestValueStruct expectedEnabledCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (dummyEnabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedEnabledCondition = enabledCondition
  actual = ::TestValueStruct (testObj.SetEnabledCondition enabledCondition)
  expected = ::TestValueStruct expectedEnabledCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (enabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 通知元の購読解除を確認（dummyEnabledCondition）
  actual = ::TestValueStruct (dummyEnabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* SetModel */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetModel 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedModel = model
  expectedPropertyValue = undefined
  actual = ::TestValueStruct (testObj.SetModel model)
  expected = ::TestValueStruct expectedModel
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認（モデル属性が未設定なので失敗）
  actual = ::TestValueStruct (model.StateChanged.HasSubscribed testObj.SynchronizeWithModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- プロパティ値を確認（モデル属性が未設定なので同期されない）
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct expectedPropertyValue
  assert (actual.Equals expected == true)

  /* SetModelAttribute */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetModelAttribute 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedModelAttribute = countAttribute
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SetModelAttribute countAttribute)
  expected = ::TestValueStruct expectedModelAttribute
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認（成功）
  actual = ::TestValueStruct (model.StateChanged.HasSubscribed testObj.SynchronizeWithModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- プロパティ値を確認（モデルと同期される）
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct expectedPropertyValue
  assert (actual.Equals expected == true)

  /* SetPropertyName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetPropertyName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedPropertyName = #Count
  actual = ::TestValueStruct (testObj.SetPropertyName #Count)
  expected = ::TestValueStruct expectedPropertyName
  assert (actual.Equals expected == true)

  /* SetPropertyValue */
  -- 成功
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SetPropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* SynchronizeWithModel */
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SynchronizeWithModel #Count 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* Load */
  -- モデル属性が設定されているので失敗
  actual = ::TestValueStruct (testObj.Load config #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* Save */
  -- モデル属性が設定されているので失敗
  actual = ::TestValueStruct (testObj.Save config #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 設定オブジェクトのキーを確認
  actual = ::TestValueStruct (config.HasValue #'TestViewModel.Count')
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* SetModelAttribute */
  -- 未定義に設定
  expectedModelAttribute = undefined
  actual = ::TestValueStruct (testObj.SetModelAttribute undefined)
  expected = ::TestValueStruct expectedModelAttribute
  assert (actual.Equals expected == true)

  /* Save */
  -- 成功
  actual = ::TestValueStruct (testObj.Save config #TestViewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 設定オブジェクトのキーを確認
  actual = ::TestValueStruct (config.HasValue #'TestViewModel.Count')
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 設定オブジェクトの値を確認
  actual = ::TestValueStruct (config.GetValue #'TestViewModel.Count')
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* SetPropertyValue */
  -- 成功
  expectedPropertyValue = 3
  actual = ::TestValueStruct (testObj.SetPropertyValue 3)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* Load */
  -- 成功
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.Load config #TestViewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct expectedPropertyValue
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 全ての購読を解除 */
  actual = ::TestValueStruct (dummyEnabledCondition.StateChanged.Unsubscribe testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (enabledCondition.StateChanged.Unsubscribe testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 通知元の購読解除を確認
  actual = ::TestValueStruct (dummyEnabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (enabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 数を確認
  actual = ::TestValueStruct (dummyEnabledCondition.StateChanged.Count())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (enabledCondition.StateChanged.Count())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* 作成パラメータ */
  testObj = testDef #Count 0 countAttribute
  testObj.EnabledChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification
  -- GetModelAttribute
  actual = ::TestValueStruct (testObj.GetModelAttribute())
  expected = ::TestValueStruct countAttribute
  assert (actual.Equals expected == true)
  -- GetPropertyName
  actual = ::TestValueStruct (testObj.GetPropertyName())
  expected = ::TestValueStruct #Count
  assert (actual.Equals expected == true)
  -- GetPropertyValue
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef #Count 0 countAttribute)
  assert (actual.Equals expected == true)

  /* Enabledをテスト */
  -- オブジェクトを初期化
  model = TestModelStruct()
  enabledCondition = conditionDef testEnabledFunction
  -- stepProperty作成
  stepProperty = testDef #Step 1 stepAttribute
  stepProperty.SetModel model
  enabledCondition.AddProperty stepProperty
  -- 通知元の購読を確認
  actual = ::TestValueStruct (stepProperty.StateChanged.HasSubscribed enabledCondition.PropertyValueChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- testObj作成
  testObj = testDef #Count 0 countAttribute
  testObj.EnabledChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification
  -- SetModel
  expectedModel = model
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SetModel model)
  expected = ::TestValueStruct expectedModel
  assert (actual.Equals expected == true)
  -- SetEnabledCondition
  expectedEnabledCondition = enabledCondition
  actual = ::TestValueStruct (testObj.SetEnabledCondition enabledCondition)
  expected = ::TestValueStruct expectedEnabledCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (enabledCondition.StateChanged.HasSubscribed testObj.RaiseEnabledChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- modelの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- プロパティの値を確認
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)
  -- IsEnabled
  actual = ::TestValueStruct (testObj.IsEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- stepPropertyの状態を変更
  expectedIsEnabled = false
  actual = ::TestValueStruct (stepProperty.SetPropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- modelの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- stepPropertyの状態を変更
  expectedIsEnabled = true
  actual = ::TestValueStruct (stepProperty.SetPropertyValue -1)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- modelの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct -1
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
