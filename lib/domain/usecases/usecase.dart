abstract class UseCase<T,Params> {
  Future<T> start([Params param]);
}