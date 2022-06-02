/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Examples of basic array operations.
*/
/* Define Model */
struct BasicArrayOpStruct (
  /*- @prop <Array[<Integer>]> */
  private items = #(),
  /*- @prop <Array[<Integer>]> */
  private itemSelection = #(),

  /*
  public fn AppendItem input = (),
  public fn GetItems = (),
  public fn GetItemSelection = (),
  public fn InsertItem input destination = (),
  public fn MoveItems indices destination = (),
  public fn RemoveItems indices = (),
  public fn SetItems input = (),
  public fn SetItemSelection input = (),
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
  @returns <Array[<Integer>]>
  */
  public fn GetItemSelection = (
    this.itemSelection
  ),

  /*-
  @param input <Integer>
  @param destination <Integer>
  @returns <Array[<Integer>]>
  */
  public fn InsertItem input destination = (
    if classOf input == Integer and findItem this.items input == 0 \
        and classOf destination == Integer and destination > 0 do (
      ::insertItem input this.items destination
      this.StateChanged.Notify #Items this.items
      for i = destination + 1 to this.itemSelection.Count do (
        this.itemSelection[i] += 1
      )
      this.StateChanged.Notify #ItemSelection this.itemSelection
    )
    this.GetItems()
  ),

  /*-
  @param indices <Array[<Integer>]>
  @param destination <Integer>
  @returns <Array[<Integer>]>
  */
  public fn MoveItems indices destination = (
    local movedIndices = ::std.ArrayUtility.MoveItems this.items indices destination
    local movedCount = movedIndices.Count
    if movedCount > 0 do (
      this.StateChanged.Notify #Items this.items
      local movedSelection = #()
      for i = 1 to indices.Count do (
        if i <= movedCount do (
          local oldIndex = indices[i]
          local newIndex = movedIndices[i]
          local selectedIndex = findItem this.itemSelection oldIndex
          if selectedIndex > 0 do (
            this.itemSelection[selectedIndex] = newIndex
            append movedSelection selectedIndex
          )
        )
      )
      if movedSelection.Count > 0 do (
        sort this.itemSelection
        this.StateChanged.Notify #ItemSelection this.itemSelection
      )
    )
    this.GetItems()
  ),

  /*-
  @param indices <Array[<Integer>]>
  @returns <Array[<Integer>]>
  */
  public fn RemoveItems indices = (
    if classOf indices == Array do (
      sort indices
      local removedIndices = #()
      local removedSelection = #()
      for i = indices.Count to 1 by -1 do (
        local index = indices[i]
        if classOf index == Integer and 1 <= index and index <= this.items.Count do (
          deleteItem this.items index
          append removedIndices index
          local selectedIndex = findItem this.itemSelection index
          if selectedIndex > 0 do (
            deleteItem this.itemSelection selectedIndex
            append removedSelection selectedIndex
          )
        )
      )
      if removedIndices.Count > 0 do (
        this.StateChanged.Notify #Items this.items
      )
      if removedSelection.Count > 0 do (
        this.StateChanged.Notify #ItemSelection this.itemSelection
      )
    )
    this.GetItems()
  ),

  /*-
  @param input <Array[<Integer>]>
  @returns <Array[<Integer>]>
  */
  public fn SetItems input = (
    if classOf input == Array do (
      this.items = for i in input where classOf i == Integer collect i
      this.StateChanged.Notify #Items this.items
    )
    this.GetItems()
  ),

  /*-
  @param input <Array[<Integer>]>
  @returns <Array[<Integer>]>
  */
  public fn SetItemSelection input = (
    if classOf input == Array do (
      sort input
      this.itemSelection = for i in input where classOf i == Integer collect i
      this.StateChanged.Notify #ItemSelection this.itemSelection
    )
    this.GetItemSelection()
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
  )
)

