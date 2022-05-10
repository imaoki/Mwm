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
  local MnuTest
  rcMenu MnuTest (
    menuItem Mi "Increment"
  )

  local RltTest
  rollout RltTest "Test" (
    button Btn "ButtonControl"
    editText Edt "EditTextControl"
  )

  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  testDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()

  /* GetControl */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetControl())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetEventName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetEventName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetParams */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetParams())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* SetControl */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetControl 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetControl "Btn")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（ロールアウト定義）
  actual = ::TestValueStruct (testObj.SetControl RltTest)
  expected = ::TestValueStruct RltTest
  assert (actual.Equals expected == true)
  -- 成功（ロールアウトコントロール）
  actual = ::TestValueStruct (testObj.SetControl RltTest.Btn)
  expected = ::TestValueStruct RltTest.Btn
  assert (actual.Equals expected == true)
  -- 成功（メニュー定義）
  actual = ::TestValueStruct (testObj.SetControl MnuTest)
  expected = ::TestValueStruct MnuTest
  assert (actual.Equals expected == true)
  -- 成功（メニューアイテム）
  actual = ::TestValueStruct (testObj.SetControl MnuTest.Mi)
  expected = ::TestValueStruct MnuTest.Mi
  assert (actual.Equals expected == true)

  /* SetEventName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetEventName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetEventName "Pressed")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.SetEventName #Pressed)
  expected = ::TestValueStruct #Pressed
  assert (actual.Equals expected == true)

  /* SetParams */
  -- 成功（配列以外の値）
  actual = ::TestValueStruct (testObj.SetParams 0)
  expected = ::TestValueStruct #(0)
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.SetParams #(0, true))
  expected = ::TestValueStruct #(0, true)
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef RltTest.Edt #Entered #("Foo")
  -- コントロール名を確認
  actual = ::TestValueStruct (testObj.GetControl())
  expected = ::TestValueStruct RltTest.Edt
  assert (actual.Equals expected == true)
  -- イベント名を確認
  actual = ::TestValueStruct (testObj.GetEventName())
  expected = ::TestValueStruct #Entered
  assert (actual.Equals expected == true)
  -- イベントデータを確認
  actual = ::TestValueStruct (testObj.GetParams())
  expected = ::TestValueStruct #("Foo")
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef RltTest.Edt #Entered #("Foo"))
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
