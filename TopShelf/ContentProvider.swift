//
//  ContentProvider.swift
//  TopShelf
//
//  Created by DLancerC on 2023/12/3.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        var topShelfSections :[TVTopShelfItemCollection<TVTopShelfSectionedItem>] = []
        addCurrentPlayCollection(topshelfItems: &topShelfSections)
        addPlayListCollection(topshelfItems: &topShelfSections)
        let sectionedContent: TVTopShelfSectionedContent = TVTopShelfSectionedContent(sections: topShelfSections)
        completionHandler(sectionedContent)
        
    }
    
    func addCurrentPlayCollection(topshelfItems: inout [TVTopShelfItemCollection<TVTopShelfSectionedItem>] ){
        if let currentPlayDictionary = UserDefaults.standard.shareValue(forKey: "currentPlay"){
            if let currentItem = creatContentItem(audioDictionary: currentPlayDictionary) {
                var currentItems = [TVTopShelfSectionedItem]()
                currentItems.append(currentItem)
                let currentItemCollection: TVTopShelfItemCollection = TVTopShelfItemCollection(items: currentItems)
                currentItemCollection.title = "当前播放"
                topshelfItems.append(currentItemCollection)
            }
        }
    }
    
    func addPlayListCollection(topshelfItems: inout [TVTopShelfItemCollection<TVTopShelfSectionedItem>] ){
        var playListItems = [TVTopShelfSectionedItem]()
        
        if let playList = UserDefaults.standard.shareListValue(forKey: "playList"){
            playList.forEach{ (playAudioDictionary) in
                guard let contentItem = creatContentItem(audioDictionary: playAudioDictionary) else { return }
                playListItems.append(contentItem)
            }
        }
                
        let playListItemCollection: TVTopShelfItemCollection = TVTopShelfItemCollection(items: playListItems)
        playListItemCollection.title = "播放列表"
        topshelfItems.append(playListItemCollection)
    }
    
    func creatContentItem(audioDictionary: Dictionary<String, Any>) -> TVTopShelfSectionedItem? {
        guard let audioId = audioDictionary["audioId"] as? Int else {
            return nil
        }
        let contentItem = TVTopShelfSectionedItem(identifier:  String(audioId))
        contentItem.playAction = TVTopShelfAction(url: URL(string: "vibefy://" + String(audioId))!)
        contentItem.displayAction = TVTopShelfAction(url: URL(string: "vibefy://" + String(audioId))!)
        
        if let imageURL = audioDictionary["audioPicUrl"] as? String {
            contentItem.setImageURL(URL(string: imageURL), for: TVTopShelfItem.ImageTraits.screenScale1x)
        }
        
        if let audioTitle = audioDictionary["audioTitle"] as? String {
            contentItem.title = audioTitle
        }
        return contentItem
    }
    
}

extension UserDefaults {
    func shareListValue(forKey key: String) ->[Dictionary<String, Any>]? {
        guard let jsonString = UserDefaults.init(suiteName: "group.com.wk.Vibefy")?.value(forKey: key) as? String else { return nil }
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let listData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else { return nil }
        return listData
    }
    
    func shareValue(forKey key: String) -> Dictionary<String, Any>? {
        guard let jsonString = UserDefaults.init(suiteName: "group.com.wk.Vibefy")?.value(forKey: key) as? String else { return nil }
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return nil }
        return dictionary
    }
}
