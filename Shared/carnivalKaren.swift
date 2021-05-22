//
//  coreKaren.swift
//  basicback4app
//
//  Created by LegitMichel777 on 2021/3/30.
//

import Foundation
import SwiftUI
import LeanCloud

enum haptic {
    case soft
    case light
    case medium
    case heavy
    case rigid
}

func getChangeState(cur: Int, lst: Int) -> changeState {
    if cur==lst {
        return .nochange
    }
    if cur>lst {
        if cur>lst+10 {
            return .dDown
        } else {
            return .down
        }
    } else {
        if cur<lst-10 {
            return .dUp
        } else {
            return .up
        }
    }
}

let doubleThreshold=10

func generateHaptic(hap:haptic) {
    #if os(iOS)
    switch hap {
    case .soft:
        let softHapticsEngine=UIImpactFeedbackGenerator.init(style: .soft)
        softHapticsEngine.impactOccurred()
    case .light:
        let lightHapticsEngine=UIImpactFeedbackGenerator.init(style: .light)
        lightHapticsEngine.impactOccurred()
    case .medium:
        let mediumHapticsEngine=UIImpactFeedbackGenerator.init(style: .medium)
        mediumHapticsEngine.impactOccurred()
    case .heavy:
        let heavyHapticsEngine=UIImpactFeedbackGenerator.init(style: .heavy)
        heavyHapticsEngine.impactOccurred()
    case .rigid:
        let rigidHapticsEngine=UIImpactFeedbackGenerator.init(style: .rigid)
        rigidHapticsEngine.impactOccurred()
    }
    #endif
}

struct Entry: Equatable {
    var id: String
    var lastUpdated: Date
    var marginalScore: Int
    var personID: String
    var addSource: String
}
struct Participant: Equatable, Hashable {
    var name: String
    var id: String
}

struct participantUpdate:Equatable {
    var date: Date
    var who: String
    var val: Int
}

struct ParticipantInfo: Equatable {
    var currentRank: Int
    var name: String
    var id: String
    var score: Int
    var previousRank: Int
    var lastUpdated: participantUpdate?
}

struct playerDetail {
    var name: String
    var playerID: String
    var totalScore: Int
    var playerEntries: [Entry]
}

let deltaTimeInterval: Double = -600

class carnivalKaren: ObservableObject {
    var refreshing: Bool=false
    @Published var manualRefresh=false
    @Published var theme: String="mid"
    
    #if os(iOS)
    var parentImg: UIImageView?
    #endif
    
    let defaults=UserDefaults.standard
    
    func storeData<T>(toStore: T, id: String) {
        defaults.set(toStore,forKey: id)
    }
    
    func saveData() {
        storeData(toStore: scoreaddpresets, id: "scoreaddpresets")
        storeData(toStore: myName, id: "myName")
        storeData(toStore: pinnedIDs, id: "pinnedIDs")
    }
    
    func grabData<T>(toGrab: inout T, id: String) {
        var dataVal: Any?
        dataVal=defaults.object(forKey: id)
        if dataVal != nil {
            toGrab=dataVal as! T
        } else {
            print("Local \(id) data not present")
        }
    }
    
    func loadData() {
        grabData(toGrab: &scoreaddpresets, id: "scoreaddpresets")
        grabData(toGrab: &myName, id: "myName")
        grabData(toGrab: &pinnedIDs, id: "pinnedIDs")
    }
    
    @Published var pinnedParticipants: [ParticipantInfo]=[]
    
    func refreshPinnedList() {
        var nxtPinnedParticipants: [ParticipantInfo]=[]
        for i in participantMasterTable {
            if pinnedIDs.contains(i.id) {
                nxtPinnedParticipants.append(i)
            }
        }
        if pinnedParticipants != nxtPinnedParticipants {
            print("Delta in pinned participants")
            DispatchQueue.main.async { [self] in
                pinnedParticipants=nxtPinnedParticipants
            }
        }
    }
    
