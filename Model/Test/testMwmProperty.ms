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
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]

  local TestModelStruct
  struct TestModelStruct (
    private count = 0,

    /*
    public fn Decrement = (),
    public fn GetCount = (),
    public fn Increment = (),
    public fn SetCount input = (),
    */

    /*-
    @returns <OkClass>
    */
    public fn Decrement = (
      this.SetCount (this.count - 1)
      ok
    ),

    /*-
    @returns <Integer>
    */
    public fn GetCount = (
      this.count
    ),

    /*-
    @returns <OkClass>
    */
    public fn Increment = (
      this.SetCount (this.count + 1)
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
          and obj.GetCount() == this.GetCount()

      isEqualStructName and isEqualProperties
    ),

    /*- @prop <Struct:ObservableStruct> */
    public StateChanged,

    on Create do (
      this.StateChanged = ::std.ObservableStruct()
    )
  )

  local expectedModel = undefined
  local expectedModelAttribute = undefined
  local expectedPropertyName = undefined
  local expectedPropertyValue = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
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

  local config = ::std.ConfigStruct()
  local model = TestModelStruct()
  local modelAttribute = modelAttributeDef #TestModel #Count #GetCount #SetCount
  local property2 = undefined

  testDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

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

  /* Load */
  -- プロパティ名未定義なので失敗
  actual = ::TestValueStruct (testObj.Load config #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- プロパティ値を確認
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct undefined
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
  expectedModelAttribute = modelAttribute
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SetModelAttribute modelAttribute)
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

  /* 作成パラメータ */
  testObj = testDef #Count 0 modelAttribute
  testObj.StateChanged.Subscribe testNotification
  -- GetModelAttribute
  actual = ::TestValueStruct (testObj.GetModelAttribute())
  expected = ::TestValueStruct modelAttribute
  assert (actual.Equals expected == true)
  -- GetPropertyName
  actual = ::TestValueStruct (testObj.GetPropertyName())
  expected = ::TestValueStruct #Count
  assert (actual.Equals expected == true)
  -- GetPropertyValue
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* SetPropertyValue */
  -- 成功
  expectedPropertyValue = 33
  actual = ::TestValueStruct (testObj.SetPropertyValue 33)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- モデルの値を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)

  /* SetModel */
  -- 成功
  expectedModel = model
  expectedPropertyValue = 0
  actual = ::TestValueStruct (testObj.SetModel model)
  expected = ::TestValueStruct expectedModel
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認（成功）
  actual = ::TestValueStruct (model.StateChanged.HasSubscribed testObj.SynchronizeWithModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- プロパティ値を確認（モデルと同期される）
  actual = ::TestValueStruct (testObj.GetPropertyValue())
  expected = ::TestValueStruct expectedPropertyValue
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  property2 = testDef #Count 0 modelAttribute
  property2.SetModel model
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct property2
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
