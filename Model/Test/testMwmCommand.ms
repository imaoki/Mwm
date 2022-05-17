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
  local eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local TestModelStruct
  struct TestModelStruct (
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

  local expectedCanExecute = true
  local expectedCanExecuteCondition = undefined
  local expectedCommandName = undefined
  local expectedExecuteCondition = undefined
  local expectedExecuteFunction = undefined
  local expectedModel = undefined
  local expectedModelAttribute = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#CanExecuteChanged): (
        actual = ::TestValueStruct (testObj.CanExecute())
        expected = ::TestValueStruct expectedCanExecute
        assert (actual.Equals expected == true)
      )
      (#CanExecuteCondition): (
        actual = ::TestValueStruct (testObj.GetCanExecuteCondition())
        expected = ::TestValueStruct expectedCanExecuteCondition
        assert (actual.Equals expected == true)
      )
      (#CommandName): (
        actual = ::TestValueStruct (testObj.GetCommandName())
        expected = ::TestValueStruct expectedCommandName
        assert (actual.Equals expected == true)
      )
      (#ExecuteCondition): (
        actual = ::TestValueStruct (testObj.GetExecuteCondition())
        expected = ::TestValueStruct expectedExecuteCondition
        assert (actual.Equals expected == true)
      )
      (#ExecuteFunction): (
        actual = ::TestValueStruct (testObj.GetExecuteFunction())
        expected = ::TestValueStruct expectedExecuteFunction
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
      default: ()
    )
    ok
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

  local model = TestModelStruct()
  local modelAttribute = modelAttributeDef #TestModel
  local firstNameAttribute = modelAttributeDef #TestModel #FirstName #GetFirstName #SetFirstName
  local lastNameAttribute = modelAttributeDef #TestModel #LastName #GetLastName #SetLastName
  local firstNameProperty = propertyDef #FirstName "" firstNameAttribute
  local lastNameProperty = propertyDef #LastName "" lastNameAttribute

  local dummyCanExecuteCondition = conditionDef()
  local canExecuteCondition = conditionDef testCanExecuteFunction
  canExecuteCondition.AddProperty firstNameProperty
  canExecuteCondition.AddProperty lastNameProperty
  local executeCondition = conditionDef()
  executeCondition.AddProperty firstNameProperty
  executeCondition.AddProperty lastNameProperty

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

  /* GetCanExecuteCondition */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCanExecuteCondition())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetCommandName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCommandName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetExecuteCondition */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecuteCondition())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetExecuteFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetExecuteFunction())
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

  /* RaiseCanExecuteChanged */
  -- コマンドが実行可能かどうかを判定する条件オブジェクトが未定義なので失敗
  expectedCanExecute = true
  actual = ::TestValueStruct (testObj.RaiseCanExecuteChanged #PropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* SetCanExecuteCondition */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetCanExecuteCondition 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedCanExecuteCondition = dummyCanExecuteCondition
  actual = ::TestValueStruct (testObj.SetCanExecuteCondition dummyCanExecuteCondition)
  expected = ::TestValueStruct expectedCanExecuteCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (dummyCanExecuteCondition.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedCanExecuteCondition = canExecuteCondition
  actual = ::TestValueStruct (testObj.SetCanExecuteCondition canExecuteCondition)
  expected = ::TestValueStruct expectedCanExecuteCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (canExecuteCondition.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 通知元の購読解除を確認（dummyCanExecuteCondition）
  actual = ::TestValueStruct (dummyCanExecuteCondition.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct false
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

  /* SetExecuteCondition */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetExecuteCondition 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedExecuteCondition = executeCondition
  actual = ::TestValueStruct (testObj.SetExecuteCondition executeCondition)
  expected = ::TestValueStruct expectedExecuteCondition
  assert (actual.Equals expected == true)
  -- 通知元の購読を確認
  actual = ::TestValueStruct (executeCondition.StateChanged.HasSubscribed testObj.RaiseCanExecuteChanged)
  expected = ::TestValueStruct false
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
  testObj = testDef #Submit testExecuteFunction executeCondition canExecuteCondition modelAttribute
  testObj.CanExecuteChanged.Subscribe testNotification
  testObj.StateChanged.Subscribe testNotification
  -- GetCommandName
  actual = ::TestValueStruct (testObj.GetCommandName())
  expected = ::TestValueStruct #Submit
  assert (actual.Equals expected == true)
  -- GetCanExecuteCondition
  actual = ::TestValueStruct (testObj.GetCanExecuteCondition())
  expected = ::TestValueStruct canExecuteCondition
  assert (actual.Equals expected == true)
  -- GetExecuteCondition
  actual = ::TestValueStruct (testObj.GetExecuteCondition())
  expected = ::TestValueStruct executeCondition
  assert (actual.Equals expected == true)
  -- GetExecuteFunction
  actual = ::TestValueStruct (testObj.GetExecuteFunction())
  expected = ::TestValueStruct testExecuteFunction
  assert (actual.Equals expected == true)
  -- GetModelAttribute
  actual = ::TestValueStruct (testObj.GetModelAttribute())
  expected = ::TestValueStruct modelAttribute
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (
    testDef #Submit testExecuteFunction executeCondition canExecuteCondition modelAttribute
  )
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
