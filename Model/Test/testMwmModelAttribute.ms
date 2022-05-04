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
  local expectedGetterName = undefined
  local expectedModelName = undefined
  local expectedObservableName = undefined
  local expectedPropertyName = undefined
  local expectedSetterName = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#GetterName): (
        actual = ::TestValueStruct (testObj.GetGetterName())
        expected = ::TestValueStruct expectedGetterName
        assert (actual.Equals expected == true)
      )
      (#ModelName): (
        actual = ::TestValueStruct (testObj.GetModelName())
        expected = ::TestValueStruct expectedModelName
        assert (actual.Equals expected == true)
      )
      (#ObservableName): (
        actual = ::TestValueStruct (testObj.GetObservableName())
        expected = ::TestValueStruct expectedObservableName
        assert (actual.Equals expected == true)
      )
      (#PropertyName): (
        actual = ::TestValueStruct (testObj.GetPropertyName())
        expected = ::TestValueStruct expectedPropertyName
        assert (actual.Equals expected == true)
      )
      (#SetterName): (
        actual = ::TestValueStruct (testObj.GetSetterName())
        expected = ::TestValueStruct expectedSetterName
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  fileIn (pathUtility.GetFullPath @"..\..\definitionPool.ms")
  testDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

  /* GetGetterName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetGetterName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetModelName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModelName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetObservableName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetObservableName())
  expected = ::TestValueStruct #StateChanged
  assert (actual.Equals expected == true)

  /* GetPropertyName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetSetterName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetSetterName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* SetGetterName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetGetterName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedGetterName = #GetProperty
  actual = ::TestValueStruct (testObj.SetGetterName #GetProperty)
  expected = ::TestValueStruct expectedGetterName
  assert (actual.Equals expected == true)
  -- 成功（未定義に設定）
  expectedGetterName = undefined
  actual = ::TestValueStruct (testObj.SetGetterName undefined)
  expected = ::TestValueStruct expectedGetterName
  assert (actual.Equals expected == true)

  /* SetModelName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetModelName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedModelName = #Model
  actual = ::TestValueStruct (testObj.SetModelName #Model)
  expected = ::TestValueStruct expectedModelName
  assert (actual.Equals expected == true)
  -- 成功（未定義に設定）
  expectedModelName = undefined
  actual = ::TestValueStruct (testObj.SetModelName undefined)
  expected = ::TestValueStruct expectedModelName
  assert (actual.Equals expected == true)

  /* SetObservableName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetObservableName 0)
  expected = ::TestValueStruct #StateChanged
  assert (actual.Equals expected == true)
  -- 無効な値（未定義）
  actual = ::TestValueStruct (testObj.SetObservableName undefined)
  expected = ::TestValueStruct #StateChanged
  assert (actual.Equals expected == true)
  -- 成功
  expectedObservableName = #PropertyChanged
  actual = ::TestValueStruct (testObj.SetObservableName #PropertyChanged)
  expected = ::TestValueStruct expectedObservableName
  assert (actual.Equals expected == true)

  /* SetPropertyName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetPropertyName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedPropertyName = #Property
  actual = ::TestValueStruct (testObj.SetPropertyName #Property)
  expected = ::TestValueStruct expectedPropertyName
  assert (actual.Equals expected == true)
  -- 成功（未定義に設定）
  expectedPropertyName = undefined
  actual = ::TestValueStruct (testObj.SetPropertyName undefined)
  expected = ::TestValueStruct expectedPropertyName
  assert (actual.Equals expected == true)

  /* SetSetterName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetSetterName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedSetterName = #SetProperty
  actual = ::TestValueStruct (testObj.SetSetterName #SetProperty)
  expected = ::TestValueStruct expectedSetterName
  assert (actual.Equals expected == true)
  -- 成功（未定義に設定）
  expectedSetterName = undefined
  actual = ::TestValueStruct (testObj.SetSetterName undefined)
  expected = ::TestValueStruct expectedSetterName
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef #FooStruct #Count #GetCount #SetCount
  -- モデル名を確認
  actual = ::TestValueStruct (testObj.GetModelName())
  expected = ::TestValueStruct #FooStruct
  assert (actual.Equals expected == true)
  -- モデルのプロパティ名を確認
  actual = ::TestValueStruct (testObj.GetPropertyName())
  expected = ::TestValueStruct #Count
  assert (actual.Equals expected == true)
  -- モデルのプロパティ値取得メソッド名を確認
  actual = ::TestValueStruct (testObj.GetGetterName())
  expected = ::TestValueStruct #GetCount
  assert (actual.Equals expected == true)
  -- モデルのプロパティ値設定メソッド名を確認
  actual = ::TestValueStruct (testObj.GetSetterName())
  expected = ::TestValueStruct #SetCount
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef #FooStruct #Count #GetCount #SetCount)
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
