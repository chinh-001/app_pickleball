enum CallApiStatus { initial, loading, noInternet, success, failure }
 
extension CallApiStatusX on CallApiStatus {
  bool get isInit => this == CallApiStatus.initial;
 
  bool get isLoading => this == CallApiStatus.loading;
 
  bool get isSuccess => this == CallApiStatus.success;
 
  bool get isFailure => this == CallApiStatus.failure;
}