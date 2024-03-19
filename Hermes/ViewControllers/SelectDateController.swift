//
//  ChooseDateController.swift
//  Hermes
//
//  Created by Shane on 3/6/24.
//

import Foundation
import UIKit
import SnapKit
import CVCalendar


class SelectDateController: BaseViewController {
    
    
    let monthLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = ThemeManager.Font.Style.secondary(weight: .demiBold).font.withDynamicSize(18.0)
        l.textColor = ThemeManager.Color.gray
        l.text = ""
        l.textAlignment = .center
        
        return l
    }()
    
    
    let selectDateLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeManager.Font.Style.main.font.withDynamicSize(18.0)
        l.textColor = ThemeManager.Color.gray
        l.text = "Select date for overnight fill up (\(Constants.Text.operatingHours))"
        l.textAlignment = .left
        
        return l
    }()
    
    lazy var calendarView: CVCalendarView = {
        let cv = CVCalendarView(frame: .zero)
        
        let appearance = Appearance()
        // Font
        appearance.dayLabelWeekdayFont = ThemeManager.Font.Style.main.font // Normal Day
        appearance.dayLabelPresentWeekdayFont = ThemeManager.Font.Style.main.font // Current Day
        appearance.dayLabelWeekdaySelectedFont = ThemeManager.Font.Style.main.font // Selected
        appearance.dayLabelPresentWeekdaySelectedFont = ThemeManager.Font.Style.main.font
        
        // Color
        appearance.dayLabelWeekdayDisabledColor = ThemeManager.Color.placeholder // Disabled Dau
        appearance.dayLabelWeekdayInTextColor = ThemeManager.Color.text // Normal Day - In
        appearance.dayLabelPresentWeekdayTextColor = ThemeManager.Color.text // Current Day
        
        cv.appearance = appearance
        
        cv.presentedDate = CVDate(date: getFirstSelectedDate())
                 
        cv.delegate = self
        cv.calendarDelegate = self
        cv.calendarAppearanceDelegate = self
       
        return cv
   }()
   
   lazy var calendarMenuView: CVCalendarMenuView = {
       let cmv = CVCalendarMenuView(frame: .zero)
       
       cmv.firstWeekday = .monday
       cmv.dayOfWeekFont = ThemeManager.Font.Style.main.font.withDynamicSize(10.0)
       cmv.dayOfWeekTextColor = ThemeManager.Color.gray

       cmv.menuViewDelegate = self
       
       return cmv
   }()
    
    
    lazy var scheduleButton: HermesLoadingButton = {
        let b = HermesLoadingButton(frame: .zero)
        b.setTitle("Schedule Fill Up", for: .normal)
        b.addTarget(self, action: #selector(schedulePressed), for: .touchUpInside)
        
        return b
    }()
    
    let cars: [Car]
    let address: Address
    
    var date: Date?
    
    init(cars: [Car], address: Address) {
        self.cars = cars
        self.address = address
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Date"
        
        setupViews()
        
        let calendar = Calendar(identifier: .gregorian)
        monthLabel.text = CVDate(date: Date(), calendar: calendar).globalDescription
        
        
        FillUpManager.shared.fetchDisabledDates { [weak self] error in
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.presentError(error: error)
            } else {
                strongSelf.setDisabledDates()
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(selectDateLabel)
        view.addSubview(monthLabel)
        view.addSubview(calendarMenuView)
        view.addSubview(calendarView)
        view.addSubview(scheduleButton)
       
        selectDateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(selectDateLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        calendarMenuView.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(calendarMenuView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
        }
        
        scheduleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-40)
        }
        
    }
    
    private func setDisabledDates() {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
        
        calendarView.contentController.presentedMonthView.mapDayViews { day in
            guard let date = day.date.convertedDate() else { return }
            
            if date < yesterday{
                day.isUserInteractionEnabled = false
                day.dayLabel.textColor = ThemeManager.Color.placeholder
                return
            }
            
            if FillUpManager.shared.disabledFillUpDates.contains(date){
                day.isUserInteractionEnabled = false
                day.dayLabel.textColor = ThemeManager.Color.placeholder
            }
        }
    }
    
    @objc func schedulePressed() {
        guard let user = UserManager.shared.currentUser,
              let date = date else { return }
        
        let fillUp = FillUp(status: .open, date: date, address: address, cars: cars, user: user, paymentIntentSecret: "")
        
        let vc = CheckoutController(fillUp: fillUp)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getFirstSelectedDate() -> Date {
        var calendar = Calendar.current
        // Use the following line if you want midnight UTC instead of local time
        //calendar.timeZone = TimeZone(secondsFromGMT: 0)
        let today = Date()
        let midnight = calendar.startOfDay(for: today)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: midnight)!
        
        // Get the current hour using the calendar
        let currentHour = calendar.component(.hour, from: today)

        // Check if the current hour is after 10 PM (22:00)
        if currentHour >= Constants.dateCutoffHour, let selectedDate = calendar.date(byAdding: .day, value: 1, to: tomorrow) {
            return selectedDate
        } else {
            return tomorrow
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        calendarMenuView.commitMenuViewUpdate()
        calendarView.redrawViewIfNecessarry()
    }
}


extension SelectDateController: CVCalendarMenuViewDelegate {}

extension SelectDateController: CVCalendarViewDelegate {
    
    func presentationMode() -> CVCalendar.CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> CVCalendar.Weekday {
        return .monday
    }
    
    
    func presentedDateUpdated(_ date: CVDate) {
        self.date = date.convertedDate()
        monthLabel.text = "\(date.globalDescription)"
    }
    
    func disableScrollingBeforeDate() -> Date {
        return Date()
    }
    
    func earliestSelectableDate() -> Date {
        return getFirstSelectedDate()
    }
}

extension SelectDateController: CVCalendarViewAppearanceDelegate {
   
    func spaceBetweenDayViews() -> CGFloat { return 0 }

    // MARK: - Background Color and Alpha methods
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        // Any selected day, that's not current day
        case (_, .selected, .not), (_, .highlighted, .not): return ThemeManager.Color.yellow
        // Current day at all times
        case (_, _, .present): return ThemeManager.Color.gray
        default: return nil
        }
    }
}
