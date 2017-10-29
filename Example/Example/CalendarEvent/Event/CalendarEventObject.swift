//
//  CalendarEventObject.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

struct CalendarEventObject {

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

extension CalendarEventObject: Equatable {

    static func ==(lhs: CalendarEventObject, rhs: CalendarEventObject) -> Bool {
        return (lhs.id == rhs.id) &&
        (lhs.location == rhs.location) &&
        (lhs.isAllDay == rhs.isAllDay) &&
        (lhs.startsDate == rhs.startsDate) &&
        (lhs.endsDate == rhs.endsDate) &&
        (lhs.eventRepeat == rhs.eventRepeat) &&
        (lhs.endRepeatDate == rhs.endRepeatDate) &&
        (lhs.calendar == rhs.calendar) &&
        (lhs.alert == rhs.alert) &&
        (lhs.secondAlert == rhs.secondAlert) &&
        (lhs.showAs == rhs.showAs) &&
        (lhs.url == rhs.url) &&
        (lhs.notes == rhs.notes)
    }

}