    @Published var scoreaddpresets=[10,20,30,-10,-20,-30]
    @Published var pinnedIDs: [String]=[]
    var participantMap=[String: String]() // the participants map that maps a participant ID to a participant name, also retrieved from the server
    var entries: [Entry]=[] // the entries retrieved from the server
    @Published var selectedParticipant: String? // the participant currently selected within the score adding view
    
    @Published var participantMasterTable: [ParticipantInfo]=[] //master table, sorted by the rank
    
    var playerSearch=""
    
    @Published var myName: String = "Unnamed"
    
    //MARK: Admin functions
    func removeEntry(id: String) {
        var index = -1
        for i in 0..<entries.count {
            if entries[i].id == id {
                index=i
                break
            }
        }
        if index == -1 {
            return
        }
        let toDelete = LCObject(className: "entry", objectId: id)
        _ = toDelete.delete { [self] result in
            switch result {
            case .success:
                entries.remove(at: index)
                DispatchQueue.main.async {
                    regenerateMaster()
                }
                break
            case .failure(error: let error):
                print(error)
            }
        }
    }
    
    func getPlayerDetail(id: String) -> playerDetail {
        if participantMap[id] == nil {
            return .init(name: "Error", playerID: "No ID", totalScore: -1, playerEntries: [.init(id: "error", lastUpdated: Date(), marginalScore: 0, personID: id, addSource: "Error"),.init(id: "error", lastUpdated: Date(), marginalScore: 0, personID: id, addSource: "Error"),.init(id: "error", lastUpdated: Date(), marginalScore: 0, personID: id, addSource: "Error"),.init(id: "error", lastUpdated: Date(), marginalScore: 0, personID: id, addSource: "Error"),.init(id: "error", lastUpdated: Date(), marginalScore: 0, personID: id, addSource: "Error")])
        }
        var playerScore=0
        var playerentries: [Entry]=[]
        for i in entries {
            if i.personID == id {
                playerScore+=i.marginalScore
                playerentries.append(i)
            }
        }
        return playerDetail(name: participantMap[id]!, playerID: id, totalScore: playerScore, playerEntries: playerentries)
    }
    
