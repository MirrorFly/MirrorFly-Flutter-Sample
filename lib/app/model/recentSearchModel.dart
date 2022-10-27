import 'dart:convert';

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
    jid: json["jid"] == null ? null : json["jid"],
    mid: json["mid"] == null ? null : json["mid"],
    searchType: json["search_type"] == null ? null : json["search_type"],
    chatType: json["chat_type"] == null ? null : json["chat_type"],
    isSearch: json["is_search"] == null ? null : json["is_search"],
  );

  Map<String, dynamic> toJson() => {
    "jid": jid == null ? null : jid,
    "mid": mid == null ? null : mid,
    "search_type": searchType == null ? null : searchType,
    "chat_type": chatType == null ? null : chatType,
    "is_search": isSearch == null ? null : isSearch,
  };
}