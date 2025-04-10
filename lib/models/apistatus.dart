enum StateStatus { initial, loading, success, failure }

class Apistatus {
  final StateStatus status;
  const Apistatus({this.status = StateStatus.initial});

  List<Object?> get props => [status];

  Apistatus copyWith({status}) => Apistatus(status: status ?? this.status);
}