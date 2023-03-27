enum OperationStatesEnum { run, ready }

final Map<OperationStatesEnum, String> _operationStatesMap = {
  OperationStatesEnum.run: 'BSH.Common.EnumType.OperationState.Run',
  OperationStatesEnum.ready: 'BSH.Common.EnumType.OperationState.Ready',
};

String operationState({required OperationStatesEnum state}) {
  return _operationStatesMap[state]!;
}
