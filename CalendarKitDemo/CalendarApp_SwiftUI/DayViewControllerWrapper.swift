//
//  DayViewControllerWrapper.swift
//  demo-CalenderKit
//
//  Created by Apple on 09/02/24.
//


//import SwiftUI
//import CalendarKit
//
//final class CalendarController: DayViewController {
//    
//    var selectedEvent: Event?
//    var generatedEvents: [EventDescriptor] = [EventDescriptor]() {
//        didSet {
//            // Call the closure passing the updated events array
//            eventsUpdated?(generatedEvents)
//        }
//    }
//    private var createdEvent: EventDescriptor?
//    var alreadyGeneratedSet = Set<Date>()
//    
//    // Closure properties to pass updated values
//    var eventsUpdated: (([EventDescriptor]) -> Void)?
//    var didSelectEventView: ((Event) -> Void)?
//    var didLongPressEventView: ((Event) -> Void)?
//    var didTapTimelineAt: ((Date) -> Void)?
//    var didLongPressTimelineAt: ((Date) -> Void)?
//    var didBeginDragging: (() -> Void)?
//    var didTransitionCancel: (() -> Void)?
//    var willMoveTo: ((Date) -> Void)?
//    var didMoveTo: ((Date) -> Void)?
//    var didUpdateEvent: ((EventDescriptor) -> Void)?
//    
//    init(selectedEvent: Event? = nil,
//         events: [EventDescriptor] = [],
//         didSelectEventView: ((Event) -> Void)? = nil,
//         didLongPressEventView: ((Event) -> Void)? = nil,
//         didTapTimelineAt: ((Date) -> Void)? = nil,
//         didLongPressTimelineAt: ((Date) -> Void)? = nil,
//         didBeginDragging: (() -> Void)? = nil,
//         didTransitionCancel: (() -> Void)? = nil,
//         willMoveTo: ((Date) -> Void)? = nil,
//         didMoveTo: ((Date) -> Void)? = nil,
//         didUpdateEvent: ((EventDescriptor) -> Void)? = nil) {
//        
//        self.selectedEvent = selectedEvent
//        self.generatedEvents = events
//        super.init(nibName: nil, bundle: nil)
//        
//        // Assign closure implementations
//        self.didSelectEventView = didSelectEventView
//        self.didLongPressEventView = didLongPressEventView
//        self.didTapTimelineAt = didTapTimelineAt
//        self.didLongPressTimelineAt = didLongPressTimelineAt
//        self.didBeginDragging = didBeginDragging
//        self.didTransitionCancel = didTransitionCancel
//        self.willMoveTo = willMoveTo
//        self.didMoveTo = didMoveTo
//        self.didUpdateEvent = didUpdateEvent
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    var colors = [UIColor.blue,
//                  UIColor.yellow,
//                  UIColor.green,
//                  UIColor.red]
//    
//    override func loadView() {
//        calendar.timeZone = .current
//        dayView = DayView(calendar: calendar)
//        view = dayView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.isHidden = true
//        dayView.autoScrollToFirstEvent = true
//        reloadData()
//    }
//    
//    // MARK: EventDataSource
//    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
//        return generatedEvents
//    }
//    
//    override func dayViewDidSelectEventView(_ eventView: EventView) {
//        guard let descriptor = eventView.descriptor as? Event else {
//            return
//        }
//        selectedEvent = descriptor
//        didSelectEventView?(descriptor)
//    }
//    
//    override func dayViewDidLongPressEventView(_ eventView: EventView) {
//        guard let descriptor = eventView.descriptor as? Event else {
//            return
//        }
//        endEventEditing()
//        beginEditing(event: descriptor, animated: true)
//        didLongPressEventView?(descriptor)
//    }
//    
//    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
//        endEventEditing()
//        didTapTimelineAt?(date)
//    }
//    
//    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
//        print("Did long press timeline at date \(date)")
//        // Cancel editing current event and start creating a new one
//        endEventEditing()
//        didLongPressTimelineAt?(date)
//        let event = generateEventNearDate(date)
//        print("Creating a new event")
//        create(event: event, animated: true)
//        createdEvent = event
//    }
//    
//    override func dayViewDidBeginDragging(dayView: DayView) {
//        endEventEditing()
//        didBeginDragging?()
//    }
//    
//    override func dayViewDidTransitionCancel(dayView: DayView) {
//        didTransitionCancel?()
//    }
//    
//    override func dayView(dayView: DayView, willMoveTo date: Date) {
//        willMoveTo?(date)
//    }
//    
//    override func dayView(dayView: DayView, didMoveTo date: Date) {
//        didMoveTo?(date)
//    }
//    
//    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
//        
//        if let _ = event.editedEvent {
//            event.commitEditing()
//        }
//        if let createdEvent = createdEvent {
//            createdEvent.editedEvent = nil
//            generatedEvents.append(createdEvent)
//            self.createdEvent = nil
//            endEventEditing()
//        }
//        reloadData()
//        
//        didUpdateEvent?(event)
//    }
//    
//    private func generateEventNearDate(_ date: Date) -> EventDescriptor {
//        let duration = (60...220).randomElement()!
//        let event = Event()
//        
//        event.startDate = Calendar.current.date(byAdding: .minute, value: 0, to: date)!
//        event.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: event.startDate)!
//        
//        event.text = "Yo Long Pressed Added Event"
//        event.color = colors.randomElement()!
//        event.editedEvent = event
//        
//        return event
//    }
//}
//
//
//struct DayViewControllerWrapper: UIViewControllerRepresentable {
//    
//    @Binding var selectedEvent: Event?
//    @Binding var events: [Event]
//    
//    var eventsUpdated: (([EventDescriptor]) -> Void)?
//    
//    var didSelectEventView: ((Event) -> Void)?
//    var didLongPressEventView: ((Event) -> Void)?
//    var didTapTimelineAt: ((Date) -> Void)?
//    var didLongPressTimelineAt: ((Date) -> Void)?
//    var didBeginDragging: (() -> Void)?
//    var didTransitionCancel: (() -> Void)?
//    var willMoveTo: ((Date) -> Void)?
//    var didMoveTo: ((Date) -> Void)?
//    var didUpdateEvent: ((EventDescriptor) -> Void)?
//    
//    func makeUIViewController(context: Context) -> CalendarController {
//        let viewController = CalendarController()
//        viewController.selectedEvent = selectedEvent
//        viewController.generatedEvents = events
//        viewController.didSelectEventView = didSelectEventView
//        viewController.didLongPressEventView = didLongPressEventView
//        viewController.didTapTimelineAt = didTapTimelineAt
//        viewController.didLongPressTimelineAt = didLongPressTimelineAt
//        viewController.didBeginDragging = didBeginDragging
//        viewController.didTransitionCancel = didTransitionCancel
//        viewController.willMoveTo = willMoveTo
//        viewController.didMoveTo = didMoveTo
//        viewController.didUpdateEvent = didUpdateEvent
//        viewController.eventsUpdated = eventsUpdated
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: CalendarController, context: Context) {
//        
//        uiViewController.selectedEvent = selectedEvent
//        uiViewController.generatedEvents = events
//        uiViewController.reloadData()
//        
//        eventsUpdated?(uiViewController.generatedEvents)
//    }
//}
//
//struct DayViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        DayViewControllerWrapper(selectedEvent: .constant(nil), events: .constant([]))
//    }
//}