/* Mwm's domain */
(
  /* Create Condition */
  local appendCondition = ::mwm.CreateCondition()
  local insertCondition = ::mwm.CreateCondition evaluator:(
    fn insertEvaluator params = (
      params[2].Name == #ItemSelection and params[2].Value.Count == 1
    )
  )
  local movePrevCondition = ::mwm.CreateCondition evaluator:(
    fn movePrevEvaluator params = (
      params[1].Name == #ItemSelection \
          and params[1].Value.Count > 0 and params[1].Value[1] > 1
    )
  )
  local moveNextCondition = ::mwm.CreateCondition evaluator:(
    fn moveNextEvaluator params = (
      params[1].Name == #Items and params[2].Name == #ItemSelection \
          and params[2].Value.Count > 0 \
          and params[2].Value[params[2].Value.Count] < params[1].Value.Count
    )
  )
  local removeCondition = ::mwm.CreateCondition evaluator:(
    fn removeEvaluator params = (
      params[1].Name == #ItemSelection and params[1].Value.Count > 0
    )
  )

  /* Create ViewModel Property */
  local numberProperty = ::mwm.CreateProperty #Number 0
  appendCondition.AddProperty numberProperty
  insertCondition.AddProperty numberProperty
  local itemsProperty = ::mwm.CreateProperty #Items #() \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #BasicArrayOp \
            propertyName:#Items \
            getterName:#GetItems \
            setterName:#SetItems
      )
  moveNextCondition.AddProperty itemsProperty
  local itemSelectionProperty = ::mwm.CreateProperty #ItemSelection #() \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #BasicArrayOp \
            propertyName:#ItemSelection \
            getterName:#GetItemSelection \
            setterName:#SetItemSelection
      )
  insertCondition.AddProperty itemSelectionProperty
  movePrevCondition.AddProperty itemSelectionProperty
  moveNextCondition.AddProperty itemSelectionProperty
  removeCondition.AddProperty itemSelectionProperty

  /* Create ViewModel Command */
  local commandAttribute = ::mwm.CreateModelAttribute #BasicArrayOp
  local appendCommand = ::mwm.CreateCommand #Append \
      executeFunction:(
        fn executeAppend model params event = (
          model.AppendItem params[1].Value
        )
      ) \
      modelAttribute:commandAttribute
  local insertCommand = ::mwm.CreateCommand #Insert \
      executeFunction:(
        fn executeInsert model params event = (
          model.InsertItem params[1].Value params[2].Value[1]
        )
      ) \
      modelAttribute:commandAttribute
  local movePrevCommand = ::mwm.CreateCommand #MovePrev \
      executeFunction:(
        fn executeMovePrev model params event = (
          local destination = params[1].Value[1] - 1
          model.MoveItems params[1].Value destination
        )
      ) \
      modelAttribute:commandAttribute
  local moveNextCommand = ::mwm.CreateCommand #MoveNext \
      executeFunction:(
        fn executeMoveNext model params event = (
          local destination = params[2].Value[params[2].Value.Count] + 2
          model.MoveItems params[2].Value destination
        )
      ) \
      modelAttribute:commandAttribute
  local removeCommand = ::mwm.CreateCommand #Remove \
      executeFunction:(
        fn executeRemove model params event = model.RemoveItems params[1].Value
      ) \
      modelAttribute:commandAttribute

  /* Set Condition */
  appendCommand.SetExecuteCondition appendCondition
  insertCommand.SetCanExecuteCondition insertCondition
  insertCommand.SetExecuteCondition insertCondition
  movePrevCommand.SetCanExecuteCondition movePrevCondition
  movePrevCommand.SetExecuteCondition movePrevCondition
  moveNextCommand.SetCanExecuteCondition moveNextCondition
  moveNextCommand.SetExecuteCondition moveNextCondition
  removeCommand.SetCanExecuteCondition removeCondition
  removeCommand.SetExecuteCondition removeCondition

  /* Define View */
  rollout RltMain "BasicArrayOperations" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #BasicArrayOpViewModel

    multiListBox MlbxItems "Items" height:10
    spinner SpnNumber "Number:" range:[0, 100, 0] scale:1 type:#Integer
    button BtnAppend "Append" across:2
    button BtnInsert "Insert"
    button BtnMovePrev "MovePrev" across:2
    button BtnMoveNext "MoveNext"
    button BtnRemove "Remove"

    /*-
    @param control <RolloutClass|RolloutControl|RCMenu|MenuItem>
    @param eventName <Name>
    @param params <Array[<Any>]|Any>
    @returns <OkClass>
    */
    fn EventNotify control eventName params = (
      if ::mwm.IsValidViewModel DataContext do (
        DataContext.RaiseTargetChanged (
          ::mwm.CreateEvent control eventName params
        )
      )
      ok
    )

    /*-
    @param obj <Struct:MwmViewModelStruct>
    @returns <OkClass>
    */
    fn Initialize obj = (
      if ::mwm.IsValidViewModel obj do (
        DataContext = obj

        /* Data Binding */
        local itemsBinding = ::mwm.CreatePropertyBinding 2 #Items MlbxItems #Items undefined
        itemsBinding.SetConverter (
          ::mwm.CreateConverter \
              (fn integerArrayToStringArray input = for i in input collect i as String) \
              (fn stringArrayToIntegerArray input = for i in input collect i as Integer)
        )
        local itemSelectionBinding = ::mwm.CreatePropertyBinding 1 #ItemSelection MlbxItems #Selection #SelectionEnd
        itemSelectionBinding.SetConverter (
          ::mwm.CreateConverter \
              (fn integerArrayAsBitArray input = input as BitArray) \
              (fn bitArrayAsIntegerArray input = input as Array)
        )
        local numberBinding = ::mwm.CreatePropertyBinding 1 #Number SpnNumber #Value #Changed
        local appendBinding = ::mwm.CreateCommandBinding #Append BtnAppend #Pressed
        local insertBinding = ::mwm.CreateCommandBinding #Insert BtnInsert #Pressed
        local movePrevBinding = ::mwm.CreateCommandBinding #MovePrev BtnMovePrev #Pressed
        local moveNextBinding = ::mwm.CreateCommandBinding #MoveNext BtnMoveNext #Pressed
        local removeBinding = ::mwm.CreateCommandBinding #Remove BtnRemove #Pressed
        DataContext.SetBinding itemsBinding
        DataContext.SetBinding itemSelectionBinding
        DataContext.SetBinding numberBinding
        DataContext.SetBinding appendBinding
        DataContext.SetBinding insertBinding
        DataContext.SetBinding movePrevBinding
        DataContext.SetBinding moveNextBinding
        DataContext.SetBinding removeBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on MlbxItems SelectionEnd do EventNotify MlbxItems #SelectionEnd #()
    on SpnNumber Changed v do EventNotify SpnNumber #Changed #(v)
    on BtnAppend Pressed do EventNotify BtnAppend #Pressed #()
    on BtnInsert Pressed do EventNotify BtnInsert #Pressed #()
    on BtnMovePrev Pressed do EventNotify BtnMovePrev #Pressed #()
    on BtnMoveNext Pressed do EventNotify BtnMoveNext #Pressed #()
    on BtnRemove Pressed do EventNotify BtnRemove #Pressed #()
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 320]

  /* Create Model Instance */
  global basicArrayOpModel = ::BasicArrayOpStruct()

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #BasicArrayOpViewModel
  viewModel.AddModel #BasicArrayOp ::basicArrayOpModel
  viewModel.AddProperty numberProperty
  viewModel.AddProperty itemsProperty
  viewModel.AddProperty itemSelectionProperty
  viewModel.AddCommand appendCommand
  viewModel.AddCommand insertCommand
  viewModel.AddCommand movePrevCommand
  viewModel.AddCommand moveNextCommand
  viewModel.AddCommand removeCommand

  /* Build Application */
  global basicArrayOpApplication = ::mwm.CreateApplication \
      #BasicArrayOpApplication #RltMain
  ::basicArrayOpApplication.AddModel #BasicArrayOp ::basicArrayOpModel
  ::basicArrayOpApplication.AddView view
  ::basicArrayOpApplication.AddViewModel viewModel

  /* Running Application */
  ::basicArrayOpApplication.Run()

  /* Direct operation */
  /*
  ::basicArrayOpModel.GetItems()
  ::basicArrayOpModel.SetItems #(1, 2, 3, 4, 5)
  ::basicArrayOpModel.GetItemSelection()
  ::basicArrayOpModel.SetItemSelection #(2, 4)
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).GetPropertyValue #Number
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).SetPropertyValue #Number 3
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).GetPropertyValue #Items
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).SetPropertyValue #Items #(1, 2, 3)
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).GetPropertyValue #ItemSelection
  (::basicArrayOpApplication.GetViewModel #BasicArrayOpViewModel).SetPropertyValue #ItemSelection #(1, 3)
  */

  /* Shutdown Application */
  /*
  ::basicArrayOpApplication.Shutdown()
  */
  ok
)
