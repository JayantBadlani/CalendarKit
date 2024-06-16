import UIKit
import CalendarKit
import SwiftUI


protocol CalenderKitDelegate: AnyObject {
    func dayViewDidSelectEventView(_ eventView: EventView, controller: CustomCalendarExampleController2)
    func dayViewDidLongPressEventView(_ eventView: EventView, controller: CustomCalendarExampleController2)
    func dayView(dayView: DayView, didTapTimelineAt date: Date, controller: CustomCalendarExampleController2)
    func dayView(dayView: DayView, didLongPressTimelineAt date: Date, controller: CustomCalendarExampleController2)
    func dayViewDidBeginDragging(dayView: DayView, controller: CustomCalendarExampleController2)
    func dayViewDidTransitionCancel(dayView: DayView, controller: CustomCalendarExampleController2)
    func dayView(dayView: DayView, willMoveTo date: Date, controller: CustomCalendarExampleController2)
    func dayView(dayView: DayView, didMoveTo  date: Date, controller: CustomCalendarExampleController2)
    func dayView(dayView: DayView, didUpdate event: EventDescriptor, controller: CustomCalendarExampleController2)
    func loadView(controller: CustomCalendarExampleController2)
}
protocol CalenderKitDataSource: EventDataSource {}


final class CustomCalendarExampleController2: DayViewController {
    
    var events: [EventDescriptor]
    weak var delegates: CalenderKitDelegate?
    //var dataSource: CalenderKitDataSource?
    
    init(events: [EventDescriptor]) {
        self.events = events
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func eventsForDate(_ date: Date) -> [CalendarKit.EventDescriptor] {
        return events
    }
    
    override func loadView() {
        delegates?.loadView(controller: self)
    }
    
    override func dayViewDidSelectEventView(_ eventView: CalendarKit.EventView) {
        delegates?.dayViewDidSelectEventView(eventView, controller: self)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: CalendarKit.EventView) {
        delegates?.dayViewDidLongPressEventView(eventView, controller: self)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didTapTimelineAt date: Date) {
        delegates?.dayView(dayView: dayView, didTapTimelineAt: date, controller: self)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didLongPressTimelineAt date: Date) {
        delegates?.dayView(dayView: dayView, didLongPressTimelineAt: date, controller: self)
    }
    
    override func dayViewDidBeginDragging(dayView: CalendarKit.DayView) {
        delegates?.dayViewDidBeginDragging(dayView: dayView, controller: self)
    }
    
    override func dayViewDidTransitionCancel(dayView: CalendarKit.DayView) {
        delegates?.dayViewDidTransitionCancel(dayView: dayView, controller: self)
    }
    
    override func dayView(dayView: CalendarKit.DayView, willMoveTo date: Date) {
        delegates?.dayView(dayView: dayView, willMoveTo: date, controller: self)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didMoveTo date: Date) {
        delegates?.dayView(dayView: dayView, didMoveTo: date, controller: self)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didUpdate event: CalendarKit.EventDescriptor) {
        delegates?.dayView(dayView: dayView, didUpdate: event, controller: self)
    }
}



struct CustomCalendarExampleControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var events: [EventDescriptor]
    
