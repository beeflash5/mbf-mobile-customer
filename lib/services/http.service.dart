// Shim selama migrasi: HttpService legacy = ApiService baru.
// Semua method (get/post/patch/delete/postWithFiles) di-inherit dari ApiService.
import 'package:fuodz/services/api_service.dart';

class HttpService extends ApiService {}
