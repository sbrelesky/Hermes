//
//  Calendar.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import CVCalendar

extension CVCalendarView {

    public func redrawViewIfNecessarry() {
        let contentViewSize = contentController.bounds.size
        let selfSize = bounds.size
        if selfSize.width != contentViewSize.width {
            let width = selfSize.width
            let height: CGFloat
            let countOfWeeks = CGFloat(6)

            let vSpace = appearance.spaceBetweenWeekViews!
            let hSpace = appearance.spaceBetweenDayViews!

            if let mode = calendarMode {
                switch mode {
                case .weekView:
                    height = selfSize.height
                case .monthView :
                    height = (selfSize.height / countOfWeeks) - (vSpace * countOfWeeks)
                }

                
                weekViewSize = CGSize(width: width, height: height)
                dayViewSize = CGSize(width: (width / 7.0) - hSpace, height: height)

                contentController.updateFrames(selfSize != contentViewSize ? bounds : .zero)
            }
        }
    }
}