    func modifyScore(val: Int) {
        if selectedParticipant == nil {
            return
        }
        do {
            let nxtScore=LCObject(className: "entry")
            try nxtScore.set("marginalScore", value: val)
            try nxtScore.set("personID", value: selectedParticipant!)
            try nxtScore.set("addSource", value: myName)
            try nxtScore.set("dateAdded",value: Date())
            nxtScore.save { [self] result in
                switch result {
                case .success:
                    print("New operation has ID \(nxtScore.objectId!.value)")
                    entries.append(.init(id: nxtScore.objectId!.value, lastUpdated: Date(), marginalScore: val, personID: selectedParticipant!, addSource: myName))
                    selectedParticipant=nil
                    DispatchQueue.main.async {
                        regenerateMaster()
                    }
                    break
                case .failure(error: let error):
                    // Execute any logic that should take place if the save fails
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: End Admin functions
    
    @Published var recentpeople: [ParticipantInfo]=[]
    
    func refreshRecents(idToParticipantMasterIndexMap: [String:Int], newParticipantMasterTable:inout [ParticipantInfo]) {
        let recentLimit=50
        
        for i in entries.sorted(by: { e1, e2 in
            e1.lastUpdated>e2.lastUpdated
        }) {
            guard let participantIndex = idToParticipantMasterIndexMap[i.personID] else {
                continue
            }
            if newParticipantMasterTable[participantIndex].lastUpdated == nil {
                newParticipantMasterTable[participantIndex].lastUpdated = .init(date: i.lastUpdated, who: i.addSource, val: i.marginalScore)
            }
        }
        var lastUpdatedSortedTable=newParticipantMasterTable.sorted { a, b in
            if a.lastUpdated == nil && b.lastUpdated == nil {
                return a.id>b.id
            }
            if a.lastUpdated == nil {
                return false
            }
            if b.lastUpdated == nil {
                return true
            }
            if a.lastUpdated!.date==b.lastUpdated!.date {
                return a.id>b.id
            }
            return a.lastUpdated!.date>b.lastUpdated!.date
        }
        if lastUpdatedSortedTable.count>recentLimit {
            lastUpdatedSortedTable.removeSubrange(50..<lastUpdatedSortedTable.count)
        }
        for i in 0..<lastUpdatedSortedTable.count {
            if lastUpdatedSortedTable[i].lastUpdated == nil {
                lastUpdatedSortedTable.removeSubrange(i..<lastUpdatedSortedTable.count)
                break
            }
        }
        if lastUpdatedSortedTable != recentpeople {
            print("Delta in recents table. updating...")
            DispatchQueue.main.async { [self] in
                recentpeople=lastUpdatedSortedTable
                print(recentpeople)
            }
        }
    }
    
    func regenerateMaster() {
        var newParticipantMasterTable: [ParticipantInfo]=[]
        
        // create display leaderboards
        let currentMap=generateOrder(validDate: Date())
        let lastMap=generateOrder(validDate: Date().advanced(by: deltaTimeInterval))
        let sortrule = { (a: Dictionary<String, Int>.Element, b:Dictionary<String, Int>.Element) -> Bool in
            if a.value > b.value {
                return true
            } else if a.value < b.value {
                return false
            }
            return a.key>b.key
        }
        let sortedInfo=currentMap.sorted(by: sortrule)
        let sortedLastMap=lastMap.sorted(by: sortrule)
        var lastRankDict: [String: Int]=[:]
        for i in 0..<sortedLastMap.count {
            lastRankDict[sortedLastMap[i].key]=i+1
        }
//        print(sortedInfo)
        var idToParticipantMasterIndexMap: [String:Int]=[:]
        for i in 0..<sortedInfo.count {
            newParticipantMasterTable.append(.init(currentRank: i+1, name: participantMap[sortedInfo[i].key] ?? "err-\(sortedInfo[i].key)", id: sortedInfo[i].key, score: sortedInfo[i].value, previousRank: lastRankDict[sortedInfo[i].key] ?? -1, lastUpdated: nil))
            idToParticipantMasterIndexMap[sortedInfo[i].key]=i
        }
        
//        print(newParticipantMasterTable)
        if newParticipantMasterTable != participantMasterTable {
            print("Delta in master table. updating...")
            if !Thread.isMainThread {
                DispatchQueue.main.sync {
                    self.participantMasterTable=newParticipantMasterTable
                }
            } else {
                self.participantMasterTable=newParticipantMasterTable
            }
            searchForParticipant(val: playerSearch)
            #if os(macOS)
            refreshRecents(idToParticipantMasterIndexMap: idToParticipantMasterIndexMap, newParticipantMasterTable: &newParticipantMasterTable)
            #endif
            #if os(iOS)
            refreshPinnedList()
            #endif
        }
    }
    
    var lastFetchEntries: Date?
    
    //MARK: Fetch raw data from the servers
    func getParticipants() -> [String:String] {
        var nxtParticipants=[String: String]()
        let participantsQuery=LCQuery(className: "participant")
        let count=participantsQuery.count().intValue
        var gotten=0
        participantsQuery.limit=1000
        while gotten<count {
            participantsQuery.skip=gotten
            var participantsObj: [LCObject]?
            participantsObj=participantsQuery.find(cachePolicy: .networkElseCache).objects
            if participantsObj != nil {
                for i in 0..<participantsObj!.count {
                    let name = participantsObj![i]["name"]?.stringValue
                    if name != nil {
                        nxtParticipants[participantsObj![i].objectId!.value]=name!
                    }
                }
            }
            gotten+=1000
        }
        return nxtParticipants
    }
    
    func refreshEntries() -> Bool {
        var nxtEntries: [Entry]=[]
        let entriesQuery=LCQuery(className: "entry")
        if lastFetchEntries != nil {
            entriesQuery.whereKey("createdAt", .greaterThanOrEqualTo(lastFetchEntries!))
        }
        let count=entriesQuery.count().intValue
        if count == 0 {
            return false
        }
        var gotten=0
        entriesQuery.limit=1000
        while gotten<count {
            entriesQuery.skip=gotten
            var entriesObj: [LCObject]?
            entriesObj=entriesQuery.find(cachePolicy: .networkElseCache).objects
            if entriesObj != nil {
                for i in 0..<entriesObj!.count {
                    let marginalScore = entriesObj![i]["marginalScore"]?.intValue
                    let person=entriesObj![i]["personID"]?.stringValue
                    let addSource=entriesObj![i]["addSource"]?.stringValue
                    let addDate=entriesObj![i]["dateAdded"]?.dateValue
                    if marginalScore != nil && person != nil && addSource != nil && addDate != nil {
                        if !entries.contains(where: { entryElement in
                            entryElement.id == entriesObj![i].objectId!.value
                        }) {
                            nxtEntries.append(.init(id: entriesObj![i].objectId!.value, lastUpdated: addDate!, marginalScore: marginalScore!, personID: person!, addSource: addSource!))
                        }
                    }
                }
            }
            gotten+=1000
        }
        entries.append(contentsOf: nxtEntries)
        lastFetchEntries=Date()
        return true
    }
    
    func applicationActive() -> Bool {
        #if os(macOS)
        return true
        #endif
        #if os(iOS)
        if Thread.isMainThread {
            return UIApplication.shared.applicationState != .background
        } else {
            var res=true
            DispatchQueue.main.sync {
                res=UIApplication.shared.applicationState != .background
            }
            return res
        }
        #endif
    }
    
    
    @objc func totalUpdateData(getparticipants: Bool) { // purpose: Completely refresh with data from the servers
        print("Full data update called")
        if refreshing {
            return
        }
        refreshing=true
        
        if getparticipants {
            let nxtParticipants=getParticipants()
            participantMap=nxtParticipants
        }
        
        let hasdelta=refreshEntries()
        if hasdelta || getparticipants {
            regenerateMaster()
        }
        DispatchQueue.main.async { [self] in
            refreshing=false
            if manualRefresh {
                manualRefresh=false
            }
        }
    }
    
    func fillWithFiller() {
        for i in previewNames {
            do {
                let name=LCObject(className: "participant")
                try name.set("name", value: i)
                let result=name.save()
                if let error=result.error {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func generateOrder(validDate: Date) -> [String:Int] { // returns a dictionary of scores
        var orderGen=[String: Int]()
        for i in participantMap.keys {
            orderGen[i]=0
        }
        for i in entries {
//            print("Dealing with entry, score for \(i.personID), count \(i.marginalScore), submitted \(i.lastUpdated)")
            if i.lastUpdated<=validDate {
//                print("Entry valid")
                orderGen[i.personID]=(orderGen[i.personID] ?? 0) + i.marginalScore
            }
        }
        return orderGen
    }
    @Published var searchedParticipants: [ParticipantInfo]=[]
    let searchLimit=50
    
    func searchForParticipant(val: String) {
        var rturnSearch: [ParticipantInfo]=[]
        let valComp=val.lowercased().replacingOccurrences(of: " ", with: "")
        for i in participantMasterTable {
//            print("MASTER ",i.name,i.score)
            let partComp=i.name.lowercased().replacingOccurrences(of: " ", with: "")
            if partComp.hasPrefix(valComp) {
                rturnSearch.append(i)
            }
        }
        if selectedParticipant != nil {
            var shouldCancelSelection=true
            for i in rturnSearch {
                if i.id == selectedParticipant {
                    shouldCancelSelection=false
                    break
                }
            }
            if shouldCancelSelection {
                selectedParticipant=nil
            }
        }
        if rturnSearch.count>50 {
            rturnSearch.removeSubrange(50..<rturnSearch.count)
        }
        if searchedParticipants != rturnSearch {
            print("Delta in searched participants. updating...")
            DispatchQueue.main.async { [self] in
                searchedParticipants=rturnSearch
            }
        }
    }
    
    @objc func changeThemeEarly() {
        theme="early"
        #if os(iOS)
        if parentImg != nil {
            parentImg!.image=UIImage(named: "image-early")
        }
        #endif
    }
    
    @objc func changeThemeMid() {
        theme="mid"
        #if os(iOS)
        if parentImg != nil {
            parentImg!.image=UIImage(named: "image-mid")
        }
        #endif
    }
    
    @objc func changeThemeLate() {
        theme="late"
        #if os(iOS)
        if parentImg != nil {
            parentImg!.image=UIImage(named: "image-late")
        }
        #endif
    }
    
    func addObj(object: LCObject) {
        let marginalScore=object["marginalScore"]?.intValue
        let person=object["personID"]?.stringValue
        let addSource=object["addSource"]?.stringValue
        let addDate=object["dateAdded"]?.dateValue
        let objid=object.objectId?.value
        if objid != nil && addDate != nil && addSource != nil && person != nil && marginalScore != nil {
            entries.append(.init(id: objid!, lastUpdated: addDate!, marginalScore: marginalScore!, personID: person!, addSource: addSource!))
        }
    }
    
    @objc func asyncUpdateData() {
        DispatchQueue.global(qos: .background).async { [self] in
            if applicationActive() {
                totalUpdateData(getparticipants: false)
            } else {
                print("Auto update skipped - application in background")
            }
        }
    }
    
    func getIntConstant(key: String) -> Int? {
        let entriesQuery=LCQuery(className: "constants")
        entriesQuery.whereKey("name", .equalTo(key))
        let obj=entriesQuery.getFirst()
        return obj.object?["value"]?.intValue
    }
    
    func sharedInit(isPreview: Bool) {
        loadData()
        
        if isPreview {
            for i in 0..<previewNames.count {
                participantMasterTable.append(.init(currentRank: i+1, name: previewNames[i], id: UUID().uuidString, score: 0, previousRank: -1))
            }
            searchForParticipant(val: "")
            refreshPinnedList()
        } else {
//            LCApplication.logLevel = .all
            do {
                var configuration = LCApplication.Configuration.default
                configuration.HTTPURLCache = URLCache(
                    // 内存缓存容量，100 MB
                    memoryCapacity: 100 * 1024 * 1024,
                    // 磁盘缓存容量，100 MB
                    diskCapacity: 100 * 1024 * 1024,
                    // `nil` 表示使用系统默认的缓存路径，你也可以自定义路径
                    diskPath: nil)
                try LCApplication.default.set(id: "P2xVk27v7eW0a5JbatguaCtr-gzGzoHsz", key: "3E7b55rmm1VSiNRRF0tIN5xI", serverURL: "https://p2xvk27v.lc-cn-n1-shared.com", configuration: configuration)
            } catch {
                fatalError("\(error)")
            }
            
            let dateCurrent = Date()
            let calendar = Calendar.current
            var components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dateCurrent)
            
            components.hour=getIntConstant(key: "midChangeHour") ?? 0
            components.minute=getIntConstant(key: "midChangeMinute") ?? 0
            
            let midTrigger=calendar.date(from: components)
            
            components.hour=getIntConstant(key: "lateChangeHour") ?? 23
            components.minute=getIntConstant(key: "lateChangeHour") ?? 59
            
            let lateTrigger=calendar.date(from: components)
            
            let changeThemes = (midTrigger != nil) && (lateTrigger != nil)
            
            if changeThemes {
                if Date() < midTrigger! {
                    changeThemeEarly()
                } else if Date()<lateTrigger! {
                    changeThemeMid()
                } else {
                    changeThemeLate()
                }
                if Date()<lateTrigger! {
                    let timer = Timer(fireAt: lateTrigger!, interval: 0, target: self, selector: #selector(changeThemeLate), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                }
                if Date()<midTrigger! {
                    let timer = Timer(fireAt: midTrigger!, interval: 0, target: self, selector: #selector(changeThemeMid), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                }
            }
            
            totalUpdateData(getparticipants: true)
            let autoRefreshTimer=Timer(timeInterval: 10, target: self, selector: #selector(asyncUpdateData), userInfo: nil, repeats: true)
            RunLoop.main.add(autoRefreshTimer, forMode: .common)
        }
    }
    
    #if os(macOS)
    init(isPreview: Bool) {
        sharedInit(isPreview: isPreview)
    }
    #endif
    
    #if os(iOS)
    init(isPreview: Bool, parentImage: UIImageView?=nil) {
        parentImg=parentImage
        
        sharedInit(isPreview: isPreview)
    }
    #endif
}
