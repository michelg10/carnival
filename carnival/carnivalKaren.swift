//
//  coreKaren.swift
//  basicback4app
//
//  Created by LegitMichel777 on 2021/3/30.
//

import Foundation
import SwiftUI
import LeanCloud

struct Entry: Equatable {
    var lastUpdated: Date
    var marginalScore: Int
    var personID: String
    var addSource: String
}
struct Participant: Equatable, Hashable {
    var name: String
    var id: String
}

struct ParticipantInfo {
    var currentRank: Int
    var name: String
    var id: String
    var score: Int
    var previousRank: Int
}

let deltaTimeInterval: Double = -600

class carnivalKaren: ObservableObject {
    @Published var scoreaddpresets=[10,20,30,-10,-20,-30]
    var participantMap=[String: String]() // the participants map that maps a participant ID to a participant name, also retrieved from the server
    var entries: [Entry]=[] // the entries retrieved from the server
    @Published var selectedParticipant: String? // the participant currently selected within the score adding view
    
    @Published var participantMasterTable: [ParticipantInfo]=[] //master table, sorted by the rank
    
    var playerSearch=""
    
    @Published var myName: String = "Unnamed"
    
    //TODO: Invalidate selectedparticipant with every search
    
    func modifyScore(val: Int) {
        if selectedParticipant == nil {
            return
        }
        do {
            let nxtScore=LCObject(className: "entry")
            try nxtScore.set("marginalScore", value: val)
            try nxtScore.set("personID", value: selectedParticipant!)
            try nxtScore.set("addSource", value: myName)
            
            nxtScore.save { [self] result in
                switch result {
                case .success:
                    entries.append(.init(lastUpdated: Date(), marginalScore: val, personID: selectedParticipant!, addSource: myName))
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
        participantMasterTable.removeAll()
        
        // create display leaderboards
        let currentMap=generateOrder(validDate: Date())
        let lastMap=generateOrder(validDate: Date().advanced(by: deltaTimeInterval))
        let sortedInfo=currentMap.sorted { (a, b) -> Bool in
            if a.value > b.value {
                return true
            } else if a.value < b.value {
                return false
            }
            return a.key>b.key
        }
        print(sortedInfo)
        for i in 0..<sortedInfo.count {
            participantMasterTable.append(.init(currentRank: i+1, name: participantMap[sortedInfo[i].key] ?? "err-\(sortedInfo[i].key)", id: sortedInfo[i].key, score: sortedInfo[i].value, previousRank: lastMap[sortedInfo[i].key] ?? -1))
        }
        print("MSTR ",participantMasterTable)
        searchForParticipant(val: playerSearch)
    }
    
    func updateData() { // purpose: Update the master participant table
        var nxtParticipants=[String: String]()
        let participantsQuery=LCQuery(className: "participant")
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
        if !nxtParticipants.isEmpty {
            participantMap=nxtParticipants
        }
        print(participantMap)
        
        var nxtEntries: [Entry]=[]
        let entriesQuery=LCQuery(className: "entry")
        var entriesObj: [LCObject]?
        entriesObj=entriesQuery.find().objects
        if entriesObj != nil {
            for i in 0..<entriesObj!.count {
                let marginalScore = entriesObj![i]["marginalScore"]?.intValue
                let person=entriesObj![i]["personID"]?.stringValue
                let addSource=entriesObj![i]["addSource"]?.stringValue
                if marginalScore != nil && person != nil && addSource != nil {
                    nxtEntries.append(.init(lastUpdated: participantsObj![i].updatedAt!.value, marginalScore: marginalScore!, personID: person!, addSource: addSource!))
                }
            }
        }
        if nxtEntries != [] {
            entries=nxtEntries
        }
        
        DispatchQueue.main.async { [self] in
            regenerateMaster()
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
            print("Dealing with entry, score for \(i.personID), count \(i.marginalScore), submitted \(i.lastUpdated)")
            if i.lastUpdated<=validDate {
                print("Entry valid")
                orderGen[i.personID]=(orderGen[i.personID] ?? 0) + i.marginalScore
                print(orderGen)
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
            print("MASTER ",i.name,i.score)
            let partComp=i.name.lowercased().replacingOccurrences(of: " ", with: "")
            if partComp.hasPrefix(valComp) {
                rturnSearch.append(i)
            }
        }
        if rturnSearch.count>50 {
            rturnSearch.removeSubrange(50..<rturnSearch.count)
        }
        DispatchQueue.main.async { [self] in
            searchedParticipants=rturnSearch
        }
    }
    init(isPreview: Bool) {
        if isPreview {
            for i in 0..<previewNames.count {
                participantMasterTable.append(.init(currentRank: i+1, name: previewNames[i], id: UUID().uuidString, score: 0, previousRank: -1))
            }
            searchForParticipant(val: "")
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
        }
    }
}