    func makeUIViewController(context: Context) -> CustomCalendarExampleController2 {
        let viewController = CustomCalendarExampleController2(events: events)
        viewController.delegates = context.coordinator
        viewController.dataSource = context.coordinator
        viewController.reloadData()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CustomCalendarExampleController2, context: Context) {
        uiViewController.events = events
        uiViewController.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, CalenderKitDelegate, CalenderKitDataSource {
        
        var parent: CustomCalendarExampleControllerRepresentable
        var alreadyGeneratedSet = Set<Date>()
        var createdEvent: EventDescriptor?
        
        init(parent: CustomCalendarExampleControllerRepresentable) {
            self.parent = parent
        }
        
        var data = [["Breakfast at Tiffany's",
                     "New York, 5th avenue"],
                    
                    ["Workout",
                     "Tufteparken"],
                    
                    ["Meeting with Alex",
                     "Home",
                     "Oslo, Tjuvholmen"],
                    
                    ["Beach Volleyball",
                     "Ipanema Beach",
                     "Rio De Janeiro"],
                    
                    ["WWDC",
                     "Moscone West Convention Center",
                     "747 Howard St"],
                    
                    ["Google I/O",
                     "Shoreline Amphitheatre",
                     "One Amphitheatre Parkway"],
                    
                    ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️",
                     "Oslo Gardermoen"],
                    
                    ["💻📲 Developing CalendarKit",
                     "🌍 Worldwide"],
                    
                    ["Software Development Lecture",
                     "Mikpoli MB310",
                     "Craig Federighi"],
        ]
        
        var colors = [UIColor.blue,
                      UIColor.yellow,
                      UIColor.green,
                      UIColor.red]
        
        private lazy var dateIntervalFormatter: DateIntervalFormatter = {
            let dateIntervalFormatter = DateIntervalFormatter()
            dateIntervalFormatter.dateStyle = .none
            dateIntervalFormatter.timeStyle = .short
            
            return dateIntervalFormatter
        }()
        
        func loadView(controller: CustomCalendarExampleController2) {
            controller.dayView = DayView(calendar: controller.calendar)
            controller.view = controller.dayView
            controller.dayView.autoScrollToFirstEvent = true
            controller.navigationController?.navigationBar.isHidden = true
            controller.reloadData()
        }
        
        
        // MARK: EventDataSource
        func eventsForDate(_ date: Date) -> [EventDescriptor] {
            if !alreadyGeneratedSet.contains(date) {
                alreadyGeneratedSet.insert(date)
                parent.events.append(contentsOf: generateEventsForDate(date))
            }
            return parent.events
        }
        
        
        private func generateEventsForDate(_ date: Date) -> [EventDescriptor] {
            var workingDate = Calendar.current.date(byAdding: .hour, value: Int.random(in: 1...15), to: date)!
            var events = [Event]()
            
            for i in 0...4 {
                let event = Event()
                
                let duration = Int.random(in: 60 ... 160)
                event.dateInterval = DateInterval(start: workingDate, duration: TimeInterval(duration * 60))
                
                var info = data.randomElement() ?? []
                
                info.append(dateIntervalFormatter.string(from: event.dateInterval.start, to: event.dateInterval.end))
                event.text = info.reduce("", {$0 + $1 + "\n"})
                event.color = colors.randomElement() ?? .red
                event.isAllDay = true
                event.lineBreakMode = .byTruncatingTail
                
                events.append(event)
                
                let nextOffset = Int.random(in: 40 ... 250)
                workingDate = Calendar.current.date(byAdding: .minute, value: nextOffset, to: workingDate)!
                event.userInfo = String(i)
            }
            
            print("Events for \(date)")
            return events
        }
        
        // MARK: DayViewDelegate
        func dayViewDidSelectEventView(_ eventView: EventView,controller: CustomCalendarExampleController2) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
        }
        
        func dayViewDidLongPressEventView(_ eventView: CalendarKit.EventView, controller: CustomCalendarExampleController2) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            controller.endEventEditing()
            print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
            controller.beginEditing(event: descriptor, animated: true)
            print(Date())
        }
        
        func dayView(dayView: CalendarKit.DayView, didTapTimelineAt date: Date, controller: CustomCalendarExampleController2) {
            controller.endEventEditing()
            print("Did Tap at date: \(date)")
        }
        
        func dayViewDidBeginDragging(dayView: CalendarKit.DayView, controller: CustomCalendarExampleController2) {
            controller.endEventEditing()
            print("DayView did begin dragging")
        }
        
        func dayView(dayView: CalendarKit.DayView, willMoveTo date: Date, controller: CustomCalendarExampleController2) {
            print("DayView = \(dayView) will move to: \(date)")
        }
        
        func dayView(dayView: CalendarKit.DayView, didMoveTo date: Date, controller: CustomCalendarExampleController2) {
            print("DayView = \(dayView) did move to: \(date)")
        }
        
        func dayViewDidTransitionCancel(dayView: CalendarKit.DayView, controller: CustomCalendarExampleController2) {
        }
        
        func dayView(dayView: CalendarKit.DayView, didLongPressTimelineAt date: Date, controller: CustomCalendarExampleController2) {
            print("Did long press timeline at date \(date)")
            // Cancel editing current event and start creating a new one
            controller.endEventEditing()
            let event = generateEventNearDate(date)
            print("Creating a new event")
            controller.create(event: event, animated: true)
            createdEvent = event
        }
        
        private func generateEventNearDate(_ date: Date) -> EventDescriptor {
            let duration = (60...220).randomElement()!
            let startDate = Calendar.current.date(byAdding: .minute, value: -Int(Double(duration) / 2), to: date)!
            let event = Event()
            
            event.dateInterval = DateInterval(start: startDate, duration: TimeInterval(duration * 60))
            
            var info = data.randomElement()!
            
            info.append(dateIntervalFormatter.string(from: event.dateInterval)!)
            event.text = info.reduce("", {$0 + $1 + "\n"})
            event.color = colors.randomElement()!
            event.editedEvent = event
            
            return event
        }
        
        func dayView(dayView: CalendarKit.DayView, didUpdate event: CalendarKit.EventDescriptor, controller: CustomCalendarExampleController2) {
            print("did finish editing \(event)")
            print("new startDate: \(event.dateInterval.start) new endDate: \(event.dateInterval.end)")
            
            if let _ = event.editedEvent {
                event.commitEditing()
            }
            
            if let createdEvent = createdEvent {
                createdEvent.editedEvent = nil
                parent.events.append(createdEvent)
                self.createdEvent = nil
                controller.endEventEditing()
            }
            controller.reloadData()
        }
    }
}
