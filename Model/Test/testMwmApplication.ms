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
  local viewModelDef = ::mwmDefinitionPool[@"Model\MwmViewModel.ms"]

  local TestModelStruct
  struct TestModelStruct (
    private count = 0,

    /*
    public fn GetCount = (),
    public fn Load config = (),
    public fn Save config = (),
    public fn SetCount input = (),

    private fn isValidConfig obj = (),
    */

    /*-
    @returns <Integer>
    */
    public fn GetCount = (
      this.count
    ),

    /*-
    @param config <Struct:ConfigStruct>
    @returns <BooleanClass>
    */
    public fn Load config = (
      local isSuccessful = false
      if this.isValidConfig config do (
        local table = config.GetValue #TestModel
        if classOf table == Dictionary do (
          if hasDictValue table #Count do this.SetCount table[#Count]
          isSuccessful = true
        )
      )
      isSuccessful
    ),

    /*-
    @param config <Struct:ConfigStruct>
    @returns <BooleanClass>
    */
    public fn Save config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = Dictionary #Name
      table[#Count] = this.GetCount()
      config.AddValue #TestModel table
      isSuccessful = true
    )
    isSuccessful
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
    @param obj <Any>
    @returns <BooleanClass>
    */
    private fn isValidConfig obj = (
      isStruct obj \
          and isProperty obj #StructName \
          and classOf obj.StructName == MAXScriptFunction \
          and obj.StructName() == #ConfigStruct
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

  local MnuTest
  rcMenu MnuTest (
    local DataContext = #TestViewModel

    fn IsValidViewModel obj = (
      isStruct obj \
          and isProperty obj #StructName \
          and classOf obj.StructName == MAXScriptFunction \
          and obj.StructName() == #MwmViewModelStruct
    )

    fn Initialize obj = (
      if IsValidViewModel obj do (
        DataContext = obj
      )
      ok
    )
  )

  local RltTest
  rollout RltTest "RltTest" (
    local DataContext = #TestViewModel

    editText Edt "Count"

    fn IsValidViewModel obj = (
      isStruct obj \
          and isProperty obj #StructName \
          and classOf obj.StructName == MAXScriptFunction \
          and obj.StructName() == #MwmViewModelStruct
    )

    fn Initialize obj = (
      if IsValidViewModel obj do (
        DataContext = obj
      )
      ok
    )
  )

  local expectedApplicationFile = undefined
  local expectedApplicationName = undefined
  local expectedConfig = undefined
  local expectedIsDisplayed = false
  local expectedModelTable = undefined
  local expectedStartupViewName = undefined
  local expectedViewModelTable = undefined
  local expectedViewTable = undefined

  local testNotification
  fn testNotification type param = (
    -- format "testNotification type:% param:%\n" type param
    case type of (
      (#ApplicationFile): (
        actual = ::TestValueStruct (testObj.GetApplicationFile())
        expected = ::TestValueStruct expectedApplicationFile
        assert (actual.Equals expected == true)
      )
      (#ApplicationName): (
        actual = ::TestValueStruct (testObj.GetApplicationName())
        expected = ::TestValueStruct expectedApplicationName
        assert (actual.Equals expected == true)
      )
      (#ApplicationRan): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedIsDisplayed
        assert (actual.Equals expected == true)
      )
      (#ApplicationShutdown): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedIsDisplayed
        assert (actual.Equals expected == true)
      )
      (#ConfigRead): (
        actual = ::TestValueStruct (testObj.GetConfig())
        expected = ::TestValueStruct expectedConfig
        assert (actual.Equals expected == true)
      )
      (#ConfigWrote): (
        actual = ::TestValueStruct (testObj.GetConfig())
        expected = ::TestValueStruct expectedConfig
        assert (actual.Equals expected == true)
      )
      (#ModelTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedModelTable
        assert (actual.Equals expected == true)
      )
      (#StartupViewName): (
        actual = ::TestValueStruct (testObj.GetStartupViewName())
        expected = ::TestValueStruct expectedStartupViewName
        assert (actual.Equals expected == true)
      )
      (#ViewModelTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedViewModelTable
        assert (actual.Equals expected == true)
      )
      (#ViewTable): (
        actual = ::TestValueStruct param
        expected = ::TestValueStruct expectedViewTable
        assert (actual.Equals expected == true)
      )
      default: ()
    )
    ok
  )

  local application2 = undefined
  local model = TestModelStruct()
  local view = ::std.DialogStruct RltTest
  view.SetMenuDef MnuTest
  local viewModel = viewModelDef #TestViewModel

  local testConfigFile = pathUtility.ChangeExtension currentFile ".mxsconfig"
  local testViewConfigTable = Dictionary #Name
  testViewConfigTable[#InitPosition] = undefined
  testViewConfigTable[#InitSize] = [160, 160]
  testViewConfigTable[#LockHeight] = false
  testViewConfigTable[#LockWidth] = false
  testViewConfigTable[#Modal] = false
  testViewConfigTable[#StyleBorder] = false
  testViewConfigTable[#StyleMaximizeBox] = false
  testViewConfigTable[#StyleMinimizeBox] = false
  testViewConfigTable[#StyleResizing] = false
  testViewConfigTable[#StyleSunkenedge] = false
  testViewConfigTable[#StyleSysmenu] = true
  testViewConfigTable[#StyleTitleBar] = false
  testViewConfigTable[#StyleToolWindow] = true

  testDef = ::mwmDefinitionPool[@"Model\MwmApplication.ms"]
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()
  testObj.StateChanged.Subscribe testNotification

  /* GetApplicationFile */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetApplicationFile())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetApplicationName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetApplicationName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetConfig */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetConfig())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetModel #TestModel)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetStartupViewName */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetStartupViewName())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetView */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetView #RltTest)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* GetViewModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.GetViewModel #TestViewModel)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* HasModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasModel #TestModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasView */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasView #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* HasViewModel */
  -- 既定値
  actual = ::TestValueStruct (testObj.HasViewModel #TestViewModel)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* WriteConfig */
  -- アプリケーションファイル未指定なので失敗する
  actual = ::TestValueStruct (testObj.WriteConfig())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* ReadConfig */
  -- アプリケーションファイル未指定なので失敗する
  actual = ::TestValueStruct (testObj.ReadConfig())
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* SetApplicationFile */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetApplicationFile 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedApplicationFile = currentFile
  actual = ::TestValueStruct (testObj.SetApplicationFile currentFile)
  expected = ::TestValueStruct expectedApplicationFile
  assert (actual.Equals expected == true)
  -- アプリケーションファイルを確認
  actual = ::TestValueStruct (testObj.GetApplicationFile())
  expected = ::TestValueStruct expectedApplicationFile
  assert (actual.Equals expected == true)
  -- 設定オブジェクトを確認
  actual = ::TestValueStruct (testObj.GetConfig())
  expected = ::TestValueStruct (::std.ConfigStruct currentFile)
  assert (actual.Equals expected == true)
  -- 設定ファイルのパスを確認
  actual = ::TestValueStruct ((testObj.GetConfig()).GetFilePath())
  expected = ::TestValueStruct testConfigFile
  assert (actual.Equals expected == true)

  /* SetApplicationName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetApplicationName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedApplicationName = #TestApplication
  actual = ::TestValueStruct (testObj.SetApplicationName #TestApplication)
  expected = ::TestValueStruct expectedApplicationName
  assert (actual.Equals expected == true)

  /* SetStartupViewName */
  -- 無効な値
  actual = ::TestValueStruct (testObj.SetStartupViewName 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  expectedStartupViewName = #RltTest
  actual = ::TestValueStruct (testObj.SetStartupViewName #RltTest)
  expected = ::TestValueStruct expectedStartupViewName
  assert (actual.Equals expected == true)

  /* AddModel */
  -- 無効な値（モデル名）
  actual = ::TestValueStruct (testObj.AddModel 0 model)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 無効な値（モデルオブジェクト）
  actual = ::TestValueStruct (testObj.AddModel #TestModel 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedModelTable = Dictionary #Name #(#TestModel, model)
  actual = ::TestValueStruct (testObj.AddModel #TestModel model)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetModel */
  actual = ::TestValueStruct (testObj.GetModel #TestModel)
  expected = ::TestValueStruct model
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

  /* AddView */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddView 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedViewTable = Dictionary #Name #(#RltTest, view)
  actual = ::TestValueStruct (testObj.AddView view)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ビューモデルの状態を確認
  actual = ::TestValueStruct (viewModel.HasModel #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutClose)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutMoved)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutOpen)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutResized)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutClose #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutMoved #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutOpen #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutResized #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- メニューイベントを確認
  actual = ::TestValueStruct (viewModel.HasCommand #MenuOpen)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #MenuOpen #RltTest)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* GetView */
  actual = ::TestValueStruct (testObj.GetView #RltTest)
  expected = ::TestValueStruct view
  assert (actual.Equals expected == true)

  /* HasView */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasView view)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasView #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* AddViewModel */
  -- 無効な値
  actual = ::TestValueStruct (testObj.AddViewModel 0)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- 成功
  expectedViewModelTable = Dictionary #Name #(#TestViewModel, viewModel)
  actual = ::TestValueStruct (testObj.AddViewModel viewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ビューモデルの状態を確認
  actual = ::TestValueStruct (viewModel.HasModel #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutClose)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutMoved)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutOpen)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasCommand #RolloutResized)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutClose #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutMoved #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutOpen #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #RolloutResized #RltTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- メニューイベントを確認
  actual = ::TestValueStruct (viewModel.HasCommand #MenuOpen)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (viewModel.HasBindingByName #MenuOpen #MnuTest)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* GetViewModel */
  actual = ::TestValueStruct (testObj.GetViewModel #TestViewModel)
  expected = ::TestValueStruct viewModel
  assert (actual.Equals expected == true)

  /* HasViewModel */
  -- オブジェクト
  actual = ::TestValueStruct (testObj.HasViewModel viewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 名前
  actual = ::TestValueStruct (testObj.HasViewModel #TestViewModel)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* WriteConfig */
  -- 成功
  expectedConfig = ::std.ConfigStruct currentFile
  expectedConfig.AddValue #TestModel (Dictionary #Name #(#Count, 0))
  expectedConfig.AddValue #'RltTest.Dialog' testViewConfigTable
  actual = ::TestValueStruct (testObj.WriteConfig())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイルの存在を確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists testConfigFile)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイルの評価結果を確認
  actual = ::TestValueStruct (fileIn testConfigFile)
  expected = ::TestValueStruct (
    Dictionary #Name \
        #(
          #TestModel,
          Dictionary #Name #(#Count, 0)
        ) \
        #(
          #'RltTest.Dialog',
          Dictionary #Name \
            #(#InitPosition, undefined) \
            #(#InitSize, [160, 160]) \
            #(#LockHeight, false) \
            #(#LockWidth, false) \
            #(#Modal, false) \
            #(#StyleBorder, false) \
            #(#StyleMaximizeBox, false) \
            #(#StyleMinimizeBox, false) \
            #(#StyleResizing, false) \
            #(#StyleSunkenedge, false) \
            #(#StyleSysmenu, true) \
            #(#StyleTitleBar, false) \
            #(#StyleToolWindow, true)
        )
  )
  assert (actual.Equals expected == true)

  /* ReadConfig */
  -- アプリケーションファイルと設定オブジェクトを未定義化
  expectedApplicationFile = undefined
  actual = ::TestValueStruct (testObj.SetApplicationFile undefined)
  expected = ::TestValueStruct expectedApplicationFile
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.GetConfig())
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- アプリケーションファイルと設定オブジェクトを再設定
  expectedApplicationFile = currentFile
  actual = ::TestValueStruct (testObj.SetApplicationFile currentFile)
  expected = ::TestValueStruct expectedApplicationFile
  assert (actual.Equals expected == true)
  actual = ::TestValueStruct (testObj.GetConfig())
  expected = ::TestValueStruct (::std.ConfigStruct currentFile)
  assert (actual.Equals expected == true)
  -- 成功
  expectedConfig = ::std.ConfigStruct currentFile
  expectedConfig.AddValue #TestModel (Dictionary #Name #(#Count, 0))
  expectedConfig.AddValue #'RltTest.Dialog' testViewConfigTable
  actual = ::TestValueStruct (testObj.ReadConfig())
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* Run */
  -- 成功
  expectedIsDisplayed = true
  actual = ::TestValueStruct (testObj.Run())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ビューが標示されているかどうかを確認
  actual = ::TestValueStruct (view.IsDisplayed())
  expected = ::TestValueStruct expectedIsDisplayed
  assert (actual.Equals expected == true)
  -- ロールアウト定義の`DataContext`変数を確認
  actual = ::TestValueStruct (view.GetRolloutDef()).DataContext
  expected = ::TestValueStruct viewModel
  assert (actual.Equals expected == true)

  /* Shutdown */
  -- 成功
  expectedIsDisplayed = false
  actual = ::TestValueStruct (testObj.Shutdown())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ビューが標示されているかどうかを確認
  actual = ::TestValueStruct (view.IsDisplayed())
  expected = ::TestValueStruct expectedIsDisplayed
  assert (actual.Equals expected == true)

  /* Run */
  -- 成功（再度開始）
  expectedIsDisplayed = true
  actual = ::TestValueStruct (testObj.Run())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ビューが標示されているかどうかを確認
  actual = ::TestValueStruct (view.IsDisplayed())
  expected = ::TestValueStruct expectedIsDisplayed
  assert (actual.Equals expected == true)
  -- ロールアウト定義の`DataContext`変数を確認
  actual = ::TestValueStruct (view.GetRolloutDef()).DataContext
  expected = ::TestValueStruct viewModel
  assert (actual.Equals expected == true)

  /* Shutdown */
  -- 成功（再度終了）
  expectedIsDisplayed = false
  actual = ::TestValueStruct (testObj.Shutdown())
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ビューが標示されているかどうかを確認
  actual = ::TestValueStruct (view.IsDisplayed())
  expected = ::TestValueStruct expectedIsDisplayed
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* 作成パラメータ */
  testObj = testDef #TestApplication #RltTest currentFile
  testObj.StateChanged.Subscribe testNotification

  /* GetApplicationFile */
  actual = ::TestValueStruct (testObj.GetApplicationFile())
  expected = ::TestValueStruct currentFile
  assert (actual.Equals expected == true)

  /* GetApplicationName */
  actual = ::TestValueStruct (testObj.GetApplicationName())
  expected = ::TestValueStruct #TestApplication
  assert (actual.Equals expected == true)

  /* GetConfig */
  actual = ::TestValueStruct (testObj.GetConfig())
  expected = ::TestValueStruct (::std.ConfigStruct currentFile)
  assert (actual.Equals expected == true)

  /* GetStartupViewName */
  actual = ::TestValueStruct (testObj.GetStartupViewName())
  expected = ::TestValueStruct #RltTest
  assert (actual.Equals expected == true)

  /* Equals */
  -- 等しくない
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef())
  assert (actual.Equals expected == false)
  -- 等しい
  -- application2 = testDe
  actual = ::TestValueStruct testObj
  expected = ::TestValueStruct (testDef #TestApplication #RltTest currentFile)
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  if ::std.FileUtility.FileExists testConfigFile do (
    ::std.FileUtility.DeleteFile testConfigFile
  )
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
