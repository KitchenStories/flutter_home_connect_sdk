enum OauthScope {
  identifyAppliance,
  oven,
  ovenMonitor,
  ovenControl,
  ovenSettings,
}

Map<OauthScope, String> scopeMap = {
  OauthScope.identifyAppliance: 'IdentifyAppliance',
  OauthScope.oven: 'Oven',
  OauthScope.ovenMonitor: 'Oven-Monitor',
  OauthScope.ovenControl: 'Oven-Control',
  OauthScope.ovenSettings: 'Oven-Settings',
};

List<String> scopesToStringList(Iterable<OauthScope> scopes) {
  return scopes.map((e) => scopeMap[e]!).toList();
}
