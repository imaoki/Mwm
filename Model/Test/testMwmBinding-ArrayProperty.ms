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
  local converterDef = ::mwmDefinitionPool[@"Model\MwmConverter.ms"]
  local eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local TestModelStruct
  struct TestModelStruct (
    /*- @prop <Array[<Integer>]> */
    private items = #(),

    /*
    public fn AppendItem input = (),
    public fn GetItems = (),
    public fn HasItem input = (),
    public fn InsertItem input destination = (),
    public fn MoveItems indices destination = (),
    public fn RemoveItems indices = (),
    public fn SetItems input = (),
    */

    /*-
    @param input <Integer>
    @returns <Array[<Integer>]>
    */
    public fn AppendItem input = (
      if classOf input == Integer and findItem this.items input == 0 do (
        append this.items input
        this.StateChanged.Notify #Items this.items
      )
      this.GetItems()
    ),

    /*-
    @returns <Array[<Integer>]>
    */
    public fn GetItems = (
      this.items
    ),

    /*-
    @param input <Integer>
    @returns <BooleanClass>
    */
    public fn HasItem input = (
      findItem this.items input > 0
    ),

    /*-
    @param input <Integer>
    @param destination <Integer>
    @returns <Array[<Integer>]>
    */
    public fn InsertItem input destination = (
      if classOf input == Integer and classOf destination == Integer \
          and destination > 0 and findItem this.items input == 0 do (
        ::insertItem input this.items destination
        this.StateChanged.Notify #Items this.items
      )
      this.GetItems()
    ),

    /*-
    @param indices <Array[<Integer>]>
    @param destination <Integer>
    @returns <Array[<Integer>]>
    */
    public fn MoveItems indices destination = (
      local newIndices = ::std.ArrayUtility.MoveItems this.items indices destination
      if newIndices.Count > 0 do (
        this.StateChanged.Notify #Items this.items
      )
      newIndices
    ),

    /*-
    @param indices <Array[<Integer>]>
    @returns <Array[<Integer>]>
    */
    public fn RemoveItems indices = (
      if classOf indices == Array do (
        sort indices
        for i = indices.Count to 1 by -1 do (
          local index = indices[i]
          if 1 <= index and index <= this.items.Count do (
            deleteItem this.items index
          )
        )
        this.StateChanged.Notify #Items this.items
      )
      this.GetItems()
    ),

    /*-
    @param input <Array[<Integer>]>
    @returns <Array[<Integer>]>
    */
    public fn SetItems input = (
      if classOf input == Array do (
        this.items = input
        this.StateChanged.Notify #Items this.items
      )
      this.GetItems()
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
      with printAllElements true (
          format "%  items:%\n" indent this.items to:out
      )
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
          and isProperty obj #GetItems \
          and classOf obj.GetItems == MAXScriptFunction

      if isEqualProperties do (
        local ov = obj.GetItems()
        local tv = this.GetItems()
        isEqualProperties = classOf ov == Array and classOf tv == Array and ov.Count == tv.Count
        if isEqualProperties do (
          for i = 1 to tv.Count while isEqualProperties do (
            isEqualProperties = ov[i] == tv[i]
          )
        )
      )

      isEqualStructName and isEqualProperties
    ),

    /*- @prop <Struct:ObservableStruct> */
    public StateChanged,

    on Create do (
      this.StateChanged = ::std.ObservableStruct()
    )
  )

  local RltTest
  rollout RltTest "RltTest" (
    multiListBox Mlbx "Items"
  )

  local expectedConverter = undefined
  local expectedMode = 1
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
      (#Mode): (
        actual = ::TestValueStruct (testObj.GetMode())
        expected = ::TestValueStruct expectedMode
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

  local testToSourceFunction
  fn testToSourceFunction input = (
    for item in input collect item as Integer
  )

  local testToTargetFunction
  fn testToTargetFunction input = (
    for item in input collect item as String
  )

  local converter = converterDef testToTargetFunction testToSourceFunction
  local model = TestModelStruct()
  local itemsAttribute = modelAttributeDef #TestModel #Items #GetItems #SetItems
  local itemsProperty = propertyDef #Items #() itemsAttribute
  itemsProperty.SetModel model

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
  /* インスタンス作成 */
  testObj = testDef 2 #Items RltTest.Mlbx #Items
  testObj.SetConverter converter
  testObj.SetSource itemsProperty
  testObj.StateChanged.Subscribe testNotification

  /* GetConverter */
  actual = ::TestValueStruct (testObj.GetConverter())
  expected = ::TestValueStruct converter
  assert (actual.Equals expected == true)

  /* GetMode */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetMode())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)

  /* GetSource */
  actual = ::TestValueStruct (testObj.GetSource())
  expected = ::TestValueStruct itemsProperty
  assert (actual.Equals expected == true)

  /* GetSourceName */
  actual = ::TestValueStruct (testObj.GetSourceName())
  expected = ::TestValueStruct #Items
  assert (actual.Equals expected == true)

  /* GetSourceValue */
  actual = ::TestValueStruct (testObj.GetSourceValue())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetTarget */
  actual = ::TestValueStruct (testObj.GetTarget())
  expected = ::TestValueStruct RltTest.Mlbx
  assert (actual.Equals expected == true)

  /* GetTargetEnabled */
  actual = ::TestValueStruct (testObj.GetTargetEnabled())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetTargetEventName */
  actual = ::TestValueStruct (testObj.GetTargetEventName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetTargetName */
  actual = ::TestValueStruct (testObj.GetTargetName())
  expected = ::TestValueStruct #Mlbx
  assert (actual.Equals expected == true)

  /* GetTargetPropertyName */
  actual = ::TestValueStruct (testObj.GetTargetPropertyName())
  expected = ::TestValueStruct #Items
  assert (actual.Equals expected == true)

  /* GetTargetPropertyValue */
  actual = ::TestValueStruct (testObj.GetTargetPropertyValue())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* ソースを変更 */
  -- セット
  expectedTargetPropertyValue = #(1, 2, 3)
  actual = ::TestValueStruct (model.SetItems #(1, 2, 3))
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetItems())
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Mlbx.Items
  expected = ::TestValueStruct #("1", "2", "3")
  assert (actual.Equals expected == true)
  -- 追加
  expectedTargetPropertyValue = #(1, 2, 3, 5)
  actual = ::TestValueStruct (model.AppendItem 5)
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetItems())
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Mlbx.Items
  expected = ::TestValueStruct #("1", "2", "3", "5")
  assert (actual.Equals expected == true)
  -- 挿入
  expectedTargetPropertyValue = #(1, 2, 3, 4, 5)
  actual = ::TestValueStruct (model.InsertItem 4 4)
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetItems())
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Mlbx.Items
  expected = ::TestValueStruct #("1", "2", "3", "4", "5")
  assert (actual.Equals expected == true)
  -- 移動
  expectedTargetPropertyValue = #(1, 3, 5, 2, 4)
  actual = ::TestValueStruct (model.MoveItems #(3, 5) 2)
  expected = ::TestValueStruct #(2, 3)
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetItems())
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Mlbx.Items
  expected = ::TestValueStruct #("1", "3", "5", "2", "4")
  assert (actual.Equals expected == true)
  -- 削除
  expectedTargetPropertyValue = #(1, 2, 4)
  actual = ::TestValueStruct (model.RemoveItems #(2, 3))
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetItems())
  expected = ::TestValueStruct expectedTargetPropertyValue
  assert (actual.Equals expected == true)
  -- ターゲットの状態を確認
  actual = ::TestValueStruct RltTest.Mlbx.Items
  expected = ::TestValueStruct #("1", "2", "4")
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  destroyDialog RltTest
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
