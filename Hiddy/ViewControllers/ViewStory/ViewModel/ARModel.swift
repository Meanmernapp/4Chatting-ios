
import Foundation

struct UserDetails {
    var name: String = ""
    var imageUrl: String = ""
    var content: [Content] = []
    
    init(userDetails: [String: Any]) {
        name = userDetails["name"] as? String ?? ""
        imageUrl = userDetails["imageUrl"] as? String ?? ""
        let aContent = userDetails["content"] as? [[String : Any]] ?? []
        for element in aContent {
            content += [Content(element: element)]
        }
    }
}


struct Content {
    var type: String
    var url: String
    init(element: [String: Any]) {
        type = element["type"] as? String ?? ""
        url = element["url"] as? String ?? ""
    }
}

struct Lastseen {
    var user_id: Int
    var user_image: String
    var user_name: String
    init(element: [String: Any]) {
        user_id = element["user_id"] as? Int ?? 0
        user_image = element["user_image"] as? String ?? ""
        user_name = element["user_name"] as? String ?? ""
    }
}
