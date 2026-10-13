class Review {
  final String id;
  final String workerId;
  final String userName;
  final int rating;
  final String text;
  final int? actualPrice;
  final bool? wasPriceWithinEstimate;
  final bool? arrivedOnTime;
  final bool? wouldRecommend;
  final String createdAtLabel;

  const Review({
    required this.id,
    required this.workerId,
    required this.userName,
    required this.rating,
    required this.text,
    this.actualPrice,
    this.wasPriceWithinEstimate,
    this.arrivedOnTime,
    this.wouldRecommend,
    required this.createdAtLabel,
  });
}
