
class RecentSearch{
  RecentSearch({
    required this.jid,
    required this.mid,
    required this.searchType,
    required this.chatType,
    required this.isSearch
  });

  String? jid;
  String? mid;
  String? searchType;
  String? chatType;
  bool? isSearch;

  factory RecentSearch.fromJson(Map<String, dynamic> json) => RecentSearch(
    jid: json["jid"],
    mid: json["mid"],
    searchType: json["search_type"],
    chatType: json["chat_type"],
    isSearch: json["is_search"],
  );

  Map<String, dynamic> toJson() => {
    "jid": jid,
    "mid": mid,
    "search_type": searchType,
    "chat_type": chatType,
    "is_search": isSearch,
  };
}