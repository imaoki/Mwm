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
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local expectedEvaluator = undefined
  local expectedProperties = #()
  local expectedPropertyValue = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#ConditionChanged): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedPropertyValue
        assert (actual.Equals expected == true)
      )
      (#Evaluator): (
        actual = ::TestValueStruct (testObj.GetEvaluator())
        expected = ::TestValueStruct expectedEvaluator
        assert (actual.Equals expected == true)
      )
      (#Properties): (
        actual = ::TestValueStruct (testObj.GetProperties())
        expected = ::TestValueStruct expectedProperties
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local testEvaluator
  fn testEvaluator params = (
    params.Count == 2 \
        and params[1].Name == #Array \
        and classOf params[1].Value == Array \
        and params[1].Value.Count > 0 \
        and params[2].Name == #Integer \
        and params[2].Value > 0
  )

  local arrayProperty = propertyDef #Array #()
  local integerProperty = propertyDef #Integer 0

  testDef = ::mwmDefinitionPool[@"Model\MwmCondition.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

  /* Evaluate */
  -- 既定値
  actual = ::TestValueStruct (testObj.Evaluate())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetEvaluator */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetEvaluator())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetProperties */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetProperties())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetProperty */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetProperty #Integer)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetPropertyNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* HasProperty */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasProperty integerProperty)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasProperty #Integer)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* MakeParams */
  -- 既定値
  actual = ::TestValueStruct (testObj.MakeParams())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* AddProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddProperty #Foo)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedProperties = #(arrayProperty)
  actual = ::TestValueStruct (testObj.AddProperty arrayProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 購読を確認
  actual = ::TestValueStruct (arrayProperty.StateChanged.HasSubscribed testObj.PropertyValueChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 重複登録（登録済みなので成功）
  actual = ::TestValueStruct (testObj.AddProperty arrayProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedProperties = #(arrayProperty, integerProperty)
  actual = ::TestValueStruct (testObj.AddProperty integerProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 購読を確認
  actual = ::TestValueStruct (integerProperty.StateChanged.HasSubscribed testObj.PropertyValueChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetProperties */
  actual = ::TestValueStruct (testObj.GetProperties())
  expected = ::TestValueStruct #(arrayProperty, integerProperty)
  assert (actual.Equals expected == true)

  /* GetProperty */
  -- Array
  actual = ::TestValueStruct (testObj.GetProperty #Array)
  expected = ::TestValueStruct arrayProperty
  assert (actual.Equals expected == true)
  -- Integer
  actual = ::TestValueStruct (testObj.GetProperty #Integer)
  expected = ::TestValueStruct integerProperty
  assert (actual.Equals expected == true)

  /* GetPropertyNames */
  actual = ::TestValueStruct (testObj.GetPropertyNames())
  expected = ::TestValueStruct #(#Array, #Integer)
  assert (actual.Equals expected == true)

  /* HasProperty */
  -- Array
  actual = ::TestValueStruct (testObj.HasProperty arrayProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasProperty #Array)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- Integer
  actual = ::TestValueStruct (testObj.HasProperty integerProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasProperty #Integer)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* SetEvaluator */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetEvaluator #Foo)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedEvaluator = testEvaluator
  actual = ::TestValueStruct (testObj.SetEvaluator testEvaluator)
  expected = ::TestValueStruct expectedEvaluator
  assert (actual.Equals expected == true)

  /* GetEvaluator */
  actual = ::TestValueStruct (testObj.GetEvaluator())
  expected = ::TestValueStruct testEvaluator
  assert (actual.Equals expected == true)

  /* PropertyValueChanged */
  -- Array
  expectedPropertyValue = #(1)
  actual = ::TestValueStruct (arrayProperty.SetPropertyValue #(1))
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- Integer
  expectedPropertyValue = -1
  actual = ::TestValueStruct (integerProperty.SetPropertyValue -1)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)

  /* Evaluate */
  -- 条件を満たさないので失敗
  actual = ::TestValueStruct (testObj.Evaluate())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- Integer
  expectedPropertyValue = 2
  actual = ::TestValueStruct (integerProperty.SetPropertyValue 2)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.Evaluate())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* RemoveProperty */
  -- 無効な値（存在しないので成功）
  actual = ::TestValueStruct (testObj.RemoveProperty #Foo)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  expectedProperties = #(integerProperty)
  actual = ::TestValueStruct (testObj.RemoveProperty arrayProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 存在を確認
  actual = ::TestValueStruct (testObj.HasProperty arrayProperty)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.HasProperty #Array)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 購読解除を確認
  actual = ::TestValueStruct (arrayProperty.StateChanged.HasSubscribed testObj.PropertyValueChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef testEvaluator
  -- GetEvaluator
  actual = ::TestValueStruct (testObj.GetEvaluator())
  expected = ::TestValueStruct testEvaluator
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef testEvaluator)
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
