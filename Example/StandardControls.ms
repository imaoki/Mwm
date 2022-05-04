/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  local ModelStruct
  struct ModelStruct (
    /*- @prop <BooleanClass> */
    private booleanValue = false,
    /*- @prop <Color> */
    private colorValue = Color 0 0 0,
    /*- @prop <Integer> */
    private indexValue = 0,
    /*- @prop <BitArray> */
    private indicesValue = #{},
    /*- @prop <Integer> */
    private integerValue = 0,
    /*- @prop <TextureMap> */
    private mapValue,
    /*- @prop <Material> */
    private materialValue,
    /*- @prop <Node> */
    private nodeValue,
    /*- @prop <String> */
    private stringValue = "",

    /*-
    @returns <BooleanClass>
    */
    public fn GetBooleanValue = (
      this.booleanValue
    ),

    /*-
    @returns <Color>
    */
    public fn GetColorValue = (
      this.colorValue
    ),

    /*-
    @returns <Integer>
    */
    public fn GetIndexValue = (
      this.indexValue
    ),

    /*-
    @returns <BitArray>
    */
    public fn GetIndicesValue = (
      this.indicesValue
    ),

    /*-
    @returns <Integer>
    */
    public fn GetIntegerValue = (
      this.integerValue
    ),

    /*-
    @returns <TextureMap>
    */
    public fn GetMapValue = (
      this.mapValue
    ),

    /*-
    @returns <Material>
    */
    public fn GetMaterialValue = (
      this.materialValue
    ),

    /*-
    @returns <Node>
    */
    public fn GetNodeValue = (
      this.nodeValue
    ),

    /*-
    @returns <String>
    */
    public fn GetStringValue = (
      this.stringValue
    ),


    /*-
    @param input <BooleanClass>
    @returns <BooleanClass>
    */
    public fn SetBooleanValue input = (
      this.booleanValue = input
      this.notify #BooleanValue this.booleanValue
      this.GetBooleanValue()
    ),

    /*-
    @param input <Color>
    @returns <Color>
    */
    public fn SetColorValue input = (
      this.colorValue = input
      this.notify #ColorValue this.colorValue
      this.GetColorValue()
    ),

    /*-
    @param input <Integer>
    @returns <Integer>
    */
    public fn SetIndexValue input = (
      this.indexValue = input
      this.notify #IndexValue this.indexValue
      this.GetIndexValue()
    ),

    /*-
    @param input <BitArray>
    @returns <BitArray>
    */
    public fn SetIndicesValue input = (
      this.indicesValue = input
      this.notify #IndicesValue this.indicesValue
      this.GetIndicesValue()
    ),

    /*-
    @param input <Integer>
    @returns <Integer>
    */
    public fn SetIntegerValue input = (
      this.integerValue = input
      this.notify #IntegerValue this.integerValue
      this.GetIntegerValue()
    ),

    /*-
    @param input <TextureMap>
    @returns <TextureMap>
    */
    public fn SetMapValue input = (
      this.mapValue = input
      this.notify #MapValue this.mapValue
      this.GetMapValue()
    ),

    /*-
    @param input <Material>
    @returns <Material>
    */
    public fn SetMaterialValue input = (
      this.materialValue = input
      this.notify #MaterialValue this.materialValue
      this.GetMaterialValue()
    ),

    /*-
    @param input <Node>
    @returns <Node>
    */
    public fn SetNodeValue input = (
      this.nodeValue = input
      this.notify #NodeValue this.nodeValue
      this.GetNodeValue()
    ),

    /*-
    @param input <String>
    @returns <String>
    */
    public fn SetStringValue input = (
      this.stringValue = input
      this.notify #StringValue this.stringValue
      this.GetStringValue()
    ),

    /*- @returns <Name> */
    public fn StructName = #ModelStruct,

    /*-
    @param indent: <String>
    @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
    @returns <OkClass>
    */
    public fn Dump indent:"" out:listener = (
      format "%ModelStruct\n" indent to:out
      format "%  booleanValue:%\n" indent this.booleanValue to:out
      format "%  colorValue:%\n" indent this.colorValue to:out
      format "%  indexValue:%\n" indent this.indexValue to:out
      format "%  indicesValue:%\n" indent this.indicesValue to:out
      format "%  integerValue:%\n" indent this.integerValue to:out
      format "%  mapValue:%\n" indent this.mapValue to:out
      format "%  materialValue:%\n" indent this.materialValue to:out
      format "%  nodeValue:%\n" indent this.nodeValue to:out
      format "%  stringValue:\"%\"\n" indent this.stringValue to:out
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

    /*- @prop <Struct:ObservableStruct> */
    public StateChanged,

    on Create do (
      this.StateChanged = (::standardDefinitionPool[@"Observable.ms"])()
    )
  )

  local currentFile = getSourceFileName()
  local pathUtility = ::std.PathUtilityStruct currentFile

  fileIn (pathUtility.GetFullPath @"..\Control\MvcCheckButton.ms")
  fileIn (pathUtility.GetFullPath @"..\Control\MvcRollout.ms")

  local rolloutMain = ::MvcRolloutStruct ControlName:"RltMain" Title:"Minimum"
  ok
)
-- (
--   -- clearListener()

--   local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
--   local sw = DotNetObject "System.Diagnostics.Stopwatch"

--   local currentFile = getSourceFileName()
--   local pathUtility = ::std.PathUtilityStruct currentFile

--   local actual
--   local expected
--   local testDef
--   local testObj

--   format "[run %]@\"%\"\n" nowTime currentFile
--   /* Setup Start ------------------------------------------------------------ */
--   testDef = fileIn (pathUtility.GetFullPath @"..\Hoge.ms")
--   /* Setup End -------------------------------------------------------------- */
--   sw.Start()
--   /* Test Start ------------------------------------------------------------- */
--   /* カテゴリ */
--   -- テスト項目
--   -- testObj = testDef 0
--   -- actual = ::TestValueStruct (testObj.IsInteger())
--   -- expected = ::TestValueStruct true
--   -- assert (actual.Equals expected == true)
--   /* Test End --------------------------------------------------------------- */
--   sw.Stop()
--   /* Teardown Start --------------------------------------------------------- */
--   /* Teardown End ----------------------------------------------------------- */
--   format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
--   ok
-- )
