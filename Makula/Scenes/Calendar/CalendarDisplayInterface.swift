/// The display interface, which is available to the logic for updating the views.
protocol CalendarDisplayInterface: class {
	/**
	 Updates the display with given data to show.

	 - parameter model: The data to show.
	 */
	func updateDisplay(model: CalendarDisplayModel.UpdateDisplay)
}
