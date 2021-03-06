import UIKit

/**
 The view controller which represents the display.

 Its purpose is to hold references to the logic and any views in the scene.
 It is responsible for displaying data provided by the logic by manipulating the view.
 The view controller does NOT manage the routing to other scenes, this is the purpose of the router which is called by the logic.
 The view controller is NOT responsible for any logic beyond formatting the output.
 */
class CalendarDisplay: BaseViewController {
	// MARK: - Dependencies

	/// The reference to the logic.
	private var logic: CalendarLogicInterface?

	/// The factory method which creates the logic for this display during setup.
	var createLogic: (CalendarDisplayInterface, UIViewController) -> CalendarLogicInterface = { display, viewController in
		CalendarLogic(display: display, router: CalendarRouter(viewController: viewController))
	}

	/// The delegate controller for the table view.
	private var tableController: CalendarTableControllerInterface?

	/// The factory method which creates the table controller when the view gets loaded.
	var createTableController: (UITableView, CalendarLogicInterface) -> CalendarTableControllerInterface = { tableview, logic in
		CalendarTableController(tableView: tableview, logic: logic)
	}

	/// True when the navigation stack should be modified on appear of the view.
	private var modifyNavigationStackOnAppear = false

	// MARK: - Setup

	/**
	 Sets up the instance with a new model.
	 Creates the logic if needed.

	 Has to be called before presenting the view controller.

	 - parameter model: The parameters for setup.
	 */
	func setup(model: CalendarRouterModel.Setup) {
		// Set up Logic.
		if logic == nil {
			logic = createLogic(self, self)
		}
		logic?.setModel(model)
		modifyNavigationStackOnAppear = model.modifyNavigationStack
	}

	// MARK: - View

	/// The root view of this controller. Only defined after the controller's view has been loaded.
	private var rootView: CalendarView! { return view as? CalendarView }

	override func loadView() {
		guard let logic = logic else { fatalError("Logic instance expected") }
		view = CalendarView(logic: logic)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Create table controller.
		guard let logic = logic else { fatalError("Logic instance expected") }
		tableController = createTableController(rootView.tableView, logic)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Request initial display data.
		logic?.requestDisplayData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Modify the navigation stack.
		if modifyNavigationStackOnAppear {
			modifyNavigationStackOnAppear = false

			guard let navigationController = navigationController else { fatalError() }
			var viewControllers = navigationController.viewControllers
			precondition(viewControllers.last == self)
			viewControllers.removeLast()
			precondition(viewControllers.last is AppointmentDatePickerDisplay)
			viewControllers.removeLast()
			precondition(viewControllers.last is NewAppointmentDisplay)
			viewControllers.removeLast()
			if viewControllers.last is CalendarDisplay {
				// Transitioned from Calendar -> New -> Calendar so also remove the first Calendar scene.
				viewControllers.removeLast()
			}
			viewControllers.append(self)
			navigationController.viewControllers = viewControllers
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { _ in
		}, completion: { _ in
			self.logic?.requestDisplayData()
		})
		super.viewWillTransition(to: size, with: coordinator)
	}
}

// MARK: - CalendarDisplayInterface

extension CalendarDisplay: CalendarDisplayInterface {
	func updateDisplay(model: CalendarDisplayModel.UpdateDisplay) {
		// Update the view.
		rootView.tableFullscreen = model.largeStyle
		// Update table view.
		tableController?.setData(model: model)
	}
}
