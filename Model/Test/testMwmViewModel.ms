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
  local bindingDef = ::mwmDefinitionPool[@"Model\MwmBinding.ms"]
  local commandDef = ::mwmDefinitionPool[@"Model\MwmCommand.ms"]
  local conditionDef = ::mwmDefinitionPool[@"Model\MwmCondition.ms"]
  local converterDef = ::mwmDefinitionPool[@"Model\MwmConverter.ms"]
  local eventDef = ::mwmDefinitionPool[@"Model\MwmEvent.ms"]
  local modelAttributeDef = ::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"]
  local propertyDef = ::mwmDefinitionPool[@"Model\MwmProperty.ms"]

  local TestModelStruct
  struct TestModelStruct (
    private count = 0,
    private step = 1,

    /*
    public fn Decrement = (),
    public fn GetCount = (),
    public fn GetStep = (),
    public fn Increment = (),
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

  local RltTest
  rollout RltTest "RltTest" (
    editText Edt "Count"
    button Btn "Increment"
  )

  local expectedBindingTable = undefined
  local expectedCommandTable = undefined
  local expectedModelTable = undefined
  local expectedPropertyTable = undefined
  local expectedViewModelName = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#BindingTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedBindingTable
        assert (actual.Equals expected == true)
      )
      (#CommandTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedCommandTable
        assert (actual.Equals expected == true)
      )
      (#ModelTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedModelTable
        assert (actual.Equals expected == true)
      )
      (#PropertyTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedPropertyTable
        assert (actual.Equals expected == true)
      )
      (#ViewModelName): (
        actual = ::TestValueStruct (testObj.GetViewModelName())
        expected = ::TestValueStruct expectedViewModelName
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local testToSourceFunction
  fn testToSourceFunction input = (
    input as Integer
  )

  local testToTargetFunction
  fn testToTargetFunction input = (
    input as String
  )

  local testCanExecuteFunction
  fn testCanExecuteFunction params = (
    params[1].Value != 0
  )

  local testExecuteFunction
  fn testExecuteFunction model params event = (
    model.Increment params[1].Value
    ok
  )

  local config = ::std.ConfigStruct()
  local converter = converterDef testToTargetFunction testToSourceFunction
  local model = TestModelStruct()
  local modelAttribute = modelAttributeDef #TestModel
  local countAttribute = modelAttributeDef #TestModel #Count #GetCount #SetCount
  local stepAttribute = modelAttributeDef #TestModel #Step #GetStep #SetStep

  local countProperty = propertyDef #Count 0 countAttribute
  countProperty.SetModel model
  local stepProperty = propertyDef #Step 1 stepAttribute
  stepProperty.SetModel model

  local canExecuteCondition = conditionDef testCanExecuteFunction
  canExecuteCondition.AddProperty stepProperty
  local executeCondition = conditionDef()
  executeCondition.AddProperty stepProperty
  local incrementCommand = commandDef #Increment testExecuteFunction \
      modelAttribute executeCondition canExecuteCondition

  local countBinding = bindingDef 1 #Count RltTest.Edt #Entered #Text
  countBinding.SetConverter converter
  local incrementBinding = bindingDef 1 #Increment RltTest.Btn #Pressed

  local viewModel2 = undefined

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

  testDef = ::mwmDefinitionPool[@"Model\MwmViewModel.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

  /* GetBinding */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetBinding #Count #Edt)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetBindingSourceNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetBindingSourceNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetBindingTargetNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetBindingTargetNames #Count)
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetCommand */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCommand #Increment)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetCommandNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetCommandNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModel #TestModel)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetModelNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModelNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetProperty */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetProperty #Count)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetPropertyNames */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyNames())
  expected = ::TestValueStruct #()
  assert (actual.Equals expected == true)

  /* GetPropertyValue */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetPropertyValue #Count)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetViewModelName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetViewModelName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* HasBinding */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasBinding incrementBinding)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasBindingByName */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasBindingByName #Increment #Btn)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasCommand */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasCommand incrementCommand)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasCommand #Increment)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasModel */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasModel model)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasModel #TestModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasProperty */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasProperty countProperty)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasProperty #Count)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* Load */
  -- ビューモデル名が未定義なので失敗
  actual = ::TestValueStruct (testObj.Load config)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* Save */
  -- ビューモデル名が未定義なので失敗
  actual = ::TestValueStruct (testObj.Save config)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* AddCommand */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddCommand 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedCommandTable = Dictionary #Name #(#Increment, incrementCommand)
  actual = ::TestValueStruct (testObj.AddCommand incrementCommand)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- コマンドオブジェクトのモデルオブジェクトを確認
  actual = ::TestValueStruct (incrementCommand.GetModel())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetCommand */
  actual = ::TestValueStruct (testObj.GetCommand #Increment)
  expected = ::TestValueStruct incrementCommand
  assert (actual.Equals expected == true)

  /* GetCommandNames */
  actual = ::TestValueStruct (testObj.GetCommandNames())
  expected = ::TestValueStruct #(#Increment)
  assert (actual.Equals expected == true)

  /* HasCommand */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasCommand incrementCommand)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasCommand #Increment)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* AddModel */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddModel #TestModel 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedModelTable = Dictionary #Name #(#TestModel, model)
  actual = ::TestValueStruct (testObj.AddModel #TestModel model)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- コマンドオブジェクトのモデルオブジェクトを確認
  actual = ::TestValueStruct (incrementCommand.GetModel())
  expected = ::TestValueStruct model
  assert (actual.Equals expected == true)

  /* GetModel */
  actual = ::TestValueStruct (testObj.GetModel #TestModel)
  expected = ::TestValueStruct model
  assert (actual.Equals expected == true)

  /* GetModelNames */
  actual = ::TestValueStruct (testObj.GetModelNames())
  expected = ::TestValueStruct #(#TestModel)
  assert (actual.Equals expected == true)

  /* HasModel */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasModel model)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasModel #TestModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* AddProperty */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddProperty 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功（`count`プロパティオブジェクト）
  expectedPropertyTable = Dictionary #Name #(#Count, countProperty)
  actual = ::TestValueStruct (testObj.AddProperty countProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトのモデルオブジェクトを確認
  actual = ::TestValueStruct (countProperty.GetModel())
  expected = ::TestValueStruct model
  assert (actual.Equals expected == true)
  -- 成功（`step`プロパティオブジェクト）
  expectedPropertyTable = Dictionary #Name #(#Count, countProperty) #(#Step, stepProperty)
  actual = ::TestValueStruct (testObj.AddProperty stepProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトのモデルオブジェクトを確認
  actual = ::TestValueStruct (stepProperty.GetModel())
  expected = ::TestValueStruct model
  assert (actual.Equals expected == true)

  /* GetProperty */
  -- `count`プロパティオブジェクト
  actual = ::TestValueStruct (testObj.GetProperty #Count)
  expected = ::TestValueStruct countProperty
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクト
  actual = ::TestValueStruct (testObj.GetProperty #Step)
  expected = ::TestValueStruct stepProperty
  assert (actual.Equals expected == true)

  /* GetPropertyNames */
  actual = ::TestValueStruct (testObj.GetPropertyNames())
  expected = ::TestValueStruct #(#Count, #Step)
  assert (actual.Equals expected == true)

  /* GetPropertyValue */
  -- `count`プロパティオブジェクト
  actual = ::TestValueStruct (testObj.GetPropertyValue #Count)
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクト
  actual = ::TestValueStruct (testObj.GetPropertyValue #Step)
  expected = ::TestValueStruct 1
  assert (actual.Equals expected == true)

  /* HasProperty */
  -- `count`プロパティオブジェクト（オブジェクト）
  actual = ::TestValueStruct (testObj.HasProperty countProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクト（オブジェクト）
  actual = ::TestValueStruct (testObj.HasProperty stepProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクト（名前）
  actual = ::TestValueStruct (testObj.HasProperty #Count)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクト（名前）
  actual = ::TestValueStruct (testObj.HasProperty #Step)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* CanExecuteCommand */
  -- 無効な値
  actual = ::TestValueStruct (testObj.CanExecuteCommand 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.CanExecuteCommand #Increment)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を変更
  actual = ::TestValueStruct (stepProperty.SetPropertyValue 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.CanExecuteCommand #Increment)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* ExecuteCommand */
  -- `step`プロパティオブジェクトの状態を変更
  actual = ::TestValueStruct (stepProperty.SetPropertyValue 2)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- 無効な値
  actual = ::TestValueStruct (testObj.ExecuteCommand 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.ExecuteCommand #Increment)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)

  /* SetBinding */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetBinding 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクト（成功）
  expectedBindingTable = Dictionary #Name \
      #(#Count, Dictionary #Name #(#Edt, countBinding))
  actual = ::TestValueStruct (testObj.SetBinding countBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクトの状態を確認
  actual = ::TestValueStruct (countBinding.GetSource())
  expected = ::TestValueStruct countProperty
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (countProperty.StateChanged.HasSubscribed countBinding.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト（成功）
  expectedBindingTable = Dictionary #Name \
      #(#Count, Dictionary #Name #(#Edt, countBinding)) \
      #(#Increment, Dictionary #Name #(#Btn, incrementBinding))
  actual = ::TestValueStruct (testObj.SetBinding incrementBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクトの状態を確認
  actual = ::TestValueStruct (incrementBinding.GetSource())
  expected = ::TestValueStruct incrementCommand
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (incrementCommand.CanExecuteChanged.HasSubscribed incrementBinding.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (incrementCommand.StateChanged.HasSubscribed incrementBinding.SourceChanged)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetBinding */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.GetBinding #Count #Edt)
  expected = ::TestValueStruct countBinding
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.GetBinding #Increment #Btn)
  expected = ::TestValueStruct incrementBinding
  assert (actual.Equals expected == true)

  /* GetBindingSourceNames */
  actual = ::TestValueStruct (testObj.GetBindingSourceNames())
  expected = ::TestValueStruct #(#Count, #Increment)
  assert (actual.Equals expected == true)

  /* GetBindingTargetNames */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.GetBindingTargetNames #Count)
  expected = ::TestValueStruct #(#Edt)
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.GetBindingTargetNames #Increment)
  expected = ::TestValueStruct #(#Btn)
  assert (actual.Equals expected == true)

  /* HasBinding */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBinding countBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBinding incrementBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* HasBindingByName */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBindingByName #Count #Edt)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBindingByName #Increment #Btn)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* SetPropertyValue */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetPropertyValue 0 10)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 存在しないプロパティ
  actual = ::TestValueStruct (testObj.SetPropertyValue #Increment 10)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.SetPropertyValue #Count 10)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- バインディングの値を確認
  actual = ::TestValueStruct (countBinding.GetSourceValue())
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)

  /* SetViewModelName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetViewModelName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedViewModelName = #TestViewModel
  actual = ::TestValueStruct (testObj.SetViewModelName #TestViewModel)
  expected = ::TestValueStruct expectedViewModelName
  assert (actual.Equals expected == true)

  /* RaiseTargetChanged */
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- コントロールの状態を確認
  actual = ::TestValueStruct (RltTest.Edt.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Edt.Text)
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Btn.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 無効な値
  actual = ::TestValueStruct (testObj.RaiseTargetChanged 0)
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 10
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- コントロールの状態を確認
  actual = ::TestValueStruct (RltTest.Edt.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Edt.Text)
  expected = ::TestValueStruct "10"
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Btn.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- コントロールの状態を変更
  RltTest.Edt.Text = "0"
  -- 成功（プロパティ）
  actual = ::TestValueStruct (
    testObj.RaiseTargetChanged (eventDef RltTest.Edt #Entered "0")
  )
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 0
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- コントロールの状態を確認
  actual = ::TestValueStruct (RltTest.Edt.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Edt.Text)
  expected = ::TestValueStruct "0"
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Btn.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功（コマンド）
  actual = ::TestValueStruct (
    testObj.RaiseTargetChanged (eventDef RltTest.Btn #Pressed #())
  )
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (countProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクトの状態を確認
  actual = ::TestValueStruct (stepProperty.GetPropertyValue())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- モデルの状態を確認
  actual = ::TestValueStruct (model.GetCount())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (model.GetStep())
  expected = ::TestValueStruct 2
  assert (actual.Equals expected == true)
  -- コントロールの状態を確認
  actual = ::TestValueStruct (RltTest.Edt.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Edt.Text)
  expected = ::TestValueStruct "2"
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Btn.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* RefreshBinding */
  actual = ::TestValueStruct (testObj.RefreshBinding())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- コントロールの状態を確認
  actual = ::TestValueStruct (RltTest.Edt.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Edt.Text)
  expected = ::TestValueStruct "2"
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (RltTest.Btn.Enabled)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* ClearBinding */
  -- 無効な値（結果的に存在しないので真になる）
  actual = ::TestValueStruct (testObj.ClearBinding 0)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト（成功）
  expectedBindingTable = Dictionary #Name \
      #(
        #Count,
        Dictionary #Name #(#Edt, countBinding)
      )
  actual = ::TestValueStruct (testObj.ClearBinding incrementBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクトの状態を確認
  actual = ::TestValueStruct (incrementBinding.GetSource())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (incrementCommand.CanExecuteChanged.HasSubscribed incrementBinding.SourceChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (incrementCommand.StateChanged.HasSubscribed incrementBinding.SourceChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクト（成功）
  expectedBindingTable = Dictionary #Name
  actual = ::TestValueStruct (testObj.ClearBinding countBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクトの状態を確認
  actual = ::TestValueStruct (countBinding.GetSource())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクトの通知元の購読を確認
  actual = ::TestValueStruct (countProperty.StateChanged.HasSubscribed countBinding.SourceChanged)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasBinding */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBinding countBinding)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBinding incrementBinding)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasBindingByName */
  -- `count`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBindingByName #Count #Edt)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト
  actual = ::TestValueStruct (testObj.HasBindingByName #Increment #Btn)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* Save */
  -- 成功
  actual = ::TestValueStruct (testObj.Save config)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Load */
  -- 成功
  actual = ::TestValueStruct (testObj.Load config)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* 作成パラメータ */
  testObj = testDef #TestViewModel
  testObj.AddCommand incrementCommand
  testObj.AddModel #TestModel model
  testObj.AddProperty countProperty
  testObj.AddProperty stepProperty
  testObj.SetBinding countBinding
  testObj.SetBinding incrementBinding
  testObj.StateChanged.Subscribe testNotification
  -- コマンドオブジェクト確認
  actual = ::TestValueStruct (testObj.HasCommand incrementCommand)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- モデルオブジェクト確認
  actual = ::TestValueStruct (testObj.HasModel model)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`プロパティオブジェクト確認
  actual = ::TestValueStruct (testObj.HasProperty countProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `step`プロパティオブジェクト確認
  actual = ::TestValueStruct (testObj.HasProperty stepProperty)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `count`バインディングオブジェクト確認
  actual = ::TestValueStruct (testObj.HasBinding countBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- `increment`バインディングオブジェクト確認
  actual = ::TestValueStruct (testObj.HasBinding incrementBinding)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  viewModel2 = testDef #TestViewModel
  viewModel2.AddCommand incrementCommand
  viewModel2.AddModel #TestModel model
  viewModel2.AddProperty countProperty
  viewModel2.AddProperty stepProperty
  viewModel2.SetBinding countBinding
  viewModel2.SetBinding incrementBinding
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct viewModel2
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  destroyDialog RltTest
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
