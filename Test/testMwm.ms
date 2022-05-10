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
  local TestMwmConverterStruct
  struct TestMwmConverterStruct (
    /*- @returns <Name> */
    public fn StructName = #MwmConverterStruct,

    /*-
    @param indent: <String>
    @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
    @returns <OkClass>
    */
    public fn Dump indent:"" out:listener = (
      format "%TestMwmConverterStruct\n" indent to:out
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

      local isEqualProperties = true

      isEqualStructName and isEqualProperties
    ),

    on Create do ()
  )

  local TestMwmViewModelStruct
  struct TestMwmViewModelStruct (
    /*- @returns <Name> */
    public fn StructName = #MwmViewModelStruct,

    /*-
    @param indent: <String>
    @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
    @returns <OkClass>
    */
    public fn Dump indent:"" out:listener = (
      format "%TestMwmViewModelStruct\n" indent to:out
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

      local isEqualProperties = true

      isEqualStructName and isEqualProperties
    ),

    on Create do ()
  )

  local testToSourceFunction
  fn testToSourceFunction input = (
    input as Integer
  )

  local testToTargetFunction
  fn testToTargetFunction input = (
    input as String
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

  local testStructInstance
  fn testStructInstance obj expectedStructName = (
    local passCount = 0
    actual = ::TestValueStruct (isStruct obj)
    expected = ::TestValueStruct true
    if assert (actual.Equals expected == true) do passCount += 1
    actual = ::TestValueStruct (isProperty obj #StructName)
    expected = ::TestValueStruct true
    if assert (actual.Equals expected == true) do passCount += 1
    actual = ::TestValueStruct (classOf obj.StructName)
    expected = ::TestValueStruct MAXScriptFunction
    if assert (actual.Equals expected == true) do passCount += 1
    actual = ::TestValueStruct (obj.StructName())
    expected = ::TestValueStruct expectedStructName
    if assert (actual.Equals expected == true) do passCount += 1
    passCount == 4
  )

  local converter = TestMwmConverterStruct()
  local viewModel = TestMwmViewModelStruct()

  testDef = fileIn (pathUtility.GetFullPath @"..\Mwm.ms")
  testObj = testDef()
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* GetConverter */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConverter #TestConverter)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetConverterNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConverterNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* AddConverter */
  -- 無効な値（コンバータ名）
  actual = ::TestValueStruct (testObj.AddConverter 0 converter)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（コンバータ名）
  actual = ::TestValueStruct (testObj.AddConverter #TestConverter 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.AddConverter #TestConverter converter)
  expected = ::TestValueStruct converter
  assert (actual.Equals expected == true)

  /* GetConverter */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConverter #TestConverter)
  expected = ::TestValueStruct converter
  assert (actual.Equals expected == true)

  /* GetConverterNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConverterNames())
  expected = ::TestValueStruct #(#TestConverter)
  assert (actual.Equals expected == true)

  /* CreateApplication */
  -- 無効な値（アプリケーション名）
  actual = ::TestValueStruct (testObj.CreateApplication 0 #RltTestView)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（起動時に表示されるビューの名前）
  actual = ::TestValueStruct (testObj.CreateApplication #TestApplication 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（アプリケーションファイルのパス）
  actual = ::TestValueStruct (
    testObj.CreateApplication #TestApplication #RltTestView applicationFile:0
  )
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（アプリケーションファイル無し）
  assert (
    testStructInstance \
    (testObj.CreateApplication #TestApplication #RltTestView) \
    #MwmApplicationStruct
  )
  -- 成功（アプリケーションファイル有り）
  assert (
    testStructInstance \
    (
      testObj.CreateApplication \
          #TestApplication #RltTestView applicationFile:currentFile
    ) \
    #MwmApplicationStruct
  )

  /* CreateCommand */
  -- 無効な値
  actual = ::TestValueStruct (testObj.CreateCommand 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  assert (
    testStructInstance \
    (testObj.CreateCommand #TestCommand) \
    #MwmCommandStruct
  )

  /* CreateCommandBinding */
  -- 無効な値（コマンド名）
  actual = ::TestValueStruct (testObj.CreateCommandBinding 0 RltTest.Btn #Pressed)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（ターゲットオブジェクト）
  actual = ::TestValueStruct (testObj.CreateCommandBinding #Increment 0 #Pressed)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（ターゲットのイベント名）
  actual = ::TestValueStruct (testObj.CreateCommandBinding #Increment RltTest.Btn 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（ロールアウト定義）
  assert (
    testStructInstance \
    (testObj.CreateCommandBinding #RolloutOpen RltTest #Open) \
    #MwmBindingStruct
  )
  -- 成功（ロールアウトコントロール）
  assert (
    testStructInstance \
    (testObj.CreateCommandBinding #Increment RltTest.Btn #Pressed) \
    #MwmBindingStruct
  )
  -- 成功（メニュー定義）
  assert (
    testStructInstance \
    (testObj.CreateCommandBinding #MenuOpen MnuTest #Open) \
    #MwmBindingStruct
  )
  -- 成功（メニューアイテム）
  assert (
    testStructInstance \
    (testObj.CreateCommandBinding #Increment MnuTest.Mi #Picked) \
    #MwmBindingStruct
  )

  /* CreateConverter */
  -- 無効な値
  actual = ::TestValueStruct (testObj.CreateConverter 0 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  assert (
    testStructInstance \
    (testObj.CreateConverter testToTargetFunction testToSourceFunction) \
    #MwmConverterStruct
  )

  /* CreateEvent */
  -- 無効な値（ロールアウトコントロール）
  actual = ::TestValueStruct (testObj.CreateEvent 0 #Entered "")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（イベント名）
  actual = ::TestValueStruct (testObj.CreateEvent RltTest.Edt 0 "")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（ロールアウト定義）
  assert (
    testStructInstance \
    (testObj.CreateEvent RltTest #Open "") \
    #MwmEventStruct
  )
  -- 成功（ロールアウトコントロール）
  assert (
    testStructInstance \
    (testObj.CreateEvent RltTest.Edt #Entered "") \
    #MwmEventStruct
  )
  -- 成功（メニュー定義）
  assert (
    testStructInstance \
    (testObj.CreateEvent MnuTest #Open "") \
    #MwmEventStruct
  )
  -- 成功（メニューアイテム）
  assert (
    testStructInstance \
    (testObj.CreateEvent MnuTest.Mi #Picked "") \
    #MwmEventStruct
  )

  /* CreateModelAttribute */
  -- 無効な値
  actual = ::TestValueStruct (testObj.CreateModelAttribute 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  assert (
    testStructInstance \
    (testObj.CreateModelAttribute #TestModel) \
    #MwmModelAttributeStruct
  )

  /* CreateProperty */
  -- 無効な値（プロパティ名）
  actual = ::TestValueStruct (testObj.CreateProperty 0 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  assert (
    testStructInstance \
    (testObj.CreateProperty #TestProperty 0) \
    #MwmPropertyStruct
  )

  /* CreatePropertyBinding */
  -- 無効な値（バインディングにおけるデータフローの方向）
  actual = ::TestValueStruct (testObj.CreatePropertyBinding #1 0 RltTest.Edt #Entered #Text)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（プロパティ名）
  actual = ::TestValueStruct (testObj.CreatePropertyBinding 1 0 RltTest.Edt #Entered #Text)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（ターゲットオブジェクト）
  actual = ::TestValueStruct (testObj.CreatePropertyBinding 1 #Count 0 #Entered #Text)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（ターゲットのイベント名）
  actual = ::TestValueStruct (testObj.CreatePropertyBinding 1 #Count RltTest.Edt 0 #Text)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（ターゲットのプロパティ名）
  actual = ::TestValueStruct (testObj.CreatePropertyBinding 1 #Count RltTest.Edt #Entered 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（ロールアウト定義）
  assert (
    testStructInstance \
    (testObj.CreatePropertyBinding 1 #Count RltTest #Open #Open) \
    #MwmBindingStruct
  )
  -- 成功（ロールアウトコントロール）
  assert (
    testStructInstance \
    (testObj.CreatePropertyBinding 1 #Count RltTest.Edt #Entered #Text) \
    #MwmBindingStruct
  )
  -- 成功（メニュー定義）
  assert (
    testStructInstance \
    (testObj.CreatePropertyBinding 1 #Count MnuTest #Open #Open) \
    #MwmBindingStruct
  )
  -- 成功（メニューアイテム）
  assert (
    testStructInstance \
    (testObj.CreatePropertyBinding 1 #Count MnuTest.Mi #Picked #Checked) \
    #MwmBindingStruct
  )

  /* CreateViewModel */
  -- 無効な値
  actual = ::TestValueStruct (testObj.CreateViewModel 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  assert (
    testStructInstance \
    (testObj.CreateViewModel #TestViewModel) \
    #MwmViewModelStruct
  )

  /* Install */

  /* IsValidViewModel */
  -- 失敗
  actual = ::TestValueStruct (testObj.IsValidViewModel 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.IsValidViewModel viewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Uninstall */

  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
