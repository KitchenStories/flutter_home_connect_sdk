enum OperationStatesEnum { run, ready, inactive }

final Map<OperationStatesEnum, String> _operationStatesMap = {
  OperationStatesEnum.run: 'BSH.Common.EnumType.OperationState.Run',
  OperationStatesEnum.ready: 'BSH.Common.EnumType.OperationState.Ready',
  OperationStatesEnum.inactive: 'BSH.Common.EnumType.OperationState.Inactive',
};

String operationState({required OperationStatesEnum state}) {
  return _operationStatesMap[state]!;
}
