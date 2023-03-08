//
//  ChatModel.swift
//  LilyTalk
//
//  Created by 강조은 on 2023/03/09.
//

import ObjectMapper

class ChatModel: Mappable {
//    var uid: String?
//    var destinationUid: String?
    
    public var user: [String:Bool] = [:]   // 채팅방에 참여한 사람들
    public var comments: [String:Comment] = [:] // 채팅방의 대화내용
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        user <- map["user"]
        comments <- map["comments"]
    }
    
    public class Comment: Mappable {

        
        public var uid: String?
        public var message: String?
        public required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
        }
    }
}
