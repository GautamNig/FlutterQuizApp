import 'dart:convert';

EventsCollection eventsCollectionFromJson(String str) => EventsCollection.fromJson(json.decode(str));

String eventsCollectionToJson(EventsCollection data) => json.encode(data.toJson());

class EventsCollection {
  EventsCollection({
    required this.slidingEvents,
  });

  List<SlidingEvent> slidingEvents;

  factory EventsCollection.fromJson(Map<String, dynamic> json) => EventsCollection(
    slidingEvents: List<SlidingEvent>.from(json["SlidingEvents"].map((x) => SlidingEvent.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "SlidingEvents": List<dynamic>.from(slidingEvents.map((x) => x.toJson())),
  };
}

class SlidingEvent {
  SlidingEvent({
    required this.name,
    required this.topText,
    required this.bottomText,
    required this.date,
    required this.picUrl,
  });

  String name;
  String topText;
  String bottomText;
  String date;
  String picUrl;

  factory SlidingEvent.fromJson(Map<String, dynamic> json) => SlidingEvent(
      name: json["Name"],
      topText: json["TopText"],
      bottomText: json["BottomText"],
      date: json["Date"],
      picUrl: json["PicUrl"]
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "TopText": topText,
    "BottomText": bottomText,
    "Date": date,
    "PicUrl": picUrl
  };
}
