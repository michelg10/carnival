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

struct ParticipantInfo: Equatable {
    var currentRank: Int
    var name: String
    var id: String
    var score: Int
    var previousRank: Int
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
    @Published var pinnedIDs=["6063bce8ef9b462612fd56ef"]
    var participantMap=[String: String]() // the participants map that maps a participant ID to a participant name, also retrieved from the server
    var entries: [Entry]=[] // the entries retrieved from the server
    @Published var selectedParticipant: String? // the participant currently selected within the score adding view
    
    @Published var participantMasterTable: [ParticipantInfo]=[] //master table, sorted by the rank
    
    var playerSearch=""
    
    @Published var myName: String = "Unnamed"
    
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
        for i in 0..<sortedInfo.count {
            newParticipantMasterTable.append(.init(currentRank: i+1, name: participantMap[sortedInfo[i].key] ?? "err-\(sortedInfo[i].key)", id: sortedInfo[i].key, score: sortedInfo[i].value, previousRank: lastRankDict[sortedInfo[i].key] ?? -1))
        }
        if newParticipantMasterTable != participantMasterTable {
            print("Delta in master table. updating...")
            DispatchQueue.main.async {
                self.participantMasterTable=newParticipantMasterTable
            }
        }
//        print("MSTR ",participantMasterTable)
        searchForParticipant(val: playerSearch)
        refreshPinnedList()
    }
    
    func getParticipants() -> [String:String] {
        var nxtParticipants=[String: String]()
        let participantsQuery=LCQuery(className: "participant")
        let count=participantsQuery.count().intValue
        var gotten=0
        participantsQuery.limit=100
        while gotten<count {
            participantsQuery.skip=gotten
            var participantsObj: [LCObject]?
            participantsObj=participantsQuery.find().objects
            if participantsObj != nil {
                for i in 0..<participantsObj!.count {
                    let name = participantsObj![i]["name"]?.stringValue
                    if name != nil {
                        nxtParticipants[participantsObj![i].objectId!.value]=name!
                    }
                }
            }
            gotten+=100
        }
        return nxtParticipants
    }
    
    func getEntries() -> [Entry] {
        var nxtEntries: [Entry]=[]
        let entriesQuery=LCQuery(className: "entry")
        let count=entriesQuery.count().intValue
        var gotten=0
        entriesQuery.limit=100
        while gotten<count {
            entriesQuery.skip=gotten
            var entriesObj: [LCObject]?
            entriesObj=entriesQuery.find().objects
            if entriesObj != nil {
                for i in 0..<entriesObj!.count {
                    let marginalScore = entriesObj![i]["marginalScore"]?.intValue
                    let person=entriesObj![i]["personID"]?.stringValue
                    let addSource=entriesObj![i]["addSource"]?.stringValue
                    let addDate=entriesObj![i]["dateAdded"]?.dateValue
                    if marginalScore != nil && person != nil && addSource != nil && addDate != nil {
                        nxtEntries.append(.init(id: entriesObj![i].objectId!.value, lastUpdated: addDate!, marginalScore: marginalScore!, personID: person!, addSource: addSource!))
                    }
                }
            }
            gotten+=100
        }
        return nxtEntries
    }
    
    @objc func updateData() { // purpose: Update the master participant table
        print("Data update called")
        if refreshing {
            return
        }
        refreshing=true
        let nxtParticipants=getParticipants()
        if !nxtParticipants.isEmpty {
            participantMap=nxtParticipants
        }
        
        let nxtEntries=getEntries()
        if nxtEntries != [] {
            entries=nxtEntries
        }
        regenerateMaster()
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
    
    @objc func asyncUpdateData() {
        DispatchQueue.global(qos: .background).async { [self] in
            updateData()
        }
    }
    
    func sharedInit(isPreview: Bool) {
        loadData()
        let dateCurrent = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: dateCurrent)
        
        components.hour=5
        components.minute=40
        
        let midTrigger=calendar.date(from: components)
        print(midTrigger)
        
        components.hour=6
        components.minute=30
        
        let lateTrigger=calendar.date(from: components)
        print(lateTrigger)
        
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
        
        
        if isPreview {
            for i in 0..<previewNames.count {
                participantMasterTable.append(.init(currentRank: i+1, name: previewNames[i], id: UUID().uuidString, score: 0, previousRank: -1))
            }
            searchForParticipant(val: "")
            refreshPinnedList()
        } else {
//            LCApplication.logLevel = .all
            do {
                try LCApplication.default.set(id: "P2xVk27v7eW0a5JbatguaCtr-gzGzoHsz", key: "3E7b55rmm1VSiNRRF0tIN5xI", serverURL: "https://p2xvk27v.lc-cn-n1-shared.com", configuration: .default)
            } catch {
                fatalError("\(error)")
            }
            DispatchQueue.global().async { [self] in
                updateData()
            }
            let autoRefreshTimer=Timer(timeInterval: 3.0, target: self, selector: #selector(asyncUpdateData), userInfo: nil, repeats: true)
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
