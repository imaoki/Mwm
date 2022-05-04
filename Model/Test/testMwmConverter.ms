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
  local testToSourceFunction
  fn testToSourceFunction input = (
    input as Integer
  )

  local testToTargetFunction
  fn testToTargetFunction input = (
    input as String
  )

  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  testDef = ::mwmDefinitionPool[@"Model\MwmConverter.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()

  /* GetToSourceFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetToSourceFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetToTargetFunction */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetToTargetFunction())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* SetToSourceFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetToSourceFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.SetToSourceFunction testToSourceFunction)
  expected = ::TestValueStruct testToSourceFunction
  assert (actual.Equals expected == true)

  /* SetToTargetFunction */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetToTargetFunction 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.SetToTargetFunction testToTargetFunction)
  expected = ::TestValueStruct testToTargetFunction
  assert (actual.Equals expected == true)

  /* ToSource */
  actual = ::TestValueStruct (testObj.ToSource "1")
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* ToTarget */
  actual = ::TestValueStruct (testObj.ToTarget 1)
  expected = ::TestValueStruct "1"
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef testToTargetFunction testToSourceFunction
  -- ソース用に変換する関数を確認
  actual = ::TestValueStruct (testObj.GetToSourceFunction())
  expected = ::TestValueStruct testToSourceFunction
  assert (actual.Equals expected == true)
  -- ターゲット用に変換する関数を確認
  actual = ::TestValueStruct (testObj.GetToTargetFunction())
  expected = ::TestValueStruct testToTargetFunction
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef testToTargetFunction testToSourceFunction)
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
