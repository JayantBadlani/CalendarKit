import UIKit
import CalendarKit
import SwiftUI


protocol CalenderKitDelegate: DayViewDelegate {
    func loadView()
}
protocol CalenderKitDataSource: EventDataSource {}

final class CustomCalendarExampleController2: DayViewController, CalenderKitDelegate, CalenderKitDataSource {
    
    var events: [EventDescriptor]
    weak var delegates: CalenderKitDelegate?
    
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
        delegates?.loadView()
    }
    
    override func dayViewDidSelectEventView(_ eventView: CalendarKit.EventView) {
        delegates?.dayViewDidSelectEventView(eventView)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: CalendarKit.EventView) {
        delegates?.dayViewDidLongPressEventView(eventView)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didTapTimelineAt date: Date) {
        delegates?.dayView(dayView: dayView, didTapTimelineAt: date)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didLongPressTimelineAt date: Date) {
        delegates?.dayView(dayView: dayView, didLongPressTimelineAt: date)
    }
    
    override func dayViewDidBeginDragging(dayView: CalendarKit.DayView) {
        delegates?.dayViewDidBeginDragging(dayView: dayView)
    }
    
    override func dayViewDidTransitionCancel(dayView: CalendarKit.DayView) {
        delegates?.dayViewDidTransitionCancel(dayView: dayView)
    }
    
    override func dayView(dayView: CalendarKit.DayView, willMoveTo date: Date) {
        delegates?.dayView(dayView: dayView, willMoveTo: date)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didMoveTo date: Date) {
        delegates?.dayView(dayView: dayView, didMoveTo: date)
    }
    
    override func dayView(dayView: CalendarKit.DayView, didUpdate event: CalendarKit.EventDescriptor) {
        delegates?.dayView(dayView: dayView, didUpdate: event)
    }
}



struct CustomCalendarExampleControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var events: [EventDescriptor]
    var viewController: CustomCalendarExampleController2 = CustomCalendarExampleController2(events: [])
    
    func makeUIViewController(context: Context) -> CustomCalendarExampleController2 {
        //self.viewController = CustomCalendarExampleController2(events: events)
        self.viewController.delegates = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CustomCalendarExampleController2, context: Context) {
        uiViewController.events = events
        uiViewController.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, viewController: self.viewController, events: $events)
    }
    
    class Coordinator: NSObject, CalenderKitDelegate, CalenderKitDataSource {
        
        var parent: CustomCalendarExampleControllerRepresentable
        var viewController: CustomCalendarExampleController2
        var alreadyGeneratedSet = Set<Date>()
        // @Binding var generatedEvents: [Event]
        @Binding var generatedEvents: [EventDescriptor]
        
        init(parent: CustomCalendarExampleControllerRepresentable, viewController: CustomCalendarExampleController2, events: Binding<[EventDescriptor]>) {
            self.parent = parent
            self.viewController = viewController
            self._generatedEvents = events
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
        
        func loadView() {
            viewController.dayView = DayView(calendar: viewController.calendar)
            viewController.view = viewController.dayView
            viewController.dayView.autoScrollToFirstEvent = true
            viewController.navigationController?.navigationBar.isHidden = true
            viewController.reloadData()
        }
        
        // MARK: EventDataSource
        func eventsForDate(_ date: Date) -> [EventDescriptor] {
            if !alreadyGeneratedSet.contains(date) {
                alreadyGeneratedSet.insert(date)
                generatedEvents.append(contentsOf: generateEventsForDate(date))
            }
            return generatedEvents
        }
        
        private func generateEventsForDate(_ date: Date) -> [EventDescriptor] {
            var workingDate = Calendar.current.date(byAdding: .hour, value: Int.random(in: 1...15), to: date)!
            var events = [Event]()
            
            for i in 0...4 {
                let event = Event()
                
                let duration = Int.random(in: 60 ... 160)
                event.dateInterval = DateInterval(start: workingDate, duration: TimeInterval(duration * 60))
                
                var info = data.randomElement() ?? []
                
                let timezone = viewController.dayView.calendar.timeZone
                print(timezone)
                
                info.append(dateIntervalFormatter.string(from: event.dateInterval.start, to: event.dateInterval.end))
                event.text = info.reduce("", {$0 + $1 + "\n"})
                event.color = colors.randomElement() ?? .red
                event.isAllDay = Bool.random()
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
        private var createdEvent: EventDescriptor?
        
        func dayViewDidSelectEventView(_ eventView: EventView) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            print("Event has been selected: \(descriptor) \(String(describing: descriptor.userInfo))")
        }
        
        func dayViewDidLongPressEventView(_ eventView: EventView) {
            guard let descriptor = eventView.descriptor as? Event else {
                return
            }
            viewController.endEventEditing()
            print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
            viewController.beginEditing(event: descriptor, animated: true)
            print(Date())
        }
        
        func dayView(dayView: DayView, didTapTimelineAt date: Date) {
            viewController.endEventEditing()
            print("Did Tap at date: \(date)")
        }
        
        func dayViewDidBeginDragging(dayView: DayView) {
            viewController.endEventEditing()
            print("DayView did begin dragging")
        }
        
        func dayView(dayView: DayView, willMoveTo date: Date) {
            print("DayView = \(dayView) will move to: \(date)")
        }
        
        func dayView(dayView: DayView, didMoveTo date: Date) {
            print("DayView = \(dayView) did move to: \(date)")
        }
        
        func dayViewDidTransitionCancel(dayView: CalendarKit.DayView) {
        }
        
        func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
            print("Did long press timeline at date \(date)")
            // Cancel editing current event and start creating a new one
            viewController.endEventEditing()
            let event = generateEventNearDate(date)
            print("Creating a new event")
            viewController.create(event: event, animated: true)
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
        
        func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
            print("did finish editing \(event)")
            print("new startDate: \(event.dateInterval.start) new endDate: \(event.dateInterval.end)")
            
            if let _ = event.editedEvent {
                event.commitEditing()
            }
            
            if let createdEvent = createdEvent {
                createdEvent.editedEvent = nil
                generatedEvents.append(createdEvent)
                self.createdEvent = nil
                viewController.endEventEditing()
            }
            
            viewController.reloadData()
        }
    }
}
