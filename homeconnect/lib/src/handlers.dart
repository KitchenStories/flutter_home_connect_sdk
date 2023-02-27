String authToken = "your dev token here";

// dynamic sendOrder(HomeDevice device, Program program, String amount) async {
//   final dio = Dio();
//   Response? response;
//   dio.options.headers = {
//     "Authorization": "Bearer $authToken",
//     "Content-Type": "application/vnd.bsh.sdk.v1+json",
//   };

//   print(program.options.getConstrains()[0].key);
//   print(program.options.getConstrains()[1].key);

//   Map<String, dynamic> data = {
//     "data": {
//       "key": program.options.key,
//       "options": [
//         {
//           "key": program.options.getConstrains()[0].key,
//           "value": 30,
//           "unit": "°C"
//         },
//         {
//           "key": program.options.getConstrains()[1].key,
//           "value": 60,
//           'unit': 'seconds'
//         }
//       ]
//     }
//   };
//   try {
//     response = await dio.put(
//         "https://simulator.home-connect.com/api/homeappliances/${device.haId}/programs/active",
//         data: data);
//     return response;
//   } catch (e) {
//     if (e is DioError && e.response != null) {
//       print("Error: ${e.response!.data}");
//     } else {
//       print("Unkown error");
//       print(e);
//     }
//   }
// }
