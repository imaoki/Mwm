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
  local eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local TestModelStruct
  struct TestModelStruct (
    public PostProcessValue,
    public PreProcessValue,

    private firstName = "",
    private fullName = "",
    private lastName = "",

    /*
    public fn GetFirstName = (),
    public fn GetFullName = (),
    public fn GetLastName = (),
    public fn SetFirstName input = (),
    public fn SetLastName input = (),
    public fn Submit input = (),
    */

    /*-
    @returns <String>
    */
    public fn GetFirstName = (
      this.firstName
    ),

    /*-
    @returns <String>
    */
    public fn GetFullName = (
      this.fullName
    ),

    /*-
    @returns <String>
    */
    public fn GetLastName = (
      this.lastName
    ),

    /*-
    @param input <String>
    @returns <String>
    */
    public fn SetFirstName input = (
      if classOf input == String do (
        this.firstName = input
        this.StateChanged.Notify #FirstName this.firstName
      )
      this.GetFirstName()
    ),

    /*-
    @param input <String>
    @returns <String>
    */
    public fn SetLastName input = (
      if classOf input == String do (
        this.lastName = input
        this.StateChanged.Notify #LastName this.lastName
      )
      this.GetLastName()
    ),

    /*-
    @param input1 <String>
    @param input2 <String>
    @returns <OkClass>
    */
    public fn Submit input1 input2 = (
      if classOf input1 == String and classOf input2 == String do (
        this.fullName = input1 + input2
        this.StateChanged.Notify #FullName this.fullName
      )
      this.GetFullName()
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
      format "%  firstName:%\n" indent this.firstName to:out
      format "%  fullName:%\n" indent this.fullName to:out
      format "%  lastName:%\n" indent this.lastName to:out
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
          and isProperty obj #GetFirstName \
          and classOf obj.GetFirstName == MAXScriptFunction \
          and obj.GetFirstName() == this.GetFirstName() \
          and isProperty obj #GetFullName \
          and classOf obj.GetFullName == MAXScriptFunction \
          and obj.GetFullName() == this.GetFullName() \
          and isProperty obj #GetLastName \
          and classOf obj.GetLastName == MAXScriptFunction \
          and obj.GetLastName() == this.GetLastName()

      isEqualStructName and isEqualProperties
    ),

    /*- @prop <Struct:ObservableStruct> */
    public StateChanged,

    on Create do (
      this.StateChanged = ::std.ObservableStruct()
    )
  )

  local testCanExecuteFunction
  fn testCanExecuteFunction params = (
    params.Count == 2 \
        and params[1].Name == #FirstName \
        and classOf params[1].Value == String \
        and params[1].Value.Count > 0 \
        and params[2].Name == #LastName \
        and classOf params[2].Value == String \
        and params[2].Value.Count > 0
  )

  local testExecuteFunction
  fn testExecuteFunction model params event = (
    model.Submit params[1].Value params[2].Value
    ok
  )

  local testPostProcessFunction
  fn testPostProcessFunction model params event = (
    model.PostProcessValue = 1
    ok
  )

  local testPreProcessFunction
  fn testPreProcessFunction model params event = (
    model.PreProcessValue = 2
    ok
  )

  local expectedCanExecute = true
  local expectedCanExecuteFunction = undefined
  local expectedCanExecuteProperties = #()
  local expectedCommandName = undefined
  local expectedExecuteFunction = undefined
  local expectedExecuteProperties = #()
  local expectedModel = undefined
  local expectedModelAttribute = undefined
  local expectedPostProcessFunction = undefined
  local expectedPreProcessFunction = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#CanExecuteChanged): (
        actual = ::TestValueStruct (testObj.CanExecute())
        expected = ::TestValueStruct expectedCanExecute
        assert (actual.Equals expected == true)
      )
      (#CanExecuteFunction): (
        actual = ::TestValueStruct (testObj.GetCanExecuteFunction())
        expected = ::TestValueStruct expectedCanExecuteFunction
        assert (actual.Equals expected == true)
      )
      (#CanExecuteProperties): (
        actual = ::TestValueStruct (testObj.GetCanExecuteProperties())
        expected = ::TestValueStruct expectedCanExecuteProperties
        assert (actual.Equals expected == true)
      )
      (#CommandName): (
        actual = ::TestValueStruct (testObj.GetCommandName())
        expected = ::TestValueStruct expectedCommandName
        assert (actual.Equals expected == true)
      )
      (#ExecuteFunction): (
        actual = ::TestValueStruct (testObj.GetExecuteFunction())
        expected = ::TestValueStruct expectedExecuteFunction
        assert (actual.Equals expected == true)
      )
      (#ExecuteProperties): (
        actual = ::TestValueStruct (testObj.GetExecuteProperties())
        expected = ::TestValueStruct expectedExecuteProperties
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
      (#PostProcessFunction): (
        actual = ::TestValueStruct (testObj.GetPostProcessFunction())
        expected = ::TestValueStruct expectedPostProcessFunction
        assert (actual.Equals expected == true)
      )
      (#PreProcessFunction): (
        actual = ::TestValueStruct (testObj.GetPreProcessFunction())
        expected = ::TestValueStruct expectedPreProcessFunction
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local model = TestModelStruct()
  local modelAttribute = modelAttributeDef #TestModel
  local firstNameAttribute = modelAttributeDef #TestModel #FirstName #GetFirstName #SetFirstName
  local lastNameAttribute = modelAttributeDef #TestModel #LastName #GetLastName #SetLastName
  local firstNameProperty = propertyDef #FirstName "" firstNameAttribute
  local lastNameProperty = propertyDef #LastName "" lastNameAttribute
  local command2 = undefined

  testDef = ::mwmDefinitionPool[@"Model\MwmCommand.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.CanExecuteChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification

  /* CanExecute */
  -- 既定値
  actual = ::TestValueStruct (testObj.CanExecute())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Execute */
  actual = ::TestValueStruct (testObj.Execute (eventDef()))
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* GetCanExecuteFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCanExecuteFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetCanExecuteProperties */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCanExecuteProperties())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetCanExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.GetCanExecuteProperty 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCanExecuteProperty #Foo)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetCanExecutePropertyNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCanExecutePropertyNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetCommandName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCommandName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetExecuteFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecuteFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetExecuteProperties */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecuteProperties())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.GetExecuteProperty 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecuteProperty #Foo)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetExecutePropertyNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecutePropertyNames())
  expected = ::TestValueStruct #()
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

  /* GetPostProcessFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPostProcessFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetPreProcessFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPreProcessFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* HasCanExecuteProperty */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty firstNameProperty)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty #FirstName)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasExecuteProperty */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasExecuteProperty firstNameProperty)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasExecuteProperty #FirstName)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* AddCanExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddCanExecuteProperty 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedCanExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddCanExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認（成功）
  actual = ::TestValueStruct (firstNameProperty.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 重複登録（成功するが既に存在するので何もしない）
  expectedCanExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddCanExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedCanExecuteProperties = #(
    firstNameProperty,
    lastNameProperty
  )
  actual = ::TestValueStruct (testObj.AddCanExecuteProperty lastNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認（成功）
  actual = ::TestValueStruct (lastNameProperty.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* AddExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddExecuteProperty 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 重複登録（成功するが既に存在するので何もしない）
  expectedExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedExecuteProperties = #(
    firstNameProperty,
    lastNameProperty
  )
  actual = ::TestValueStruct (testObj.AddExecuteProperty lastNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* HasCanExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty lastNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty #FirstName)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasCanExecuteProperty #LastName)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* HasExecuteProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.HasExecuteProperty 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasExecuteProperty lastNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasExecuteProperty #FirstName)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasExecuteProperty #LastName)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* RaiseCanExecuteChanged */
  expectedCanExecute = true
  actual = ::TestValueStruct (testObj.RaiseCanExecuteChanged #PropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* SetCanExecuteFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetCanExecuteFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedCanExecuteFunction = testCanExecuteFunction
  actual = ::TestValueStruct (testObj.SetCanExecuteFunction testCanExecuteFunction)
  expected = ::TestValueStruct expectedCanExecuteFunction
  assert (actual.Equals expected == true)

  /* SetCommandName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetCommandName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedCommandName = #Submit
  actual = ::TestValueStruct (testObj.SetCommandName #Submit)
  expected = ::TestValueStruct expectedCommandName
  assert (actual.Equals expected == true)

  /* SetExecuteFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetExecuteFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedExecuteFunction = testExecuteFunction
  actual = ::TestValueStruct (testObj.SetExecuteFunction testExecuteFunction)
  expected = ::TestValueStruct expectedExecuteFunction
  assert (actual.Equals expected == true)

  /* SetModel */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetModel 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedModel = model
  actual = ::TestValueStruct (testObj.SetModel model)
  expected = ::TestValueStruct expectedModel
  assert (actual.Equals expected == true)

  /* SetModelAttribute */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetModelAttribute 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedModelAttribute = modelAttribute
  actual = ::TestValueStruct (testObj.SetModelAttribute modelAttribute)
  expected = ::TestValueStruct expectedModelAttribute
  assert (actual.Equals expected == true)

  /* SetPostProcessFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetPostProcessFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedPostProcessFunction = testPostProcessFunction
  actual = ::TestValueStruct (testObj.SetPostProcessFunction testPostProcessFunction)
  expected = ::TestValueStruct expectedPostProcessFunction
  assert (actual.Equals expected == true)

  /* SetPreProcessFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetPreProcessFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedPreProcessFunction = testPreProcessFunction
  actual = ::TestValueStruct (testObj.SetPreProcessFunction testPreProcessFunction)
  expected = ::TestValueStruct expectedPreProcessFunction
  assert (actual.Equals expected == true)

  /* CanExecute */
  actual = ::TestValueStruct (testObj.CanExecute())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- -- FirstName変更（プロパティオブジェクトからの通知で`RaiseCanExecuteChanged`が呼ばれる）
  expectedCanExecute = false
  firstNameProperty.SetPropertyValue "foo"
  -- -- LastName変更（プロパティオブジェクトからの通知で`RaiseCanExecuteChanged`が呼ばれる）
  expectedCanExecute = true
  lastNameProperty.SetPropertyValue "bar"

  /* Execute */
  actual = ::TestValueStruct (testObj.Execute (eventDef()))
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- FullName確認
  actual = ::TestValueStruct (model.GetFullName())
  expected = ::TestValueStruct "foobar"
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef #Submit testExecuteFunction testCanExecuteFunction modelAttribute
  testObj.CanExecuteChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification
  -- GetCanExecuteFunction
  actual = ::TestValueStruct (testObj.GetCanExecuteFunction())
  expected = ::TestValueStruct testCanExecuteFunction
  assert (actual.Equals expected == true)
  -- GetExecuteFunction
  actual = ::TestValueStruct (testObj.GetExecuteFunction())
  expected = ::TestValueStruct testExecuteFunction
  assert (actual.Equals expected == true)
  -- GetModelAttribute
  actual = ::TestValueStruct (testObj.GetModelAttribute())
  expected = ::TestValueStruct modelAttribute
  assert (actual.Equals expected == true)

  /* SetModel */
  -- 成功
  expectedModel = model
  actual = ::TestValueStruct (testObj.SetModel model)
  expected = ::TestValueStruct expectedModel
  assert (actual.Equals expected == true)

  /* AddCanExecuteProperty */
  -- 成功
  expectedCanExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddCanExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* AddExecuteProperty */
  -- 成功
  expectedExecuteProperties = #(
    firstNameProperty
  )
  actual = ::TestValueStruct (testObj.AddExecuteProperty firstNameProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  command2 = testDef #Submit testExecuteFunction testCanExecuteFunction modelAttribute
  command2.SetModel model
  command2.AddCanExecuteProperty firstNameProperty
  command2.AddExecuteProperty firstNameProperty
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct command2
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
