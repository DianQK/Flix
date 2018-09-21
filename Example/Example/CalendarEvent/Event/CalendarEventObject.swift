//
//  CalendarEventObject.swift
//  Example
//
//  Created by DianQK on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

struct CalendarEventObject: Equatable {

    var id: Int

    let title: String // default New Event
    let location: EventLocation?

    let isAllDay: Bool
    let startsDate: Date
    let endsDate: Date
    let eventRepeat: RepeatOption
    let endRepeatDate: Date?

    let calendar: CalendarOption

    let alert: AlertOption
    let secondAlert: AlertOption

    let showAs: ShowAsOption

    let url: String?
    let notes: String?

}

extension CalendarEventObject: StringIdentifiableType {

    var identity: String {
        return self.id.description
    }

}
